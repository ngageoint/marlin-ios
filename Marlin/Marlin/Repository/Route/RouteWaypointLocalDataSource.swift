//
//  RouteWaypointLocalDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 10/30/23.
//

import Foundation
import CoreData

protocol RouteWaypointLocalDataSource {
    @discardableResult
    func getAsam(waypointURI: URL?) -> AsamModel?
}

class RouteWaypointCoreDataDataSource: RouteWaypointLocalDataSource, ObservableObject {
    private var context: NSManagedObjectContext
    
    required init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getAsam(waypointURI: URL?) -> AsamModel? {
        if let waypointURI = waypointURI {
            if let id = context.persistentStoreCoordinator?.managedObjectID(
                forURIRepresentation: waypointURI
            ),
               let waypoint = try? context.existingObject(with: id) as? RouteWaypoint {
                let dataSource = waypoint.decodeToDataSource()
                if let dataSource = dataSource as? AsamModel {
                    return dataSource
                }
            }
        }
        return nil
    }
}
