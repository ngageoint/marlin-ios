//
//  RadioBeaconLocalDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 1/31/24.
//

import Foundation
import CoreData
import Combine
import UIKit
import BackgroundTasks

protocol RadioBeaconLocalDataSource {
    func getNewestRadioBeacon() -> RadioBeaconModel?

    func getRadioBeacon(featureNumber: Int?, volumeNumber: String?) -> RadioBeaconModel?
    func getRadioBeaconsInBounds(
        filters: [DataSourceFilterParameter]?,
        minLatitude: Double?,
        maxLatitude: Double?,
        minLongitude: Double?,
        maxLongitude: Double?
    ) -> [RadioBeaconModel]
    func radioBeacons(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<[RadioBeaconItem], Error>
    func getCount(filters: [DataSourceFilterParameter]?) -> Int
    func insert(task: BGTask?, radioBeacons: [RadioBeaconModel]) async -> Int
    func batchImport(from propertiesList: [RadioBeaconModel]) async throws -> Int
}

struct RadioBeaconModelPage {
    var list: [RadioBeaconItem]
    var next: Int?
    var currentHeader: String?
}

class RadioBeaconCoreDataDataSource: CoreDataDataSource, RadioBeaconLocalDataSource, ObservableObject {
    private lazy var context: NSManagedObjectContext = {
        PersistenceController.current.newTaskContext()
    }()

    func getNewestRadioBeacon() -> RadioBeaconModel? {
        var model: RadioBeaconModel?
        context.performAndWait {
            if let newestRadioBeacon = try? context.fetchFirst(
                RadioBeacon.self,
                sortBy: [NSSortDescriptor(keyPath: \RadioBeacon.noticeNumber, ascending: false)],
                predicate: nil) {
                model = RadioBeaconModel(radioBeacon: newestRadioBeacon)
            }
        }

        return model
    }

    func getRadioBeacon(featureNumber: Int?, volumeNumber: String?) -> RadioBeaconModel? {
        return context.performAndWait {
            if let featureNumber = featureNumber, let volumeNumber = volumeNumber {
                if let radioBeacon = try? context.fetchFirst(
                    RadioBeacon.self,
                    predicate: NSPredicate(
                        format: "featureNumber = %ld AND volumeNumber = %@",
                        argumentArray: [featureNumber, volumeNumber])
                ) {
                    return RadioBeaconModel(radioBeacon: radioBeacon)
                }
            }
            return nil
        }
    }

    func getRadioBeaconsInBounds(
        filters: [DataSourceFilterParameter]?,
        minLatitude: Double?,
        maxLatitude: Double?,
        minLongitude: Double?,
        maxLongitude: Double?
    ) -> [RadioBeaconModel] {
        var radioBeacons: [RadioBeaconModel] = []
        // TODO: this should probably execute on a different context and be a perform
        context.performAndWait {
            let fetchRequest = RadioBeacon.fetchRequest()
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

            fetchRequest.sortDescriptors = UserDefaults.standard.sort(DataSources.radioBeacon.key).map({ sortParameter in
                sortParameter.toNSSortDescriptor()
            })
            radioBeacons = (context.fetch(request: fetchRequest)?.map { radioBeacon in
                RadioBeaconModel(radioBeacon: radioBeacon)
            }) ?? []
        }

        return radioBeacons
    }

    typealias Page = Int

