//
//  PortLocalDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 1/30/24.
//

import Foundation
import CoreData
import Combine
import UIKit
import BackgroundTasks

protocol PortLocalDataSource {
    func getPort(portNumber: Int64?) -> PortModel?
    func getPortsInBounds(
        filters: [DataSourceFilterParameter]?,
        minLatitude: Double?,
        maxLatitude: Double?,
        minLongitude: Double?,
        maxLongitude: Double?
    ) -> [PortModel]
    func getCount(filters: [DataSourceFilterParameter]?) -> Int
    func getPorts(
        filters: [DataSourceFilterParameter]?
    ) async -> [PortModel]
    func insert(task: BGTask?, ports: [PortModel]) async -> Int
    func batchImport(from propertiesList: [PortModel]) async throws -> Int

    func ports(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<[PortItem], Error>
}

struct PortModelPage {
    var portList: [PortItem]
    var next: Int?
    var currentHeader: String?
}

class PortCoreDataDataSource: CoreDataDataSource, PortLocalDataSource, ObservableObject {
    private lazy var context: NSManagedObjectContext = {
        PersistenceController.current.newTaskContext()
    }()
    
    func getPort(portNumber: Int64?) -> PortModel? {
        var model: PortModel?
        context.performAndWait {
            if let portNumber = portNumber {
                if let port = context.fetchFirst(Port.self, key: "portNumber", value: portNumber) {
                    model = PortModel(port: port)
                }
            }
        }
        return model
    }
    
    func getPortsInBounds(
        filters: [DataSourceFilterParameter]?,
        minLatitude: Double?,
        maxLatitude: Double?,
        minLongitude: Double?,
        maxLongitude: Double?
    ) -> [PortModel] {
        var ports: [PortModel] = []
        // TODO: this should probably execute on a different context and be a perform
        context.performAndWait {
            let fetchRequest = Port.fetchRequest()
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

            fetchRequest.sortDescriptors = UserDefaults.standard.sort(DataSources.port.key).map({ sortParameter in
                sortParameter.toNSSortDescriptor()
            })
            ports = (context.fetch(request: fetchRequest)?.map { port in
                PortModel(port: port)
            }) ?? []
        }

        return ports
    }

    func getPorts(
        filters: [DataSourceFilterParameter]?
    ) async -> [PortModel] {
        return await context.perform {
            let fetchRequest = Port.fetchRequest()
            var predicates: [NSPredicate] = self.buildPredicates(filters: filters)

            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            fetchRequest.predicate = predicate

            fetchRequest.sortDescriptors = UserDefaults.standard.sort(DataSources.port.key).map({ sortParameter in
                sortParameter.toNSSortDescriptor()
            })
            return (self.context.fetch(request: fetchRequest)?.map { port in
                PortModel(port: port)
            }) ?? []
        }
    }

    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        let fetchRequest = Port.fetchRequest()
        let predicates: [NSPredicate] = buildPredicates(filters: filters)

        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.predicate = predicate

        fetchRequest.sortDescriptors = UserDefaults.standard.sort(DataSources.port.key).map({ sortParameter in
            sortParameter.toNSSortDescriptor()
        })

        var count = 0
        context.performAndWait {
            count = (try? context.count(for: fetchRequest)) ?? 0
        }
        return count
    }

    typealias Page = Int

