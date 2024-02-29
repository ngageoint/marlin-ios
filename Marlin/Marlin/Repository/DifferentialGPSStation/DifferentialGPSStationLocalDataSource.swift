//
//  DifferentialGPSStationLocalDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 2/1/24.
//

import Foundation
import CoreData
import Combine
import UIKit
import BackgroundTasks

protocol DifferentialGPSStationLocalDataSource {
    func getNewestDifferentialGPSStation() -> DifferentialGPSStationModel?
    func getDifferentialGPSStation(featureNumber: Int?, volumeNumber: String?) -> DifferentialGPSStationModel?
    func getDifferentialGPSStationsInBounds(
        filters: [DataSourceFilterParameter]?,
        minLatitude: Double?,
        maxLatitude: Double?,
        minLongitude: Double?,
        maxLongitude: Double?
    ) async -> [DifferentialGPSStationModel]

    func dgps(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<[DifferentialGPSStationItem], Error>
    func getDifferentialGPSStations(
        filters: [DataSourceFilterParameter]?
    ) async -> [DifferentialGPSStationModel]

    func getCount(filters: [DataSourceFilterParameter]?) -> Int
    func insert(task: BGTask?, dgpss: [DifferentialGPSStationModel]) async -> Int
    func batchImport(from propertiesList: [DifferentialGPSStationModel]) async throws -> Int
}

class DifferentialGPSStationCoreDataDataSource: 
    CoreDataDataSource,
    DifferentialGPSStationLocalDataSource,
    ObservableObject {
    private lazy var context: NSManagedObjectContext = {
        PersistenceController.current.newTaskContext()
    }()

    func getNewestDifferentialGPSStation() -> DifferentialGPSStationModel? {
        var model: DifferentialGPSStationModel?
        context.performAndWait {
            if let newestDifferentialGPSStation =
                try? PersistenceController.current.fetchFirst(
                    DifferentialGPSStation.self,
                    sortBy: [
                        NSSortDescriptor(keyPath: \DifferentialGPSStation.noticeNumber, ascending: false)
                    ],
                    predicate: nil,
                    context: context) {
                model = DifferentialGPSStationModel(differentialGPSStation: newestDifferentialGPSStation)
            }
        }
        return model
    }

    func getDifferentialGPSStation(featureNumber: Int?, volumeNumber: String?) -> DifferentialGPSStationModel? {
        guard let featureNumber = featureNumber, let volumeNumber = volumeNumber else {
            return nil
        }
        return context.performAndWait {
            if let dgps = try? context.fetchFirst(
                DifferentialGPSStation.self,
                predicate: NSPredicate(
                    format: "featureNumber = %ld AND volumeNumber = %@",
                    argumentArray: [featureNumber, volumeNumber])) {
                return DifferentialGPSStationModel(differentialGPSStation: dgps)
            }
            return nil
        }
    }

    func getDifferentialGPSStationsInBounds(
        filters: [DataSourceFilterParameter]?,
        minLatitude: Double?,
        maxLatitude: Double?,
        minLongitude: Double?,
        maxLongitude: Double?
    ) async -> [DifferentialGPSStationModel] {
        let context = PersistenceController.current.newTaskContext()

        return await context.perform {
            let fetchRequest = DifferentialGPSStation.fetchRequest()
            var predicates: [NSPredicate] = self.buildPredicates(filters: filters)

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

            fetchRequest.sortDescriptors = UserDefaults.standard.sort(DataSources.dgps.key).map({ sortParameter in
                sortParameter.toNSSortDescriptor()
            })
            return (context.fetch(request: fetchRequest)?.map { dgps in
                DifferentialGPSStationModel(differentialGPSStation: dgps)
            }) ?? []
        }
    }

    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        let fetchRequest = DifferentialGPSStation.fetchRequest()
        let predicates: [NSPredicate] = buildPredicates(filters: filters)

        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.predicate = predicate

        fetchRequest.sortDescriptors = UserDefaults.standard.sort(DataSources.dgps.key).map({ sortParameter in
            sortParameter.toNSSortDescriptor()
        })

        var count = 0
        context.performAndWait {
            count = (try? context.count(for: fetchRequest)) ?? 0
        }
        return count
    }

    func getDifferentialGPSStations(
        filters: [DataSourceFilterParameter]?
    ) async -> [DifferentialGPSStationModel] {
        return await context.perform {
            let fetchRequest = DifferentialGPSStation.fetchRequest()
            let predicates: [NSPredicate] = self.buildPredicates(filters: filters)

            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            fetchRequest.predicate = predicate

            fetchRequest.sortDescriptors = UserDefaults.standard.sort(DataSources.dgps.key).map({ sortParameter in
                sortParameter.toNSSortDescriptor()
            })
            return (self.context.fetch(request: fetchRequest)?.map { dgps in
                DifferentialGPSStationModel(differentialGPSStation: dgps)
            }) ?? []
        }
    }

}

// MARK: Data Publisher methods
extension DifferentialGPSStationCoreDataDataSource {

