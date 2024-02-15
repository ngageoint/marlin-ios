//
//  NavigationalWarningLocalDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 2/1/24.
//

import Foundation
import CoreData
import Combine
import UIKit
import BackgroundTasks

protocol NavigationalWarningLocalDataSource {

    func getNavigationalWarning(
        msgYear: Int64,
        msgNumber: Int64,
        navArea: String?
    ) -> NavigationalWarningModel?

    func getNavigationalWarningsInBounds(
        filters: [DataSourceFilterParameter]?,
        minLatitude: Double?,
        maxLatitude: Double?,
        minLongitude: Double?,
        maxLongitude: Double?
    ) -> [NavigationalWarningModel]

    func getNavigationalWarnings(
        filters: [DataSourceFilterParameter]?
    ) async -> [NavigationalWarningModel]

    func navigationalWarnings(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<[NavigationalWarningItem], Error>

    func getCount(filters: [DataSourceFilterParameter]?) -> Int
    func insert(task: BGTask?, navigationalWarnings: [NavigationalWarningModel]) async -> Int
    func batchImport(from propertiesList: [NavigationalWarningModel]) async throws -> Int
}

class NavigationalWarningCoreDataDataSource:
    CoreDataDataSource,
    NavigationalWarningLocalDataSource,
    ObservableObject {
    typealias DataType = NavigationalWarning
    typealias ModelType = NavigationalWarningModel
    typealias Item = NavigationalWarningItem

    private lazy var context: NSManagedObjectContext = {
        PersistenceController.current.newTaskContext()
    }()

    func getNavigationalWarning(
        msgYear: Int64,
        msgNumber: Int64,
        navArea: String?
    ) -> ModelType? {
        return context.performAndWait {
            if let navArea = navArea {
                if let navigationalWarning = try? context.fetchFirst(
                    DataType.self,
                    predicate: NSPredicate(
                        format: "msgYear = %d AND msgNumber = %d AND navArea = %@",
                        argumentArray: [msgYear, msgNumber, navArea]
                    )) {
                    return ModelType(navigationalWarning: navigationalWarning)
                }
            }
            return nil
        }
    }

    func getNavigationalWarningsInBounds(
        filters: [DataSourceFilterParameter]?,
        minLatitude: Double?,
        maxLatitude: Double?,
        minLongitude: Double?,
        maxLongitude: Double?
    ) -> [ModelType] {
        var models: [ModelType] = []
        // TODO: this should probably execute on a different context and be a perform
        context.performAndWait {
            let fetchRequest = DataType.fetchRequest()
            var predicates: [NSPredicate] = buildPredicates(filters: filters)

            if let minLatitude = minLatitude,
               let maxLatitude = maxLatitude,
               let minLongitude = minLongitude,
               let maxLongitude = maxLongitude {
                predicates.append(
                    self.boundsPredicate(
                        minLatitude: minLatitude,
                        maxLatitude: maxLatitude,
                        minLongitude: minLongitude,
                        maxLongitude: maxLongitude
                    )
                )
            }

            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            fetchRequest.predicate = predicate

            fetchRequest.sortDescriptors = UserDefaults.standard.sort(DataSources.navWarning.key).map({ sortParameter in
                sortParameter.toNSSortDescriptor()
            })
            models = (context.fetch(request: fetchRequest)?.map { model in
                ModelType(navigationalWarning: model)
            }) ?? []
        }
        return models
    }

    override func boundsPredicate(
        minLatitude: Double,
        maxLatitude: Double,
        minLongitude: Double,
        maxLongitude: Double
    ) -> NSPredicate {
        return NSPredicate(
            format: """
                (maxLatitude >= %lf AND minLatitude <= %lf AND maxLongitude >= %lf AND minLongitude <= %lf) \
                OR minLongitude < -180 OR maxLongitude > 180
            """, minLatitude, maxLatitude, minLongitude, maxLongitude
        )
    }

    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        let fetchRequest = DataType.fetchRequest()
        let predicates: [NSPredicate] = buildPredicates(filters: filters)

        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.predicate = predicate

        fetchRequest.sortDescriptors = UserDefaults.standard.sort(DataSources.navWarning.key).map({ sortParameter in
            sortParameter.toNSSortDescriptor()
        })

        var count = 0
        context.performAndWait {
            count = (try? context.count(for: fetchRequest)) ?? 0
        }
        return count
    }

    func getNavigationalWarnings(
        filters: [DataSourceFilterParameter]?
    ) async -> [NavigationalWarningModel] {
        return await context.perform {
            let fetchRequest = DataType.fetchRequest()
            var predicates: [NSPredicate] = self.buildPredicates(filters: filters)

            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            fetchRequest.predicate = predicate

            fetchRequest.sortDescriptors = UserDefaults.standard.sort(DataSources.asam.key).map({ sortParameter in
                sortParameter.toNSSortDescriptor()
            })
            return (self.context.fetch(request: fetchRequest)?.map { navigationalWarning in
                NavigationalWarningModel(navigationalWarning: navigationalWarning)
            }) ?? []
        }
    }

}

