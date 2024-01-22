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
    func observeAsamListItems(
        filters: [DataSourceFilterParameter]?
    ) -> AnyPublisher<CollectionDifference<AsamModel>, Never>
    func insert(task: BGTask?, asams: [AsamModel]) async -> Int
    func batchImport(from propertiesList: [AsamModel]) async throws -> Int
    
    func asams(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<[AsamItem], Error>
}

struct AsamModelPage {
    var asamList: [AsamItem]
    var next: Int?
    var currentHeader: String?
}

class AsamCoreDataDataSource: CoreDataDataSource, AsamLocalDataSource, ObservableObject {
    private var context: NSManagedObjectContext
    
    required init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getNewestAsam() -> AsamModel? {
        let context = PersistenceController.current.newTaskContext()
        var asam: AsamModel?
        context.performAndWait {
            if let newestAsam = try? PersistenceController.current.fetchFirst(
                Asam.self,
                sortBy: [
                    NSSortDescriptor(keyPath: \Asam.date, ascending: false)
                ],
                predicate: nil,
                context: context
            ) {
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
            let request: NSFetchRequest<Asam> = AsamFilterable()
                .fetchRequest(filters: filters, commonFilters: nil) as? NSFetchRequest<Asam> ?? Asam.fetchRequest()
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
    
    typealias Page = Int
    
    func asams(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal? = nil
    ) -> AnyPublisher<[AsamItem], Error> {
        return asams(filters: filters, at: nil, currentHeader: nil, paginatedBy: paginator)
            .map(\.asamList)
            .eraseToAnyPublisher()
    }
    
    func asams(
        filters: [DataSourceFilterParameter]?,
        at page: Page?, currentHeader: String?
    ) -> AnyPublisher<AsamModelPage, Error> {

        let request: NSFetchRequest<Asam> = AsamFilterable()
            .fetchRequest(filters: filters, commonFilters: nil) as? NSFetchRequest<Asam> ?? Asam.fetchRequest()
        request.fetchLimit = 100
        request.fetchOffset = (page ?? 0) * request.fetchLimit
        let userSort = UserDefaults.standard.sort(Asam.key)
        let sortDescriptors: [DataSourceSortParameter] = userSort.isEmpty ? Asam.defaultSort : userSort
        
        request.sortDescriptors = sortDescriptors.map({ sortParameter in
            sortParameter.toNSSortDescriptor()
        })
        var previousHeader: String? = currentHeader
        var asams: [AsamItem] = []
        context.performAndWait {
            if let fetched = context.fetch(request: request) {
                
                asams = fetched.flatMap { asam in
                    guard let sortDescriptor = sortDescriptors.first else {
                        return [AsamItem.listItem(AsamListModel(asam: asam))]
                    }

                    if !sortDescriptor.section {
                        return [AsamItem.listItem(AsamListModel(asam: asam))]
                    }

                    return createSectionHeaderAndListItem(
                        asam: asam,
                        sortDescriptor: sortDescriptor,
                        previousHeader: &previousHeader
                    )
                }
            }
        }
        
        let asamPage: AsamModelPage = AsamModelPage(
            asamList: asams, next: (page ?? 0) + 1,
            currentHeader: previousHeader
        )

        return Just(asamPage)
            .setFailureType(to: Error.self)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func createSectionHeaderAndListItem(
        asam: Asam,
        sortDescriptor: DataSourceSortParameter,
        previousHeader: inout String?
    ) -> [AsamItem] {
        let currentValue = asam.value(forKey: sortDescriptor.property.key)
        let sortValueString: String? = getCurrentSortValue(sortDescriptor: sortDescriptor, sortValue: currentValue)

        if let previous = previousHeader, let sortValueString = sortValueString {
            if previous != sortValueString {
                previousHeader = sortValueString
                return [
                    AsamItem.sectionHeader(header: sortValueString),
                    AsamItem.listItem(AsamListModel(asam: asam))
                ]
            }
        } else if previousHeader == nil, let sortValueString = sortValueString {
            previousHeader = sortValueString
            return [
                AsamItem.sectionHeader(header: sortValueString),
                AsamItem.listItem(AsamListModel(asam: asam))
            ]
        }

        return [AsamItem.listItem(AsamListModel(asam: asam))]
    }

    // ignore due to the amount of data types
    // swiftlint:disable cyclomatic_complexity
    func getCurrentSortValue(sortDescriptor: DataSourceSortParameter, sortValue: Any?) -> String? {
        var sortValueString: String?
        switch sortDescriptor.property.type {
        case .string:
            sortValueString = sortValue as? String
        case .date:
            if let currentValue = sortValue as? Date {
                sortValueString = Asam.dateFormatter.string(from: currentValue)
            }
        case .int:
            sortValueString = (sortValue as? Int)?.zeroIsEmptyString
        case .float:
            sortValueString = (sortValue as? Float)?.zeroIsEmptyString
        case .double:
            sortValueString = (sortValue as? Double)?.zeroIsEmptyString
        case .boolean:
            sortValueString = ((sortValue as? Bool) ?? false) ? "True" : "False"
        case .enumeration:
            sortValueString = sortValue as? String
        case .latitude:
            sortValueString = (sortValue as? Double)?.latitudeDisplay
        case .longitude:
            sortValueString = (sortValue as? Double)?.longitudeDisplay
        default:
            return nil
        }
        return sortValueString
    }
    // swiftlint:enable cyclomatic_complexity

    func asams(
        filters: [DataSourceFilterParameter]?,
        at page: Page?,
        currentHeader: String?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<AsamModelPage, Error> {
        return asams(filters: filters, at: page, currentHeader: currentHeader)
            .map { result -> AnyPublisher<AsamModelPage, Error> in
                if let paginator = paginator, let next = result.next {
                    return self.asams(
                        filters: filters,
                        at: next,
                        currentHeader: result.currentHeader,
                        paginatedBy: paginator
                    )
                    .wait(untilOutputFrom: paginator)
                    .retry(.max)
                    .prepend(result)
                    .eraseToAnyPublisher()
                } else {
                    return Just(result)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
    
    func observeAsamListItems(
        filters: [DataSourceFilterParameter]?
    ) -> AnyPublisher<CollectionDifference<AsamModel>, Never> {
        let request: NSFetchRequest<Asam> = AsamFilterable()
            .fetchRequest(filters: filters, commonFilters: nil) as? NSFetchRequest<Asam> ?? Asam.fetchRequest()
//        request.fetchLimit = 100
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

        // Create an operation that performs the main part of the background task.
        operation = AsamDataLoadOperation(asams: asams, localDataSource: self)

        return await executeOperationInBackground(task: task)
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
            }) as [AnyHashable: Any])
            index += 1
            return false
        })
        return batchInsertRequest
    }
}
