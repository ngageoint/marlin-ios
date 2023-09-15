//
//  ModuRepository.swift
//  Marlin
//
//  Created by Daniel Barela on 9/15/23.
//

import Foundation
import CoreData

protocol ModuRepository {
    @discardableResult
    func getModu(name: String?, waypointURI: URL?) -> ModuModel?
}

class ModuRepositoryManager: ModuRepository, ObservableObject {
    private var repository: ModuRepository
    
    init(repository: ModuRepository) {
        self.repository = repository
    }
    
    func getModu(name: String?, waypointURI: URL?) -> ModuModel? {
        repository.getModu(name: name, waypointURI: waypointURI)
    }
}

class ModuCoreDataRepository: ModuRepository, ObservableObject {
    private var context: NSManagedObjectContext
    
    required init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getModu(name: String?, waypointURI: URL?) -> ModuModel? {
        if let waypointURI = waypointURI, let name = name {
            if let id = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: waypointURI), let waypoint = try? context.existingObject(with: id) as? RouteWaypoint {
                let dataSource = waypoint.decodeToDataSource()
                if let dataSource = dataSource as? ModuModel {
                    return dataSource
                }
            }
        }
        if let name = name {
            if let modu = context.fetchFirst(Modu.self, key: "name", value: name) {
                return ModuModel(modu: modu)
            }
        }
        return nil
    }
}
