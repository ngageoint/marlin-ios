//
//  PublicationLocalDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 2/1/24.
//

import Foundation
import CoreData
import Combine
import UIKit
import BackgroundTasks

private struct PublicationLocalDataSourceProviderKey: InjectionKey {
    static var currentValue: PublicationLocalDataSource = PublicationCoreDataDataSource()
}

extension InjectedValues {
    var publicationLocalDataSource: PublicationLocalDataSource {
        get { Self[PublicationLocalDataSourceProviderKey.self] }
        set { Self[PublicationLocalDataSourceProviderKey.self] = newValue }
    }
}

protocol PublicationLocalDataSource {
    func getPublication(s3Key: String?) -> PublicationModel?
    func getSections(filters: [DataSourceFilterParameter]?) async -> [PublicationItem]?
    func getPublications(typeId: Int) async -> [PublicationModel]
    func getCount(filters: [DataSourceFilterParameter]?) -> Int
    func observePublication(
        s3Key: String
    ) -> AnyPublisher<PublicationModel, Never>?
    func checkFileExists(s3Key: String) -> Bool
    func deleteFile(s3Key: String)
    func updateProgress(s3Key: String, progress: DownloadProgress)
    func pubs(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<[PublicationItem], Error>
    func sectionHeaders(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<[PublicationItem], Error>
    func insert(task: BGTask?, epubs: [PublicationModel]) async -> Int
    func batchImport(from propertiesList: [PublicationModel]) async throws -> Int
}

struct PublicationModelPage {
    var pubList: [PublicationItem]
    var next: Int?
    var currentHeader: String?
}

class PublicationCoreDataDataSource: 
    CoreDataDataSource,
    PublicationLocalDataSource,
    ObservableObject {
    lazy var context: NSManagedObjectContext = {
        PersistenceController.current.newTaskContext()
    }()

    func getPublication(s3Key: String?) -> PublicationModel? {
        return context.performAndWait {
            if let s3Key = s3Key,
               let epub = context.fetchFirst(ElectronicPublication.self, key: "s3Key", value: s3Key) {
                return PublicationModel(epub: epub)
            }
            return nil
        }
    }

    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        let fetchRequest = ElectronicPublication.fetchRequest()
        let predicates: [NSPredicate] = buildPredicates(filters: filters)

        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.predicate = predicate

        fetchRequest.sortDescriptors = UserDefaults.standard.sort(DataSources.epub.key).toNSSortDescriptors()

        return context.performAndWait {
            (try? context.count(for: fetchRequest)) ?? 0
        }
    }

    func getPublications(typeId: Int) async -> [PublicationModel] {
        let filters: [DataSourceFilterParameter] = [
            DataSourceFilterParameter(
                property: DataSourceProperty(
                    name: "Type",
                    key: #keyPath(ElectronicPublication.pubTypeId),
                    type: .int
                ),
                comparison: .equals,
                valueInt: typeId
            )
        ]

        let fetchRequest = ElectronicPublication.fetchRequest()
        let predicates: [NSPredicate] = buildPredicates(filters: filters)

        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.predicate = predicate

        fetchRequest.sortDescriptors = UserDefaults.standard.sort(DataSources.epub.key).toNSSortDescriptors()

        let context = PersistenceController.current.newTaskContext()
        return await context.perform {
            return context.fetch(request: fetchRequest)?
                .compactMap({ pub in
                    PublicationModel(epub: pub)
                }) ?? []
        }
    }

    func getSections(filters: [DataSourceFilterParameter]?) async -> [PublicationItem]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ElectronicPublication")
        let predicates: [NSPredicate] = buildPredicates(filters: filters)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.predicate = predicate

        let sectionHeaderSort: [DataSourceSortParameter] = [
            DataSourceSortParameter(
                property: DataSourceProperty(
                    name: "Type",
                    key: #keyPath(ElectronicPublication.pubTypeId),
                    type: .int),
                ascending: true,
                section: true)
        ]

        let sortDescriptors: [DataSourceSortParameter] = sectionHeaderSort

        let keypathExp = NSExpression(forKeyPath: sortDescriptors[0].property.key)
        let expression = NSExpression(forFunction: "count:", arguments: [keypathExp])
        let countDesc = NSExpressionDescription()

        countDesc.expression = expression
        countDesc.name = "count"
        countDesc.expressionResultType = .integer64AttributeType

        request.propertiesToGroupBy = [sortDescriptors[0].property.key]
        request.propertiesToFetch = [sortDescriptors[0].property.key, countDesc]
        request.resultType = .dictionaryResultType
        request.sortDescriptors = [sortDescriptors[0].toNSSortDescriptor()]
        let context = PersistenceController.current.newTaskContext()

        return await context.perform {
            if let res = try? context.fetch(request) as? [[String: Any]] {
                struct PubTypeCount {
                    var pubType: PublicationTypeEnum
                    var count: Int
                }

                return res.compactMap({ result in
                    if let id = result["pubTypeId"] as? Int,
                       let pubType = PublicationTypeEnum(rawValue: id) {
                        return PubTypeCount(pubType: pubType, count: result["count"] as? Int ?? 0)
                    }
                    return nil
                })
                .sorted(by: { pubTypeCount1, pubTypeCount2 in
                    pubTypeCount1.pubType.description < pubTypeCount2.pubType.description
                })
                .compactMap { pubTypeCount in
                    PublicationItem.pubType(type: pubTypeCount.pubType, count: pubTypeCount.count)
                }
            }
            return nil
        }

    }
}

