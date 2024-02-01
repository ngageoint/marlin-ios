//
//  ElectronicPublicationLocalDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 2/1/24.
//

import Foundation
import CoreData
import Combine
import UIKit
import BackgroundTasks

protocol ElectronicPublicationLocalDataSource {
    func getElectronicPublication(s3Key: String?) -> ElectronicPublicationModel?
    func getCount(filters: [DataSourceFilterParameter]?) -> Int
    func insert(task: BGTask?, epubs: [ElectronicPublicationModel]) async -> Int
    func batchImport(from propertiesList: [ElectronicPublicationModel]) async throws -> Int
}

class ElectronicPublicationCoreDataDataSource: 
    CoreDataDataSource,
    ElectronicPublicationLocalDataSource,
    ObservableObject {
    private lazy var context: NSManagedObjectContext = {
        PersistenceController.current.newTaskContext()
    }()

    func getElectronicPublication(s3Key: String?) -> ElectronicPublicationModel? {
        if let s3Key = s3Key,
           let epub = context.fetchFirst(ElectronicPublication.self, key: "s3Key", value: s3Key) {
            return ElectronicPublicationModel(epub: epub)
        }
        return nil
    }

    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        let fetchRequest = ElectronicPublication.fetchRequest()
        let predicates: [NSPredicate] = buildPredicates(filters: filters)

        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.predicate = predicate

        fetchRequest.sortDescriptors = UserDefaults.standard.sort(DataSources.epub.key).map({ sortParameter in
            sortParameter.toNSSortDescriptor()
        })

        var count = 0
        context.performAndWait {
            count = (try? context.count(for: fetchRequest)) ?? 0
        }
        return count
    }
}

// MARK: Import methods
extension ElectronicPublicationCoreDataDataSource {

    func insert(task: BGTask? = nil, epubs: [ElectronicPublicationModel]) async -> Int {
        let count = epubs.count
        NSLog("Received \(count) \(DataSources.epub.key) records.")

        // Create an operation that performs the main part of the background task.
        operation = ElectronicPublicationDataLoadOperation(epubs: epubs, localDataSource: self)

        return await executeOperationInBackground(task: task)
    }

    func batchImport(from propertiesList: [ElectronicPublicationModel]) async throws -> Int {
        guard !propertiesList.isEmpty else { return 0 }
        let taskContext = PersistenceController.current.newTaskContext()
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importEpubs"

        let count = try await taskContext.perform {
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = self.newBatchInsertRequest(with: propertiesList)
            batchInsertRequest.resultType = .count
            if let fetchResult = try? taskContext.execute(batchInsertRequest),
               let batchInsertResult = fetchResult as? NSBatchInsertResult {
                try? taskContext.save()
                if let count = batchInsertResult.result as? Int, count > 0 {
                    NSLog("Inserted \(count) EPUB records")
                    return count
                } else {
                    NSLog("No new EPUB records")
                }
                return 0
            }
            throw MSIError.batchInsertError
        }
        return count
    }

    func newBatchInsertRequest(with propertyList: [ElectronicPublicationModel]) -> NSBatchInsertRequest {
        var index = 0
        let total = propertyList.count

        // Provide one dictionary at a time when the closure is called.
        let batchInsertRequest = NSBatchInsertRequest(
            entity: ElectronicPublication.entity(),
            dictionaryHandler: { dictionary in
                guard index < total else { return true }
                let propertyDictionary = propertyList[index].dictionaryValue
                dictionary.addEntries(from: propertyDictionary.mapValues({ value in
                    if let value = value {
                        return value
                    }
                    return NSNull()
                }) as [AnyHashable: Any])
                index += 1
                return false
            }
        )
        return batchInsertRequest
    }
}
