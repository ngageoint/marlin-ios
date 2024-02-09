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
    func getAsamsInBounds(
        filters: [DataSourceFilterParameter]?,
        minLatitude: Double?,
        maxLatitude: Double?,
        minLongitude: Double?,
        maxLongitude: Double?
    ) -> [AsamModel]
    func asams(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<[AsamItem], Error>
    func getAsams(
        filters: [DataSourceFilterParameter]?
    ) async -> [AsamModel]

    func getCount(filters: [DataSourceFilterParameter]?) -> Int
    func insert(task: BGTask?, asams: [AsamModel]) async -> Int
    func batchImport(from propertiesList: [AsamModel]) async throws -> Int
}

struct AsamModelPage {
    var asamList: [AsamItem]
    var next: Int?
    var currentHeader: String?
}

class AsamCoreDataDataSource: CoreDataDataSource, AsamLocalDataSource, ObservableObject {
    private lazy var context: NSManagedObjectContext = {
        PersistenceController.current.newTaskContext()
    }()

    func getNewestAsam() -> AsamModel? {
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

    func getAsamsInBounds(
        filters: [DataSourceFilterParameter]?,
        minLatitude: Double?,
        maxLatitude: Double?,
        minLongitude: Double?,
        maxLongitude: Double?
    ) -> [AsamModel] {
        var asams: [AsamModel] = []
        // TODO: this should probably execute on a different context and be a perform
        context.performAndWait {
            let fetchRequest = Asam.fetchRequest()
            var predicates: [NSPredicate] = buildPredicates(filters: filters)

            if let minLatitude = minLatitude,
               let maxLatitude = maxLatitude,
               let minLongitude = minLongitude,
               let maxLongitude = maxLongitude {
                predicates.append(NSPredicate(
                    format: "latitude >= %lf AND latitude <= %lf AND longitude >= %lf AND longitude <= %lf",
                    minLatitude,
                    maxLatitude,
                    minLongitude,
                    maxLongitude
                ))
            }

            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            fetchRequest.predicate = predicate

            fetchRequest.sortDescriptors = UserDefaults.standard.sort(DataSources.asam.key).map({ sortParameter in
                sortParameter.toNSSortDescriptor()
            })
            asams = (context.fetch(request: fetchRequest)?.map { asam in
                AsamModel(asam: asam)
            }) ?? []
        }

        return asams
    }

    func getAsams(
        filters: [DataSourceFilterParameter]?
    ) async -> [AsamModel] {
        return await context.perform {
            let fetchRequest = Asam.fetchRequest()
            var predicates: [NSPredicate] = self.buildPredicates(filters: filters)

            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            fetchRequest.predicate = predicate

            fetchRequest.sortDescriptors = UserDefaults.standard.sort(DataSources.asam.key).map({ sortParameter in
                sortParameter.toNSSortDescriptor()
            })
            return (self.context.fetch(request: fetchRequest)?.map { asam in
                AsamModel(asam: asam)
            }) ?? []
        }
    }

    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        let fetchRequest = Asam.fetchRequest()
        let predicates: [NSPredicate] = buildPredicates(filters: filters)

        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.predicate = predicate

        fetchRequest.sortDescriptors = UserDefaults.standard.sort(DataSources.asam.key).map({ sortParameter in
            sortParameter.toNSSortDescriptor()
        })

        var count = 0
        context.performAndWait {
            count = (try? context.count(for: fetchRequest)) ?? 0
        }
        return count
    }
}

// MARK: Data Publisher methods
extension AsamCoreDataDataSource {

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
        at page: Page?, 
        currentHeader: String?
    ) -> AnyPublisher<AsamModelPage, Error> {

        let request = Asam.fetchRequest()
        let predicates: [NSPredicate] = buildPredicates(filters: filters)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.predicate = predicate

        request.fetchLimit = 100
        request.fetchOffset = (page ?? 0) * request.fetchLimit
        let userSort = UserDefaults.standard.sort(DataSources.asam.key)
        let sortDescriptors: [DataSourceSortParameter] =
        userSort.isEmpty ? DataSources.asam.defaultSort : userSort

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
                sortValueString = DataSources.asam.dateFormatter.string(from: currentValue)
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
}

// MARK: Import methods
extension AsamCoreDataDataSource {
    func insert(task: BGTask? = nil, asams: [AsamModel]) async -> Int {
        let count = asams.count
        NSLog("Received \(count) \(DataSources.asam.key) records.")

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