    func radioBeacons(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<[RadioBeaconItem], Error> {
        return radioBeacons(filters: filters, at: nil, currentHeader: nil, paginatedBy: paginator)
            .map(\.list)
            .eraseToAnyPublisher()
    }

    func radioBeacons(
        filters: [DataSourceFilterParameter]?,
        at page: Page?, currentHeader: String?
    ) -> AnyPublisher<RadioBeaconModelPage, Error> {

        let request = RadioBeacon.fetchRequest()
        let predicates: [NSPredicate] = buildPredicates(filters: filters)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.predicate = predicate

        request.fetchLimit = 100
        request.fetchOffset = (page ?? 0) * request.fetchLimit
        let userSort = UserDefaults.standard.sort(DataSources.radioBeacon.key)
        let sortDescriptors: [DataSourceSortParameter] =
        userSort.isEmpty ? DataSources.radioBeacon.defaultSort : userSort

        request.sortDescriptors = sortDescriptors.map({ sortParameter in
            sortParameter.toNSSortDescriptor()
        })
        var previousHeader: String? = currentHeader
        var radioBeacons: [RadioBeaconItem] = []
        context.performAndWait {
            if let fetched = context.fetch(request: request) {

                radioBeacons = fetched.flatMap { radioBeacon in
                    guard let sortDescriptor = sortDescriptors.first else {
                        return [RadioBeaconItem.listItem(RadioBeaconListModel(radioBeacon: radioBeacon))]
                    }

                    if !sortDescriptor.section {
                        return [RadioBeaconItem.listItem(RadioBeaconListModel(radioBeacon: radioBeacon))]
                    }

                    return createSectionHeaderAndListItem(
                        radioBeacon: radioBeacon,
                        sortDescriptor: sortDescriptor,
                        previousHeader: &previousHeader
                    )
                }
            }
        }

        let radioBeaconPage: RadioBeaconModelPage = RadioBeaconModelPage(
            list: radioBeacons, next: (page ?? 0) + 1,
            currentHeader: previousHeader
        )

        return Just(radioBeaconPage)
            .setFailureType(to: Error.self)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func createSectionHeaderAndListItem(
        radioBeacon: RadioBeacon,
        sortDescriptor: DataSourceSortParameter,
        previousHeader: inout String?
    ) -> [RadioBeaconItem] {
        let currentValue = radioBeacon.value(forKey: sortDescriptor.property.key)
        let sortValueString: String? = getCurrentSortValue(sortDescriptor: sortDescriptor, sortValue: currentValue)

        if let previous = previousHeader, let sortValueString = sortValueString {
            if previous != sortValueString {
                previousHeader = sortValueString
                return [
                    RadioBeaconItem.sectionHeader(header: sortValueString),
                    RadioBeaconItem.listItem(RadioBeaconListModel(radioBeacon: radioBeacon))
                ]
            }
        } else if previousHeader == nil, let sortValueString = sortValueString {
            previousHeader = sortValueString
            return [
                RadioBeaconItem.sectionHeader(header: sortValueString),
                RadioBeaconItem.listItem(RadioBeaconListModel(radioBeacon: radioBeacon))
            ]
        }

        return [RadioBeaconItem.listItem(RadioBeaconListModel(radioBeacon: radioBeacon))]
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
                sortValueString = DataSources.radioBeacon.dateFormatter.string(from: currentValue)
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

    func radioBeacons(
        filters: [DataSourceFilterParameter]?,
        at page: Page?,
        currentHeader: String?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<RadioBeaconModelPage, Error> {
        return radioBeacons(filters: filters, at: page, currentHeader: currentHeader)
            .map { result -> AnyPublisher<RadioBeaconModelPage, Error> in
                if let paginator = paginator, let next = result.next {
                    return self.radioBeacons(
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

    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        let fetchRequest = RadioBeacon.fetchRequest()
        let predicates: [NSPredicate] = buildPredicates(filters: filters)

        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.predicate = predicate

        fetchRequest.sortDescriptors = UserDefaults.standard.sort(DataSources.radioBeacon.key).map({ sortParameter in
            sortParameter.toNSSortDescriptor()
        })

        var count = 0
        context.performAndWait {
            count = (try? context.count(for: fetchRequest)) ?? 0
        }
        return count
    }

    func insert(task: BGTask?, radioBeacons: [RadioBeaconModel]) async -> Int {
        let count = radioBeacons.count
        NSLog("Received \(count) \(DataSources.radioBeacon.key) records.")

        // Create an operation that performs the main part of the background task.
        operation = RadioBeaconDataLoadOperation(radioBeacons: radioBeacons, localDataSource: self)

        return await executeOperationInBackground(task: task)
    }

    func batchImport(from propertiesList: [RadioBeaconModel]) async throws -> Int {
        guard !propertiesList.isEmpty else { return 0 }
        let taskContext = PersistenceController.current.newTaskContext()
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importRadioBeacons"

        let count = try await taskContext.perform {
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = self.newBatchInsertRequest(with: propertiesList)
            batchInsertRequest.resultType = .count
            if let fetchResult = try? taskContext.execute(batchInsertRequest),
               let batchInsertResult = fetchResult as? NSBatchInsertResult {
                try? taskContext.save()
                if let count = batchInsertResult.result as? Int, count > 0 {
                    NSLog("Inserted \(count) Radio Beacon records")
                    return count
                } else {
                    NSLog("No new radio beacon records")
                }
                return 0
            }
            throw MSIError.batchInsertError
        }
        return count
    }

    func newBatchInsertRequest(with propertyList: [RadioBeaconModel]) -> NSBatchInsertRequest {
        var index = 0
        let total = propertyList.count

        // Provide one dictionary at a time when the closure is called.
        let batchInsertRequest = NSBatchInsertRequest(entity: RadioBeacon.entity(), dictionaryHandler: { dictionary in
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
