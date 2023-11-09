//
//  AsamLocalDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 9/15/23.
//

import Foundation
import CoreData
import Combine
import UIKit
import BackgroundTasks

protocol AsamLocalDataSource {
    func getNewestAsam() -> AsamModel?
    @discardableResult
    func getAsam(reference: String?) -> AsamModel?
    func getAsams(filters: [DataSourceFilterParameter]?) -> [AsamModel]
    func getCount(filters: [DataSourceFilterParameter]?) -> Int
    func observeAsamListItems(filters: [DataSourceFilterParameter]?) -> AnyPublisher<CollectionDifference<AsamModel>, Never>
    func insert(task: BGTask?, asams: [AsamModel]) async -> Int
    func batchImport(from propertiesList: [AsamModel]) async throws -> Int
}

class AsamCoreDataDataSource: AsamLocalDataSource, ObservableObject {
    private var context: NSManagedObjectContext
    var cleanup : (() -> ())?
    var operation: AsamDataLoadOperation?
    
    required init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getNewestAsam() -> AsamModel? {
        let context = PersistenceController.current.newTaskContext()
        var asam: AsamModel? = nil
        context.performAndWait {
            if let newestAsam = try? PersistenceController.current.fetchFirst(Asam.self, sortBy: [NSSortDescriptor(keyPath: \Asam.date, ascending: false)], predicate: nil, context: context) {
                asam = AsamModel(asam: newestAsam)
            }
        }
        return asam
    }
    
    func getAsam(reference: String?) -> AsamModel? {
        var model: AsamModel?
        context.performAndWait {
            if let reference = reference {
                if let asam = context.fetchFirst(Asam.self, key: "reference", value: reference) {
                    model = AsamModel(asam: asam)
                }
            }
        }
        return model
    }
    
    func getAsams(filters: [DataSourceFilterParameter]?) -> [AsamModel] {
        var asams: [AsamModel] = []
        context.performAndWait {
            let request: NSFetchRequest<Asam> = AsamFilterable().fetchRequest(filters: filters, commonFilters: nil) as? NSFetchRequest<Asam> ?? Asam.fetchRequest()
            request.sortDescriptors = UserDefaults.standard.sort(Asam.key).map({ sortParameter in
                sortParameter.toNSSortDescriptor()
            })
            asams = (context.fetch(request: request)?.map { asam in
                AsamModel(asam: asam)
            }) ?? []
        }
        
        return asams
    }
    
    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        guard let fetchRequest = AsamFilterable().fetchRequest(filters: filters, commonFilters: nil) else {
            return 0
        }
        var count = 0
        context.performAndWait {
            count = (try? context.count(for: fetchRequest)) ?? 0
        }
        return count
    }
    
    func observeAsamListItems(filters: [DataSourceFilterParameter]?) -> AnyPublisher<CollectionDifference<AsamModel>, Never> {
        let request: NSFetchRequest<Asam> = AsamFilterable().fetchRequest(filters: filters, commonFilters: nil) as? NSFetchRequest<Asam> ?? Asam.fetchRequest()
        request.sortDescriptors = UserDefaults.standard.sort(Asam.key).map({ sortParameter in
            sortParameter.toNSSortDescriptor()
        })
        return context.changesPublisher(for: request, transformer: { asam in
            AsamModel(asam: asam)
        })
        .receive(on: DispatchQueue.main)
        .catch { _ in Empty() }
        .eraseToAnyPublisher()
    }
    
    func insert(task: BGTask? = nil, asams: [AsamModel]) async -> Int {
        let count = asams.count
        NSLog("Received \(count) \(Asam.key) records.")
        
        let crossReference = Dictionary(grouping: asams, by: \.reference)
        let duplicates = crossReference
            .filter { $1.count > 1 }
        
        print("Found Dupicate ASAMs \(duplicates.keys)")
        
        if let task = task {
            registerBackgroundTask(name: task.identifier)
            guard backgroundTask != .invalid else { return 0 }
        }
        
        // Create an operation that performs the main part of the background task.
        operation = AsamDataLoadOperation(asams: asams, localDataSource: self)
        
        // Provide the background task with an expiration handler that cancels the operation.
        task?.expirationHandler = {
            self.operation?.cancel()
        }
        
        // Start the operation.
        if let operation = operation {
            self.asamBackgroundLoadQueue.addOperation(operation)
        }
        
        return await withCheckedContinuation { continuation in
            // Inform the system that the background task is complete
            // when the operation completes.
            operation?.completionBlock = {
                task?.setTaskCompleted(success: !(self.operation?.isCancelled ?? false))
                continuation.resume(returning: self.operation?.count ?? 0)
            }
        }
    }
    
    func batchImport(from propertiesList: [AsamModel]) async throws -> Int {
        guard !propertiesList.isEmpty else { return 0 }
        let taskContext = PersistenceController.current.newTaskContext()
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importAsams"
        
        /// - Tag: performAndWait
        let count = try await taskContext.perform {
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = self.newBatchInsertRequest(with: propertiesList)
            batchInsertRequest.resultType = .count
            if let fetchResult = try? taskContext.execute(batchInsertRequest),
               let batchInsertResult = fetchResult as? NSBatchInsertResult {
                try? taskContext.save()
                if let count = batchInsertResult.result as? Int, count > 0 {
                    NSLog("Inserted \(count) ASAM records")
                    return count
                } else {
                    NSLog("No new ASAM records")
                }
                return 0
            }
            throw MSIError.batchInsertError
        }
        return count
    }
    
    func newBatchInsertRequest(with propertyList: [AsamModel]) -> NSBatchInsertRequest {
        var index = 0
        let total = propertyList.count
        
        // Provide one dictionary at a time when the closure is called.
        let batchInsertRequest = NSBatchInsertRequest(entity: Asam.entity(), dictionaryHandler: { dictionary in
            guard index < total else { return true }
            let propertyDictionary = propertyList[index].dictionaryValue
            dictionary.addEntries(from: propertyDictionary.mapValues({ value in
                if let value = value {
                    return value
                }
                return NSNull()
            }) as [AnyHashable : Any])
            index += 1
            return false
        })
        return batchInsertRequest
    }
    
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    lazy var asamBackgroundLoadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.name = "Asam load queue"
        return queue
    }()
    
    func registerBackgroundTask(name: String) {
        NSLog("Register the background task \(name)")
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: name) { [weak self] in
            NSLog("iOS has signaled time has expired \(name)")
            self?.cleanup?()
            print("canceling \(name)")
            self?.operation?.cancel()
            print("calling endBackgroundTask \(name)")
            self?.endBackgroundTaskIfActive()
        }
    }
    
    func endBackgroundTaskIfActive() {
        let isBackgroundTaskActive = backgroundTask != .invalid
        if isBackgroundTaskActive {
            NSLog("Background task ended. Asam Load")
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
}
