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

protocol NoticeToMarinersLocalDataSource {
    func getNoticesToMariners(
        noticeNumber: Int?
    ) -> [NoticeToMarinersModel]?
    func getNoticeToMariners(
        odsEntryId: Int?
    ) -> NoticeToMarinersModel?
    func observeNoticeToMariners(
        odsEntryId: Int
    ) -> AnyPublisher<NoticeToMarinersModel, Never>?
    func checkFileExists(odsEntryId: Int) -> Bool
    func deleteFile(odsEntryId: Int)
    func updateProgress(odsEntryId: Int, progress: DownloadProgress)
    func getNewestNoticeToMariners() -> NoticeToMarinersModel?
    func getNoticesToMariners(
        filters: [DataSourceFilterParameter]?
    ) async -> [NoticeToMarinersModel]
    func noticeToMariners(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<[NoticeToMarinersItem], Error>
    func sectionHeaders(
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
    typealias ListModelType = NoticeToMarinersListModel
    typealias Item = NoticeToMarinersItem

    private lazy var context: NSManagedObjectContext = {
        PersistenceController.current.newTaskContext()
    }()

    func getNoticesToMariners(
        noticeNumber: Int?
    ) -> [ModelType]? {
        return context.performAndWait {
            if let noticeNumber = noticeNumber {
                let predicate = NSPredicate(format: "noticeNumber == %i", argumentArray: [noticeNumber])
                let request = NoticeToMariners.fetchRequest()
                request.predicate = predicate
                request.sortDescriptors = DataSources.noticeToMariners.defaultSort.map({ sortParameter in
                    sortParameter.toNSSortDescriptor()
                })
                return context.fetch(request: request)?.map({ notice in
                    ModelType(noticeToMariners: notice)
                })
            }
            return nil
        }
    }

    func getNoticeToMariners(odsEntryId: Int?) -> NoticeToMarinersModel? {
        return context.performAndWait {
            if let odsEntryId = odsEntryId {
                if let notice = try? context.fetchFirst(
                    DataType.self,
                    predicate: NSPredicate(format: "odsEntryId == %i", argumentArray: [odsEntryId])) {
                    return ModelType(noticeToMariners: notice)
                }
            }
            return nil
        }
    }

    func getNewestNoticeToMariners() -> NoticeToMarinersModel? {
        var ntm: NoticeToMarinersModel?
        context.performAndWait {
            if let newestNoticeToMariners = try? PersistenceController.current.fetchFirst(
                NoticeToMariners.self,
                sortBy: [
                    NSSortDescriptor(keyPath: \NoticeToMariners.noticeNumber, ascending: false)
                ],
                predicate: nil,
                context: context
            ) {
                ntm = NoticeToMarinersModel(noticeToMariners: newestNoticeToMariners)
            }
        }
        return ntm
    }

    func getNoticesToMariners(
        filters: [DataSourceFilterParameter]?
    ) async -> [NoticeToMarinersModel] {
        return await context.perform {
            let fetchRequest = NoticeToMariners.fetchRequest()
            var predicates: [NSPredicate] = self.buildPredicates(filters: filters)

            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            fetchRequest.predicate = predicate

            fetchRequest.sortDescriptors = UserDefaults.standard.sort(
                DataSources.noticeToMariners.key
            ).map({ sortParameter in
                sortParameter.toNSSortDescriptor()
            })
            return (self.context.fetch(request: fetchRequest)?.map { ntm in
                NoticeToMarinersModel(noticeToMariners: ntm)
            }) ?? []
        }
    }

    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        let fetchRequest = DataType.fetchRequest()
        let predicates: [NSPredicate] = buildPredicates(filters: filters)

        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.predicate = predicate

        fetchRequest.sortDescriptors = UserDefaults.standard.sort(DataSources.noticeToMariners.key).map({ sortParameter in
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
    func updateProgress(odsEntryId: Int, progress: DownloadProgress) {
        return context.performAndWait {
            guard let notice = try? context.fetchFirst(
                DataType.self,
                predicate: NSPredicate(format: "odsEntryId == %i", argumentArray: [odsEntryId])) else {
                return
            }
            notice.isDownloading = progress.isDownloading
            notice.isDownloaded = progress.isDownloaded
            notice.downloadProgress = progress.downloadProgress
            notice.error = progress.error
            try? context.save()
        }
    }

    func deleteFile(odsEntryId: Int) {
        return context.performAndWait {
            guard let notice = try? context.fetchFirst(
                DataType.self,
                predicate: NSPredicate(format: "odsEntryId == %i", argumentArray: [odsEntryId])),
            let odsKey = notice.odsKey else {
                return
            }
            let docsUrl = URL.documentsDirectory
            let fileUrl = "\(docsUrl.absoluteString)\(odsKey)"
            let destinationUrl = URL(string: fileUrl)

            if let destinationUrl = destinationUrl {
                guard FileManager().fileExists(atPath: destinationUrl.path) else { return }
                do {
                    try FileManager().removeItem(atPath: destinationUrl.path)
                    notice.isDownloaded = false
                    try? context.save()
                } catch let error {
                    print("Error while deleting file: ", error)
                }
            }
        }
    }

    func checkFileExists(odsEntryId: Int) -> Bool {
        return context.performAndWait {
            guard let notice = try? context.fetchFirst(
                DataType.self,
                predicate: NSPredicate(format: "odsEntryId == %i", argumentArray: [odsEntryId])) else {
                return false
            }
            var downloaded = false
            if let destinationUrl = URL(string: notice.savePath) {
                downloaded = FileManager().fileExists(atPath: destinationUrl.path)
            }
            if downloaded != notice.isDownloaded {
                notice.isDownloaded = downloaded
                try? context.save()
            }
            return downloaded
        }
    }

    func observeNoticeToMariners(
        odsEntryId: Int
    ) -> AnyPublisher<NoticeToMarinersModel, Never>? {
        return context.performAndWait {
            guard let notice = try? context.fetchFirst(
                DataType.self,
                predicate: NSPredicate(format: "odsEntryId == %i", argumentArray: [odsEntryId])) else {
                return nil
            }
            return publisher(for: notice, in: context)
                .map({ notice in
                    return NoticeToMarinersModel(noticeToMariners: notice)
                })
                .eraseToAnyPublisher()
        }
    }
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
        let userSort = UserDefaults.standard.sort(DataSources.noticeToMariners.key)
        let sortDescriptors: [DataSourceSortParameter] =
        userSort.isEmpty ? DataSources.noticeToMariners.defaultSort : userSort

        request.sortDescriptors = sortDescriptors.map({ sortParameter in
            sortParameter.toNSSortDescriptor()
        })
        var previousHeader: String? = currentHeader
        var list: [Item] = []
        context.performAndWait {
            if let fetched = context.fetch(request: request) {

                list = fetched.flatMap { item in
                    guard let sortDescriptor = sortDescriptors.first else {
                        return [Item.listItem(ListModelType(noticeToMariners: item))]
                    }

                    if !sortDescriptor.section {
                        return [Item.listItem(ListModelType(noticeToMariners: item))]
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
                    Item.listItem(ListModelType(noticeToMariners: item))
                ]
            }
        } else if previousHeader == nil, let sortValueString = sortValueString {
            previousHeader = sortValueString
            return [
                Item.sectionHeader(header: sortValueString),
                Item.listItem(ListModelType(noticeToMariners: item))
            ]
        }

        return [Item.listItem(ListModelType(noticeToMariners: item))]
    }

    // ignore due to the amount of data types
    // swiftlint:disable cyclomatic_complexity
    func getCurrentSortValue(sortDescriptor: DataSourceSortParameter, sortValue: Any?) -> String? {
        if sortDescriptor.property.key == #keyPath(NoticeToMariners.noticeNumber), let sortValue = sortValue as? Int {
            return "\(Int(sortValue / 100))"
        }
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

// MARK: section header publishers
extension NoticeToMarinersCoreDataDataSource {

    func sectionHeaders(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<[NoticeToMarinersItem], Error> {
        return sectionHeaders(filters: filters, at: nil, currentHeader: nil, paginatedBy: paginator)
            .map(\.list)
            .eraseToAnyPublisher()
    }

    func sectionHeaders(
        filters: [DataSourceFilterParameter]?,
        at page: Page?,
        currentHeader: String?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<ModelPage, Error> {
        return sectionHeaders(filters: filters, at: page, currentHeader: currentHeader)
            .map { result -> AnyPublisher<ModelPage, Error> in
                if let paginator = paginator, let next = result.next {
                    return self.sectionHeaders(
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

    func sectionHeaders(
        filters: [DataSourceFilterParameter]?,
        at page: Page?,
        currentHeader: String?
    ) -> AnyPublisher<ModelPage, Error> {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "NoticeToMariners")
        let predicates: [NSPredicate] = buildPredicates(filters: filters)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.predicate = predicate
        request.resultType = .dictionaryResultType
        request.fetchLimit = 100
        request.fetchOffset = (page ?? 0) * request.fetchLimit
        request.returnsDistinctResults = true

        let sectionHeaderSort: [DataSourceSortParameter] = [
            DataSourceSortParameter(
                property: DataSourceProperty(
                    name: "Notice Number",
                    key: #keyPath(NoticeToMariners.noticeNumber),
                    type: .int),
                ascending: false,
                section: true)
        ]

        let sortDescriptors: [DataSourceSortParameter] = sectionHeaderSort

        request.propertiesToFetch = [sortDescriptors[0].property.key]

        request.sortDescriptors = [sortDescriptors[0].toNSSortDescriptor()]
        var notices: [NoticeToMarinersItem] = []

        var previousHeader: String? = currentHeader

        context.performAndWait {
            if let res = try? context.fetch(request) as? [[String: Any]] {
                notices = res.flatMap {

                    let noticeSectionHeader = "\(($0["noticeNumber"] as? Int ?? -1) / 100)"
                    if previousHeader != noticeSectionHeader {
                        previousHeader = noticeSectionHeader
                        return [
                            NoticeToMarinersItem.sectionHeader(header: noticeSectionHeader),
                            NoticeToMarinersItem.week(noticeNumber: $0["noticeNumber"] as? Int ?? -1)
                        ]
                    }
                    return [NoticeToMarinersItem.week(noticeNumber: $0["noticeNumber"] as? Int ?? -1)]
                }
            }
        }

        let noticePage: ModelPage = ModelPage(
            list: notices,
            next: (page ?? 0) + 1,
            currentHeader: previousHeader
        )

        return Just(noticePage)
            .setFailureType(to: Error.self)
            .receive(on: DispatchQueue.main)
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
