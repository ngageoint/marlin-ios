//
//  PortRepository.swift
//  Marlin
//
//  Created by Daniel Barela on 9/20/23.
//

import Foundation
import CoreData

protocol PortRepository {
    @discardableResult
    func getPort(portNumber: Int64?, waypointURI: URL?) -> PortModel?
    func getCount(filters: [DataSourceFilterParameter]?) -> Int
}

class PortRepositoryManager: PortRepository, ObservableObject {
    private var repository: PortRepository
    init(repository: PortRepository) {
        self.repository = repository
    }
    
    func getPort(portNumber: Int64?, waypointURI: URL?) -> PortModel? {
        repository.getPort(portNumber: portNumber, waypointURI: waypointURI)
    }
    
    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        repository.getCount(filters: filters)
    }
}

class PortCoreDataRepository: PortRepository, ObservableObject {
    private var context: NSManagedObjectContext
    required init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getPort(portNumber: Int64?, waypointURI: URL?) -> PortModel? {
        if let waypointURI = waypointURI {
            if let id = context.persistentStoreCoordinator?.managedObjectID(
                forURIRepresentation: waypointURI
            ), let waypoint = try? context.existingObject(with: id) as? RouteWaypoint {
                let dataSource = waypoint.decodeToDataSource()
                if let dataSource = dataSource as? PortModel {
                    return dataSource
                }
            }
        }
        if let portNumber = portNumber {
            if let port = context.fetchFirst(Port.self, key: "portNumber", value: portNumber) {
                return PortModel(port: port)
            }
        }
        return nil
    }
    
    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        guard let fetchRequest = PortFilterable().fetchRequest(filters: filters, commonFilters: nil) else {
            return 0
        }
        return (try? context.count(for: fetchRequest)) ?? 0
    }
}
