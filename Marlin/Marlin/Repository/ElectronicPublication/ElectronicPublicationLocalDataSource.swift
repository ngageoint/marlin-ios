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
    func observeElectronicPublication(
        s3Key: String
    ) -> AnyPublisher<ElectronicPublicationModel, Never>?
    func checkFileExists(s3Key: String) -> Bool
    func deleteFile(s3Key: String)
    func updateProgress(s3Key: String, progress: DownloadProgress)
    func epubs(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<[ElectronicPublicationItem], Error>
    func sectionHeaders(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<[ElectronicPublicationItem], Error>
    func insert(task: BGTask?, epubs: [ElectronicPublicationModel]) async -> Int
    func batchImport(from propertiesList: [ElectronicPublicationModel]) async throws -> Int
}

struct ElectronicPublicationModelPage {
    var epubList: [ElectronicPublicationItem]
    var next: Int?
    var currentHeader: String?
}

class ElectronicPublicationCoreDataDataSource: 
    CoreDataDataSource,
    ElectronicPublicationLocalDataSource,
    ObservableObject {
    lazy var context: NSManagedObjectContext = {
        PersistenceController.current.newTaskContext()
    }()

    func getElectronicPublication(s3Key: String?) -> ElectronicPublicationModel? {
        return context.performAndWait {
            if let s3Key = s3Key,
               let epub = context.fetchFirst(ElectronicPublication.self, key: "s3Key", value: s3Key) {
                return ElectronicPublicationModel(epub: epub)
            }
            return nil
        }
    }

    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        let fetchRequest = ElectronicPublication.fetchRequest()
        let predicates: [NSPredicate] = buildPredicates(filters: filters)

        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.predicate = predicate

        fetchRequest.sortDescriptors = UserDefaults.standard.sort(DataSources.epub.key).map({ sortParameter in
            sortParameter.toNSSortDescriptor()
        })

        return context.performAndWait {
            (try? context.count(for: fetchRequest)) ?? 0
        }
    }
}

// MARK: epub publishers
extension ElectronicPublicationCoreDataDataSource {

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
        return context.performAndWait {
            guard let epub = context.fetchFirst(ElectronicPublication.self, key: "s3Key", value: s3Key) else {
                return false
            }
            var downloaded = false
            if let destinationUrl = URL(string: epub.savePath) {
                downloaded = FileManager().fileExists(atPath: destinationUrl.path)
            }
            if downloaded != epub.isDownloaded {
                epub.isDownloaded = downloaded
                try? context.save()
            }
            return downloaded
        }
    }

    func observeElectronicPublication(
        s3Key: String
    ) -> AnyPublisher<ElectronicPublicationModel, Never>? {
        return context.performAndWait {
            let epub = context.fetchFirst(ElectronicPublication.self, key: "s3Key", value: s3Key)

            if let epub = epub {
                return publisher(for: epub, in: context)
                    .map({ epub in
                        return ElectronicPublicationModel(epub: epub)
                    })
                    .eraseToAnyPublisher()
            }
            return nil
        }
    }

    func epubs(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<[ElectronicPublicationItem], Error> {
        return epubs(filters: filters, at: nil, currentHeader: nil, paginatedBy: paginator)
            .map(\.epubList)
            .eraseToAnyPublisher()
    }

    func epubs(
        filters: [DataSourceFilterParameter]?,
        at page: Page?,
        currentHeader: String?
    ) -> AnyPublisher<ElectronicPublicationModelPage, Error> {

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
        var epubs: [ElectronicPublicationItem] = []
        context.performAndWait {
            if let fetched = context.fetch(request: request) {

                epubs = fetched.flatMap { epub in
                    guard let sortDescriptor = sortDescriptors.first else {
                        return [ElectronicPublicationItem.listItem(ElectronicPublicationListModel(epub: epub))]
                    }

                    if !sortDescriptor.section {
                        return [ElectronicPublicationItem.listItem(ElectronicPublicationListModel(epub: epub))]
                    }

                    return createSectionHeaderAndListItem(
                        epub: epub,
                        sortDescriptor: sortDescriptor,
                        previousHeader: &previousHeader
                    )
                }
            }
        }

        let epubPage: ElectronicPublicationModelPage = ElectronicPublicationModelPage(
            epubList: epubs, next: (page ?? 0) + 1,
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
    ) -> [ElectronicPublicationItem] {
        let currentValue = epub.value(forKey: sortDescriptor.property.key)
        let sortValueString: String? = getCurrentSortValue(sortDescriptor: sortDescriptor, sortValue: currentValue)

        if let previous = previousHeader, let sortValueString = sortValueString {
            if previous != sortValueString {
                previousHeader = sortValueString
                return [
                    ElectronicPublicationItem.sectionHeader(header: sortValueString),
                    ElectronicPublicationItem.listItem(ElectronicPublicationListModel(epub: epub))
                ]
            }
        } else if previousHeader == nil, let sortValueString = sortValueString {
            previousHeader = sortValueString
            return [
                ElectronicPublicationItem.sectionHeader(header: sortValueString),
                ElectronicPublicationItem.listItem(ElectronicPublicationListModel(epub: epub))
            ]
        }

        return [ElectronicPublicationItem.listItem(ElectronicPublicationListModel(epub: epub))]
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
    // swiftlint:enable cyclomatic_complexity

    func epubs(
        filters: [DataSourceFilterParameter]?,
        at page: Page?,
        currentHeader: String?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<ElectronicPublicationModelPage, Error> {
        return epubs(filters: filters, at: page, currentHeader: currentHeader)
            .map { result -> AnyPublisher<ElectronicPublicationModelPage, Error> in
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
extension ElectronicPublicationCoreDataDataSource {

    func sectionHeaders(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<[ElectronicPublicationItem], Error> {
        return sectionHeaders(filters: filters, at: nil, currentHeader: nil, paginatedBy: paginator)
            .map(\.epubList)
            .eraseToAnyPublisher()
    }

    func sectionHeaders(
        filters: [DataSourceFilterParameter]?,
        at page: Page?,
        currentHeader: String?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<ElectronicPublicationModelPage, Error> {
        return sectionHeaders(filters: filters, at: page, currentHeader: currentHeader)
            .map { result -> AnyPublisher<ElectronicPublicationModelPage, Error> in
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
    ) -> AnyPublisher<ElectronicPublicationModelPage, Error> {

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
        var epubs: [ElectronicPublicationItem] = []
        context.performAndWait {
            if let res = try? context.fetch(request) as? [[String: Any]] {
                epubs = res.compactMap {
                    ElectronicPublicationItem.sectionHeader(
                        header: "\(PublicationTypeEnum(rawValue: $0["pubTypeId"] as? Int ?? -1)?.description ?? "")")
                }
            }
        }

        let epubPage: ElectronicPublicationModelPage = ElectronicPublicationModelPage(
            epubList: epubs, next: (page ?? 0) + 1,
            currentHeader: ""
        )

        return Just(epubPage)
            .setFailureType(to: Error.self)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
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