// MARK: epub publishers
extension PublicationCoreDataDataSource {

    func updateProgress(s3Key: String, progress: DownloadProgress) {
        return context.performAndWait {
            guard let epub = context.fetchFirst(ElectronicPublication.self, key: "s3Key", value: s3Key) else {
                return
            }
            epub.isDownloading = progress.isDownloading
            epub.isDownloaded = progress.isDownloaded
            epub.downloadProgress = progress.downloadProgress
            epub.error = progress.error
            try? context.save()
        }
    }

    func deleteFile(s3Key: String) {
        return context.performAndWait {
            guard let epub = context.fetchFirst(ElectronicPublication.self, key: "s3Key", value: s3Key) else {
                return
            }
            let docsUrl = URL.documentsDirectory
            let fileUrl = "\(docsUrl.absoluteString)\(s3Key)"
            let destinationUrl = URL(string: fileUrl)

            if let destinationUrl = destinationUrl {
                guard FileManager().fileExists(atPath: destinationUrl.path) else { return }
                do {
                    try FileManager().removeItem(atPath: destinationUrl.path)
                    epub.isDownloaded = false
                    try? context.save()
                } catch let error {
                    print("Error while deleting file: ", error)
                }
            }
        }
    }

    func checkFileExists(s3Key: String) -> Bool {
        print("XXX check file exists in publication core data source")
        return context.performAndWait {
            guard let epub = context.fetchFirst(ElectronicPublication.self, key: "s3Key", value: s3Key) else {
                print("XXX no publication")
                return false
            }
            var downloaded = false
            if let destinationUrl = URL(string: epub.savePath) {
                downloaded = FileManager().fileExists(atPath: destinationUrl.path)
                print("XXX file exists \(downloaded)")
            }
            if downloaded != epub.isDownloaded {
                epub.isDownloaded = downloaded
                try? context.save()
            }
            return downloaded
        }
    }

    func observePublication(
        s3Key: String
    ) -> AnyPublisher<PublicationModel, Never>? {
        return context.performAndWait {
            let epub = context.fetchFirst(ElectronicPublication.self, key: "s3Key", value: s3Key)

            if let epub = epub {
                return publisher(for: epub, in: context)
                    .map({ epub in
                        return PublicationModel(epub: epub)
                    })
                    .eraseToAnyPublisher()
            }
            return nil
        }
    }