    typealias DataType = DifferentialGPSStation
    typealias ModelType = DifferentialGPSStationModel
    typealias Item = DifferentialGPSStationItem

    struct ModelPage {
        var list: [Item]
        var next: Int?
        var currentHeader: String?
    }

    func dgps(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<[Item], Error> {
        return models(filters: filters, at: nil, currentHeader: nil, paginatedBy: paginator)
            .map(\.list)
            .eraseToAnyPublisher()
    }

    func models(
        filters: [DataSourceFilterParameter]?,
        at page: Page?, currentHeader: String?
    ) -> AnyPublisher<ModelPage, Error> {

        let request = DataType.fetchRequest()
        let predicates: [NSPredicate] = buildPredicates(filters: filters)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.predicate = predicate

        request.fetchLimit = 100
        request.fetchOffset = (page ?? 0) * request.fetchLimit
        let userSort = UserDefaults.standard.sort(DataSources.dgps.key)
        let sortDescriptors: [DataSourceSortParameter] =
        userSort.isEmpty ? DataSources.dgps.defaultSort : userSort

        request.sortDescriptors = sortDescriptors.map({ sortParameter in
            sortParameter.toNSSortDescriptor()
        })
        var previousHeader: String? = currentHeader
        var dgpss: [Item] = []
        context.performAndWait {
            if let fetched = context.fetch(request: request) {

                dgpss = fetched.flatMap { dgps in
                    guard let sortDescriptor = sortDescriptors.first else {
                        return [Item.listItem(ModelType(differentialGPSStation: dgps))]
                    }

                    if !sortDescriptor.section {
                        return [Item.listItem(ModelType(differentialGPSStation: dgps))]
                    }

                    return createSectionHeaderAndListItem(
                        dgps: dgps,
                        sortDescriptor: sortDescriptor,
                        previousHeader: &previousHeader
                    )
                }
            }
        }

        let dgpsPage: ModelPage = ModelPage(
            list: dgpss, next: (page ?? 0) + 1,
            currentHeader: previousHeader
        )

        return Just(dgpsPage)
            .setFailureType(to: Error.self)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func createSectionHeaderAndListItem(
        dgps: DataType,
        sortDescriptor: DataSourceSortParameter,
        previousHeader: inout String?
    ) -> [DifferentialGPSStationItem] {
        let currentValue = dgps.value(forKey: sortDescriptor.property.key)
        let sortValueString: String? = getCurrentSortValue(sortDescriptor: sortDescriptor, sortValue: currentValue)

        if let previous = previousHeader, let sortValueString = sortValueString {
            if previous != sortValueString {
                previousHeader = sortValueString
                return [
                    Item.sectionHeader(header: sortValueString),
                    Item.listItem(ModelType(differentialGPSStation: dgps))
                ]
            }
        } else if previousHeader == nil, let sortValueString = sortValueString {
            previousHeader = sortValueString
            return [
                Item.sectionHeader(header: sortValueString),
                Item.listItem(ModelType(differentialGPSStation: dgps))
            ]
        }

        return [Item.listItem(ModelType(differentialGPSStation: dgps))]
    }

    func getCurrentSortValue(sortDescriptor: DataSourceSortParameter, sortValue: Any?) -> String? {
        var sortValueString: String?
        switch sortDescriptor.property.type {
        case .string:
            sortValueString = sortValue as? String
        case .date:
            if let currentValue = sortValue as? Date {
                sortValueString = DataSources.dgps.dateFormatter.string(from: currentValue)
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
extension DifferentialGPSStationCoreDataDataSource {

    func insert(task: BGTask? = nil, dgpss: [DifferentialGPSStationModel]) async -> Int {
        let count = dgpss.count
        NSLog("Received \(count) \(DataSources.dgps.key) records.")

        // Create an operation that performs the main part of the background task.
        operation = DifferentialGPSStationDataLoadOperation(dgpss: dgpss, localDataSource: self)

        return await executeOperationInBackground(task: task)
    }

    func batchImport(from propertiesList: [DifferentialGPSStationModel]) async throws -> Int {
        guard !propertiesList.isEmpty else { return 0 }
        let taskContext = PersistenceController.current.newTaskContext()
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importDgps"

        let count = try await taskContext.perform {
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = self.newBatchInsertRequest(with: propertiesList)
            batchInsertRequest.resultType = .count
            if let fetchResult = try? taskContext.execute(batchInsertRequest),
               let batchInsertResult = fetchResult as? NSBatchInsertResult {
                try? taskContext.save()
                if let count = batchInsertResult.result as? Int, count > 0 {
                    NSLog("Inserted \(count) DGPS records")
                    return count
                } else {
                    NSLog("No new DGPS records")
                }
                return 0
            }
            throw MSIError.batchInsertError
        }
        return count
    }

    func newBatchInsertRequest(with propertyList: [DifferentialGPSStationModel]) -> NSBatchInsertRequest {
        var index = 0
        let total = propertyList.count

        // Provide one dictionary at a time when the closure is called.
        let batchInsertRequest = NSBatchInsertRequest(
            entity: DifferentialGPSStation.entity(),
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