    func ports(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<[PortItem], Error> {
        return ports(filters: filters, at: nil, currentHeader: nil, paginatedBy: paginator)
            .map(\.portList)
            .eraseToAnyPublisher()
    }

    func ports(
        filters: [DataSourceFilterParameter]?,
        at page: Page?,
        currentHeader: String?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<PortModelPage, Error> {
        return ports(filters: filters, at: page, currentHeader: currentHeader)
            .map { result -> AnyPublisher<PortModelPage, Error> in
                if let paginator = paginator, let next = result.next {
                    return self.ports(
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

    func ports(
        filters: [DataSourceFilterParameter]?,
        at page: Page?,
        currentHeader: String?
    ) -> AnyPublisher<PortModelPage, Error> {

        let request = Port.fetchRequest()
        let predicates: [NSPredicate] = buildPredicates(filters: filters)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.predicate = predicate

        request.fetchLimit = 100
        request.fetchOffset = (page ?? 0) * request.fetchLimit
        let userSort = UserDefaults.standard.sort(DataSources.port.key)
        let sortDescriptors: [DataSourceSortParameter] =
        userSort.isEmpty ? DataSources.port.defaultSort : userSort

        request.sortDescriptors = sortDescriptors.map({ sortParameter in
            sortParameter.toNSSortDescriptor()
        })
        var previousHeader: String? = currentHeader
        var ports: [PortItem] = []
        context.performAndWait {
            if let fetched = context.fetch(request: request) {

                ports = fetched.flatMap { port in
                    guard let sortDescriptor = sortDescriptors.first else {
                        return [PortItem.listItem(PortListModel(port: port))]
                    }

                    if !sortDescriptor.section {
                        return [PortItem.listItem(PortListModel(port: port))]
                    }

                    return createSectionHeaderAndListItem(
                        port: port,
                        sortDescriptor: sortDescriptor,
                        previousHeader: &previousHeader
                    )
                }
            }
        }

        let portPage: PortModelPage = PortModelPage(
            portList: ports, next: (page ?? 0) + 1,
            currentHeader: previousHeader
        )

        return Just(portPage)
            .setFailureType(to: Error.self)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func createSectionHeaderAndListItem(
        port: Port,
        sortDescriptor: DataSourceSortParameter,
        previousHeader: inout String?
    ) -> [PortItem] {
        let currentValue = port.value(forKey: sortDescriptor.property.key)
        let sortValueString: String? = getCurrentSortValue(sortDescriptor: sortDescriptor, sortValue: currentValue)

        if let previous = previousHeader, let sortValueString = sortValueString {
            if previous != sortValueString {
                previousHeader = sortValueString
                return [
                    PortItem.sectionHeader(header: sortValueString),
                    PortItem.listItem(PortListModel(port: port))
                ]
            }
        } else if previousHeader == nil, let sortValueString = sortValueString {
            previousHeader = sortValueString
            return [
                PortItem.sectionHeader(header: sortValueString),
                PortItem.listItem(PortListModel(port: port))
            ]
        }

        return [PortItem.listItem(PortListModel(port: port))]
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
                sortValueString = DataSources.port.dateFormatter.string(from: currentValue)
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

    func insert(task: BGTask? = nil, ports: [PortModel]) async -> Int {
        let count = ports.count
        NSLog("Received \(count) \(DataSources.port.key) records.")

        // Create an operation that performs the main part of the background task.
        operation = PortDataLoadOperation(ports: ports, localDataSource: self)

        return await executeOperationInBackground(task: task)
    }

    func batchImport(from propertiesList: [PortModel]) async throws -> Int {
        guard !propertiesList.isEmpty else { return 0 }
        let taskContext = PersistenceController.current.newTaskContext()
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importPorts"

        let count = try await taskContext.perform {
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = self.newBatchInsertRequest(with: propertiesList)
            batchInsertRequest.resultType = .count
            if let fetchResult = try? taskContext.execute(batchInsertRequest),
               let batchInsertResult = fetchResult as? NSBatchInsertResult {
                try? taskContext.save()
                if let count = batchInsertResult.result as? Int, count > 0 {
                    NSLog("Inserted \(count) Port records")
                    return count
                } else {
                    NSLog("No new Port records")
                }
                return 0
            }
            throw MSIError.batchInsertError
        }
        return count
    }

    func newBatchInsertRequest(with propertyList: [PortModel]) -> NSBatchInsertRequest {
        var index = 0
        let total = propertyList.count

        // Provide one dictionary at a time when the closure is called.
        let batchInsertRequest = NSBatchInsertRequest(entity: Port.entity(), dictionaryHandler: { dictionary in
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
