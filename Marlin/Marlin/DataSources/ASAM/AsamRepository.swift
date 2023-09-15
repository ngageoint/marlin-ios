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
}

protocol AsamRepository {
    @discardableResult
    func getAsam(reference: String?, waypointURI: URL?) -> AsamModel?
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
}
