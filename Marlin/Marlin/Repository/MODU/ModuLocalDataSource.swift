//
//  ModuLocalDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 1/22/24.
//

import Foundation
import CoreData
import Combine
import UIKit
import BackgroundTasks

protocol ModuLocalDataSource {
    func insert(task: BGTask?, modus: [ModuModel]) async -> Int
    func batchImport(from propertiesList: [ModuModel]) async throws -> Int
    func getNewestModu() -> ModuModel?
    func getModus(filters: [DataSourceFilterParameter]?) -> [ModuModel]
    func getModusInBounds(
        filters: [DataSourceFilterParameter]?,
        minLatitude: Double?,
        maxLatitude: Double?,
        minLongitude: Double?,
        maxLongitude: Double?
    ) -> [ModuModel]
    func getCount(filters: [DataSourceFilterParameter]?) -> Int
    func getModu(name: String?) -> ModuModel?
    func modus(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<[ModuItem], Error>
}

struct ModuModelPage {
    var moduList: [ModuItem]
    var next: Int?
    var currentHeader: String?
}

class ModuCoreDataDataSource: CoreDataDataSource, ModuLocalDataSource, ObservableObject {
    private lazy var context: NSManagedObjectContext = {
        PersistenceController.current.newTaskContext()
    }()

    func getNewestModu() -> ModuModel? {
//        let context = PersistenceController.current.newTaskContext()
        var modu: ModuModel?
        context.performAndWait {
            if let newestModu = try? PersistenceController.current.fetchFirst(
                Modu.self,
                sortBy: [
                    NSSortDescriptor(keyPath: \Modu.date, ascending: false)
                ],
                predicate: nil,
                context: context
            ) {
                modu = ModuModel(modu: newestModu)
            }
        }
        return modu
    }

    func getModus(filters: [DataSourceFilterParameter]?) -> [ModuModel] {
        var modus: [ModuModel] = []
        context.performAndWait {
            let request: NSFetchRequest<Modu> = ModuFilterable()
                .fetchRequest(filters: filters, commonFilters: nil) as? NSFetchRequest<Modu> ?? Modu.fetchRequest()
            request.sortDescriptors = UserDefaults.standard.sort(DataSources.modu.key).map({ sortParameter in
                sortParameter.toNSSortDescriptor()
            })
            modus = (context.fetch(request: request)?.map { modu in
                ModuModel(modu: modu)
            }) ?? []
        }

        return modus
    }

    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        var count = 0
        guard let fetchRequest = ModuFilterable().fetchRequest(filters: filters, commonFilters: nil) else {
            return 0
        }
        context.performAndWait {

            count = (try? context.count(for: fetchRequest)) ?? 0
        }
        return count
    }

    func getModu(name: String?) -> ModuModel? {
        var model: ModuModel?
        context.performAndWait {
            if let name = name, let modu = context.fetchFirst(Modu.self, key: "name", value: name) {
                model = ModuModel(modu: modu)
            }
        }
        return model
    }

    typealias Page = Int

    func modus(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal? = nil
    ) -> AnyPublisher<[ModuItem], Error> {
        return modus(filters: filters, at: nil, currentHeader: nil, paginatedBy: paginator)
            .map(\.moduList)
            .eraseToAnyPublisher()
    }