// MARK: Data Publisher methods
extension NavigationalWarningCoreDataDataSource {

    struct ModelPage {
        var list: [Item]
        var next: Int?
        var currentHeader: String?
    }

    func navigationalWarnings(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<[Item], Error> {
        return models(filters: filters, at: nil, currentHeader: nil, paginatedBy: paginator)
            .map(\.list)
            .eraseToAnyPublisher()
    }

    func models(
        filters: [DataSourceFilterParameter]?,
        at page: Page?,
        currentHeader: String?
    ) -> AnyPublisher<ModelPage, Error> {

        let request = DataType.fetchRequest()
        let predicates: [NSPredicate] = buildPredicates(filters: filters)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.predicate = predicate

        request.fetchLimit = 100
        request.fetchOffset = (page ?? 0) * request.fetchLimit
        let userSort = UserDefaults.standard.sort(DataSources.navWarning.key)
        let sortDescriptors: [DataSourceSortParameter] =
        userSort.isEmpty ? DataSources.navWarning.defaultSort : userSort

        request.sortDescriptors = sortDescriptors.map({ sortParameter in
            sortParameter.toNSSortDescriptor()
        })
        var previousHeader: String? = currentHeader
        var list: [Item] = []
        context.performAndWait {
            if let fetched = context.fetch(request: request) {

                list = fetched.flatMap { item in
                    guard let sortDescriptor = sortDescriptors.first else {
                        return [Item.listItem(ModelType(navigationalWarning: item))]
                    }

                    if !sortDescriptor.section {
                        return [Item.listItem(ModelType(navigationalWarning: item))]
                    }

                    return createSectionHeaderAndListItem(
                        item: item,
                        sortDescriptor: sortDescriptor,
                        previousHeader: &previousHeader
                    )
                }
            }
        }

        let modelPage: ModelPage = ModelPage(
            list: list,
            next: (page ?? 0) + 1,
            currentHeader: previousHeader
        )

        return Just(modelPage)
            .setFailureType(to: Error.self)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func createSectionHeaderAndListItem(
        item: DataType,
        sortDescriptor: DataSourceSortParameter,
        previousHeader: inout String?
    ) -> [Item] {
        let currentValue = item.value(forKey: sortDescriptor.property.key)
        let sortValueString: String? = getCurrentSortValue(sortDescriptor: sortDescriptor, sortValue: currentValue)

        if let previous = previousHeader, let sortValueString = sortValueString {
            if previous != sortValueString {
                previousHeader = sortValueString
                return [
                    Item.sectionHeader(header: sortValueString),
                    Item.listItem(ModelType(navigationalWarning: item))
                ]
            }
        } else if previousHeader == nil, let sortValueString = sortValueString {
            previousHeader = sortValueString
            return [
                Item.sectionHeader(header: sortValueString),
                Item.listItem(ModelType(navigationalWarning: item))
            ]
        }

        return [Item.listItem(ModelType(navigationalWarning: item))]
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
                sortValueString = DataSources.navWarning.dateFormatter.string(from: currentValue)
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

    func models(
        filters: [DataSourceFilterParameter]?,
        at page: Page?,
        currentHeader: String?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<ModelPage, Error> {
        return models(filters: filters, at: page, currentHeader: currentHeader)
            .map { result -> AnyPublisher<ModelPage, Error> in
                if let paginator = paginator, let next = result.next {
                    return self.models(
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
extension NavigationalWarningCoreDataDataSource {

    func insert(task: BGTask? = nil, navigationalWarnings: [ModelType]) async -> Int {
        let count = navigationalWarnings.count
        NSLog("Received \(count) \(DataSources.navWarning.key) records.")

        // Create an operation that performs the main part of the background task.
        operation = NavigationalWarningDataLoadOperation(navigationalWarnings: navigationalWarnings, localDataSource: self)

        return await executeOperationInBackground(task: task)
    }

    func batchImport(from propertiesList: [ModelType]) async throws -> Int {
        guard !propertiesList.isEmpty else { return 0 }
        let taskContext = PersistenceController.current.newTaskContext()
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importNavigationalWarnings"

        let count = try await taskContext.perform {
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = self.newBatchInsertRequest(with: propertiesList)
            batchInsertRequest.resultType = .count
            if let fetchResult = try? taskContext.execute(batchInsertRequest),
               let batchInsertResult = fetchResult as? NSBatchInsertResult {
                try? taskContext.save()
                if let count = batchInsertResult.result as? Int, count > 0 {
                    NSLog("Inserted \(count) navigational warning records")
                    return count
                } else {
                    NSLog("No new navigational warning records")
                }
                return 0
            }
            throw MSIError.batchInsertError
        }
        return count
    }

    func newBatchInsertRequest(with propertyList: [ModelType]) -> NSBatchInsertRequest {
        var index = 0
        let total = propertyList.count

        // Provide one dictionary at a time when the closure is called.
        let batchInsertRequest = NSBatchInsertRequest(
            entity: DataType.entity(),
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