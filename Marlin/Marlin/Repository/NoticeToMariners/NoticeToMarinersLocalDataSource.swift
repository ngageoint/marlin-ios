//
//  NoticeToMarinersLocalDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 2/1/24.
//

import Foundation
import CoreData
import Combine
import UIKit
import BackgroundTasks

enum NoticeToMarinersItem: Hashable, Identifiable {
    var id: String {
        switch self {
        case .listItem(let noticeToMariners):
            return noticeToMariners.id
        case .sectionHeader(let header):
            return header
        }
    }

    case listItem(_ noticeToMariners: NoticeToMarinersModel)
    case sectionHeader(header: String)
}

protocol NoticeToMarinersLocalDataSource {
    func getNoticeToMariners(
        noticeNumber: Int64?
    ) -> NoticeToMarinersModel?

    func noticeToMariners(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<[NoticeToMarinersItem], Error>

    func getCount(filters: [DataSourceFilterParameter]?) -> Int
    func insert(task: BGTask?, noticeToMariners: [NoticeToMarinersModel]) async -> Int
    func batchImport(from propertiesList: [NoticeToMarinersModel]) async throws -> Int
}

class NoticeToMarinersCoreDataDataSource:
    CoreDataDataSource,
    NoticeToMarinersLocalDataSource,
    ObservableObject {
    typealias DataType = NoticeToMariners
    typealias ModelType = NoticeToMarinersModel
    typealias Item = NoticeToMarinersItem

    private lazy var context: NSManagedObjectContext = {
        PersistenceController.current.newTaskContext()
    }()

    func getNoticeToMariners(
        noticeNumber: Int64?
    ) -> ModelType? {
        if let noticeNumber = noticeNumber {
            if let notice = try? context.fetchFirst(
                DataType.self,
                predicate: NSPredicate(format: "noticeNumber == %i", argumentArray: [noticeNumber])) {
                return ModelType(noticeToMariners: notice)
            }
        }
        return nil
    }

    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        let fetchRequest = DataType.fetchRequest()
        let predicates: [NSPredicate] = buildPredicates(filters: filters)

        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.predicate = predicate

        fetchRequest.sortDescriptors = UserDefaults.standard.sort(DataSources.light.key).map({ sortParameter in
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
extension NoticeToMarinersCoreDataDataSource {

    struct ModelPage {
        var list: [Item]
        var next: Int?
        var currentHeader: String?
    }

    func noticeToMariners(
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
        let userSort = UserDefaults.standard.sort(DataSources.light.key)
        let sortDescriptors: [DataSourceSortParameter] =
        userSort.isEmpty ? DataSources.light.defaultSort : userSort

        request.sortDescriptors = sortDescriptors.map({ sortParameter in
            sortParameter.toNSSortDescriptor()
        })
        var previousHeader: String? = currentHeader
        var list: [Item] = []
        context.performAndWait {
            if let fetched = context.fetch(request: request) {

                list = fetched.flatMap { item in
                    guard let sortDescriptor = sortDescriptors.first else {
                        return [Item.listItem(ModelType(noticeToMariners: item))]
                    }

                    if !sortDescriptor.section {
                        return [Item.listItem(ModelType(noticeToMariners: item))]
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
                    Item.listItem(ModelType(noticeToMariners: item))
                ]
            }
        } else if previousHeader == nil, let sortValueString = sortValueString {
            previousHeader = sortValueString
            return [
                Item.sectionHeader(header: sortValueString),
                Item.listItem(ModelType(noticeToMariners: item))
            ]
        }

        return [Item.listItem(ModelType(noticeToMariners: item))]
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
                sortValueString = DataSources.noticeToMariners.dateFormatter.string(from: currentValue)
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
extension NoticeToMarinersCoreDataDataSource {

    func insert(task: BGTask? = nil, noticeToMariners: [ModelType]) async -> Int {
        let count = noticeToMariners.count
        NSLog("Received \(count) \(DataSources.noticeToMariners.key) records.")

        // Create an operation that performs the main part of the background task.
        operation = NoticeToMarinersDataLoadOperation(noticeToMariners: noticeToMariners, localDataSource: self)

        return await executeOperationInBackground(task: task)
    }

    func batchImport(from propertiesList: [ModelType]) async throws -> Int {
        guard !propertiesList.isEmpty else { return 0 }
        let taskContext = PersistenceController.current.newTaskContext()
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importNoticeToMariners"

        let count = try await taskContext.perform {
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = self.newBatchInsertRequest(with: propertiesList)
            batchInsertRequest.resultType = .count
            if let fetchResult = try? taskContext.execute(batchInsertRequest),
               let batchInsertResult = fetchResult as? NSBatchInsertResult {
                try? taskContext.save()
                if let count = batchInsertResult.result as? Int, count > 0 {
                    NSLog("Inserted \(count) notice to mariners records")
                    return count
                } else {
                    NSLog("No new notice to mariners records")
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