    func modus(
        filters: [DataSourceFilterParameter]?,
        at page: Page?,
        currentHeader: String?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<ModuModelPage, Error> {
        return modus(filters: filters, at: page, currentHeader: currentHeader)
            .map { result -> AnyPublisher<ModuModelPage, Error> in
                if let paginator = paginator, let next = result.next {
                    return self.modus(
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

    func modus(
        filters: [DataSourceFilterParameter]?,
        at page: Page?, currentHeader: String?
    ) -> AnyPublisher<ModuModelPage, Error> {

        let request: NSFetchRequest<Modu> = ModuFilterable()
            .fetchRequest(filters: filters, commonFilters: nil) as? NSFetchRequest<Modu> ?? Modu.fetchRequest()
        request.fetchLimit = 100
        request.fetchOffset = (page ?? 0) * request.fetchLimit
        let userSort = UserDefaults.standard.sort(DataSources.modu.key)
        let sortDescriptors: [DataSourceSortParameter] = userSort.isEmpty ? DataSources.modu.defaultSort : userSort

        request.sortDescriptors = sortDescriptors.map({ sortParameter in
            sortParameter.toNSSortDescriptor()
        })
        var previousHeader: String? = currentHeader
        var modus: [ModuItem] = []
        context.performAndWait {
            if let fetched = context.fetch(request: request) {

                modus = fetched.flatMap { modu in
                    guard let sortDescriptor = sortDescriptors.first else {
                        return [ModuItem.listItem(ModuListModel(modu: modu))]
                    }

                    if !sortDescriptor.section {
                        return [ModuItem.listItem(ModuListModel(modu: modu))]
                    }

                    return createSectionHeaderAndListItem(
                        modu: modu,
                        sortDescriptor: sortDescriptor,
                        previousHeader: &previousHeader
                    )
                }
            }
        }

        let moduPage: ModuModelPage = ModuModelPage(
            moduList: modus, next: (page ?? 0) + 1,
            currentHeader: previousHeader
        )

        return Just(moduPage)
            .setFailureType(to: Error.self)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func getModusInBounds(
        filters: [DataSourceFilterParameter]?,
        minLatitude: Double?,
        maxLatitude: Double?,
        minLongitude: Double?,
        maxLongitude: Double?
    ) -> [ModuModel] {
        var modus: [ModuModel] = []
        // TODO: this should probably execute on a different context and be a perform
        context.performAndWait {
            let fetchRequest = Modu.fetchRequest()
            var predicates: [NSPredicate] = []

            if let filters = filters {
                for filter in filters {
                    let predicate = filter.toPredicate(
                        boundsPredicateBuilder: { bounds in
                            return NSPredicate(
                                format: "latitude >= %lf AND latitude <= %lf AND longitude >= %lf AND longitude <= %lf",
                                bounds.swCorner.y,
                                bounds.neCorner.y,
                                bounds.swCorner.x,
                                bounds.swCorner.y
                            )
                        })
                    if let predicate = predicate {
                        predicates.append(predicate)
                    }
                }
            }

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

            fetchRequest.sortDescriptors = UserDefaults.standard.sort(DataSources.modu.key).map({ sortParameter in
                sortParameter.toNSSortDescriptor()
            })
            modus = (context.fetch(request: fetchRequest)?.map { modu in
                ModuModel(modu: modu)
            }) ?? []
        }

        return modus
    }

    func createSectionHeaderAndListItem(
        modu: Modu,
        sortDescriptor: DataSourceSortParameter,
        previousHeader: inout String?
    ) -> [ModuItem] {
        let currentValue = modu.value(forKey: sortDescriptor.property.key)
        let sortValueString: String? = getCurrentSortValue(sortDescriptor: sortDescriptor, sortValue: currentValue)

        if let previous = previousHeader, let sortValueString = sortValueString {
            if previous != sortValueString {
                previousHeader = sortValueString
                return [
                    ModuItem.sectionHeader(header: sortValueString),
                    ModuItem.listItem(ModuListModel(modu: modu))
                ]
            }
        } else if previousHeader == nil, let sortValueString = sortValueString {
            previousHeader = sortValueString
            return [
                ModuItem.sectionHeader(header: sortValueString),
                ModuItem.listItem(ModuListModel(modu: modu))
            ]
        }

        return [ModuItem.listItem(ModuListModel(modu: modu))]
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
                sortValueString = DataSources.modu.dateFormatter.string(from: currentValue)
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

    func insert(task: BGTask? = nil, modus: [ModuModel]) async -> Int {
        let count = modus.count
        NSLog("Received \(count) \(DataSources.modu.key) records.")

        // Create an operation that performs the main part of the background task.
        operation = ModuDataLoadOperation(modus: modus, localDataSource: self)

        return await executeOperationInBackground(task: task)
    }

    func batchImport(from propertiesList: [ModuModel]) async throws -> Int {
        guard !propertiesList.isEmpty else { return 0 }
        let taskContext = PersistenceController.current.newTaskContext()
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importModus"

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
                    NSLog("Inserted \(count) MODU records")
                    return count
                } else {
                    NSLog("No new MODU records")
                }
                return 0
            }
            throw MSIError.batchInsertError
        }
        return count
    }

    func newBatchInsertRequest(with propertyList: [ModuModel]) -> NSBatchInsertRequest {
        var index = 0
        let total = propertyList.count

        // Provide one dictionary at a time when the closure is called.
        let batchInsertRequest = NSBatchInsertRequest(entity: Modu.entity(), dictionaryHandler: { dictionary in
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