    func pubs(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<[PublicationItem], Error> {
        return epubs(filters: filters, at: nil, currentHeader: nil, paginatedBy: paginator)
            .map(\.pubList)
            .eraseToAnyPublisher()
    }

    func epubs(
        filters: [DataSourceFilterParameter]?,
        at page: Page?,
        currentHeader: String?
    ) -> AnyPublisher<PublicationModelPage, Error> {

        let request = ElectronicPublication.fetchRequest()
        let predicates: [NSPredicate] = buildPredicates(filters: filters)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.predicate = predicate

        request.fetchLimit = 100
        request.fetchOffset = (page ?? 0) * request.fetchLimit
        let userSort = UserDefaults.standard.sort(DataSources.epub.key)
        let sortDescriptors: [DataSourceSortParameter] =
        userSort.isEmpty ? DataSources.epub.defaultSort : userSort

        request.sortDescriptors = sortDescriptors.map({ sortParameter in
            sortParameter.toNSSortDescriptor()
        })
        var previousHeader: String? = currentHeader
        var epubs: [PublicationItem] = []
        context.performAndWait {
            if let fetched = context.fetch(request: request) {

                epubs = fetched.flatMap { epub in
                    guard let sortDescriptor = sortDescriptors.first else {
                        return [PublicationItem.listItem(PublicationListModel(epub: epub))]
                    }

                    if !sortDescriptor.section {
                        return [PublicationItem.listItem(PublicationListModel(epub: epub))]
                    }

                    return createSectionHeaderAndListItem(
                        epub: epub,
                        sortDescriptor: sortDescriptor,
                        previousHeader: &previousHeader
                    )
                }
            }
        }

        let epubPage: PublicationModelPage = PublicationModelPage(
            pubList: epubs, next: (page ?? 0) + 1,
            currentHeader: previousHeader
        )

        return Just(epubPage)
            .setFailureType(to: Error.self)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func createSectionHeaderAndListItem(
        epub: ElectronicPublication,
        sortDescriptor: DataSourceSortParameter,
        previousHeader: inout String?
    ) -> [PublicationItem] {
        let currentValue = epub.value(forKey: sortDescriptor.property.key)
        let sortValueString: String? = getCurrentSortValue(sortDescriptor: sortDescriptor, sortValue: currentValue)

        if let previous = previousHeader, let sortValueString = sortValueString {
            if previous != sortValueString {
                previousHeader = sortValueString
                return [
                    PublicationItem.sectionHeader(header: sortValueString),
                    PublicationItem.listItem(PublicationListModel(epub: epub))
                ]
            }
        } else if previousHeader == nil, let sortValueString = sortValueString {
            previousHeader = sortValueString
            return [
                PublicationItem.sectionHeader(header: sortValueString),
                PublicationItem.listItem(PublicationListModel(epub: epub))
            ]
        }

        return [PublicationItem.listItem(PublicationListModel(epub: epub))]
    }

    func getCurrentSortValue(sortDescriptor: DataSourceSortParameter, sortValue: Any?) -> String? {
        var sortValueString: String?
        switch sortDescriptor.property.type {
        case .string:
            sortValueString = sortValue as? String
        case .date:
            if let currentValue = sortValue as? Date {
                sortValueString = DataSources.epub.dateFormatter.string(from: currentValue)
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

    func epubs(
        filters: [DataSourceFilterParameter]?,
        at page: Page?,
        currentHeader: String?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<PublicationModelPage, Error> {
        return epubs(filters: filters, at: page, currentHeader: currentHeader)
            .map { result -> AnyPublisher<PublicationModelPage, Error> in
                if let paginator = paginator, let next = result.next {
                    return self.epubs(
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
extension PublicationCoreDataDataSource {

    func sectionHeaders(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<[PublicationItem], Error> {
        return sectionHeaders(filters: filters, at: nil, currentHeader: nil, paginatedBy: paginator)
            .map(\.pubList)
            .eraseToAnyPublisher()
    }

    func sectionHeaders(
        filters: [DataSourceFilterParameter]?,
        at page: Page?,
        currentHeader: String?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<PublicationModelPage, Error> {
        return sectionHeaders(filters: filters, at: page, currentHeader: currentHeader)
            .map { result -> AnyPublisher<PublicationModelPage, Error> in
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
    ) -> AnyPublisher<PublicationModelPage, Error> {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ElectronicPublication")
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
                    name: "Type",
                    key: #keyPath(ElectronicPublication.pubTypeId),
                    type: .int),
                ascending: true,
                section: true)
        ]

        let sortDescriptors: [DataSourceSortParameter] = sectionHeaderSort

        request.propertiesToFetch = [sortDescriptors[0].property.key]

        request.sortDescriptors = [sortDescriptors[0].toNSSortDescriptor()]
        var epubs: [PublicationItem] = []
        let context = PersistenceController.current.newTaskContext()
        context.performAndWait {
            if let res = try? context.fetch(request) as? [[String: Any]] {
                epubs = res.compactMap {
                    PublicationTypeEnum(rawValue: $0["pubTypeId"] as? Int ?? -1)
                }
                .sorted(by: { section1, section2 in
                    section1.description < section2.description
                })
                .compactMap {
                    PublicationItem.pubType(type: $0, count: 0)
                }
            }
        }

        let epubPage: PublicationModelPage = PublicationModelPage(
            pubList: epubs, next: (page ?? 0) + 1,
            currentHeader: ""
        )

        return Just(epubPage)
            .setFailureType(to: Error.self)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: Import methods
extension PublicationCoreDataDataSource {

    func insert(task: BGTask? = nil, epubs: [PublicationModel]) async -> Int {
        let count = epubs.count
        NSLog("Received \(count) \(DataSources.epub.key) records.")

        // Create an operation that performs the main part of the background task.
        let operation = PublicationDataLoadOperation(epubs: epubs)

        return await executeOperationInBackground(operation: operation)
    }

    func batchImport(from propertiesList: [PublicationModel]) async throws -> Int {
        guard !propertiesList.isEmpty else { return 0 }
        let taskContext = PersistenceController.current.newTaskContext()
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importEpubs"

        let count = try await taskContext.perform {
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = self.newBatchInsertRequest(with: propertiesList)
            batchInsertRequest.resultType = .objectIDs
            if let fetchResult = try? taskContext.execute(batchInsertRequest),
               let batchInsertResult = fetchResult as? NSBatchInsertResult {
                if let objectIds = batchInsertResult.result as? [NSManagedObjectID] {
                    if objectIds.count > 0 {
                        NSLog("Inserted \(objectIds.count) EPUB records")
                        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ElectronicPublication")
                        fetch.predicate = NSPredicate(format: "NOT (self IN %@)", objectIds)
                        let request = NSBatchDeleteRequest(fetchRequest: fetch)
                        request.resultType = .resultTypeCount
                        if let deleteResult = try? taskContext.execute(request),
                           let batchDeleteResult = deleteResult as? NSBatchDeleteResult {
                            if let count = batchDeleteResult.result as? Int {
                                NSLog("Deleted \(count) old records")
                            }
                        }
                        try? taskContext.save()
                        return objectIds.count
                    } else {
                        NSLog("No new EPUB records")
                    }
                }
                try? taskContext.save()
                return 0
            }
            throw MSIError.batchInsertError
        }
        return count
    }

    func newBatchInsertRequest(with propertyList: [PublicationModel]) -> NSBatchInsertRequest {
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
