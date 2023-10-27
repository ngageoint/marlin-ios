//
//  AsamRepository.swift
//  Marlin
//
//  Created by Daniel Barela on 9/15/23.
//

import Foundation
import CoreData

class AsamRepositoryManager: AsamRepository, ObservableObject {
    private var repository: AsamRepository
    init(repository: AsamRepository) {
        self.repository = repository
    }
    func getAsam(reference: String?, waypointURI: URL?) -> AsamModel? {
        repository.getAsam(reference: reference, waypointURI: waypointURI)
    }
    func getAsams(filters: [DataSourceFilterParameter]?) -> [AsamModel] {
        repository.getAsams(filters: filters)
    }
    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        repository.getCount(filters: filters)
    }
}

protocol AsamRepository {
    @discardableResult
    func getAsam(reference: String?, waypointURI: URL?) -> AsamModel?
    func getAsams(filters: [DataSourceFilterParameter]?) -> [AsamModel]
    func getCount(filters: [DataSourceFilterParameter]?) -> Int
}

class AsamCoreDataRepository: AsamRepository, ObservableObject {
    private var context: NSManagedObjectContext
    
    required init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getAsam(reference: String?, waypointURI: URL?) -> AsamModel? {
        if let waypointURI = waypointURI, let reference = reference {
            if let id = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: waypointURI), let waypoint = try? context.existingObject(with: id) as? RouteWaypoint {
                let dataSource = waypoint.decodeToDataSource()
                if let dataSource = dataSource as? AsamModel {
                    return dataSource
                }
            }
        }
        if let reference = reference {
            if let asam = context.fetchFirst(Asam.self, key: "reference", value: reference) {
                return AsamModel(asam: asam)
            }
        }
        return nil
    }
    
    func getAsams(filters: [DataSourceFilterParameter]?) -> [AsamModel] {
        return []
    }
    
    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        NSLog("Get the count for filters \(filters)")
        guard let fetchRequest = AsamFilterable().fetchRequest(filters: filters, commonFilters: nil) else {
            return 0
        }
        return (try? context.count(for: fetchRequest)) ?? 0
    }
}
