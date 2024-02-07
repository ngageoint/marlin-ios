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
    func getModu(waypointURI: URL?) -> ModuModel?
    func getPort(waypointURI: URL?) -> PortModel?
    func getDifferentialGPSStation(waypointURI: URL?) -> DifferentialGPSStationModel?
    func getLight(waypointURI: URL?) -> [LightModel]?
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

    func getModu(waypointURI: URL?) -> ModuModel? {
        if let waypointURI = waypointURI {
            if let id = context.persistentStoreCoordinator?.managedObjectID(
                forURIRepresentation: waypointURI
            ),
               let waypoint = try? context.existingObject(with: id) as? RouteWaypoint {
                let dataSource = waypoint.decodeToDataSource()
                if let dataSource = dataSource as? ModuModel {
                    return dataSource
                }
            }
        }
        return nil
    }

    func getPort(waypointURI: URL?) -> PortModel? {
        if let waypointURI = waypointURI {
            if let id = context.persistentStoreCoordinator?.managedObjectID(
                forURIRepresentation: waypointURI
            ),
               let waypoint = try? context.existingObject(with: id) as? RouteWaypoint {
                let dataSource = waypoint.decodeToDataSource()
                if let dataSource = dataSource as? PortModel {
                    return dataSource
                }
            }
        }
        return nil
    }

    func getDifferentialGPSStation(waypointURI: URL?) -> DifferentialGPSStationModel? {
        if let waypointURI = waypointURI {
            if let id = context.persistentStoreCoordinator?.managedObjectID(
                forURIRepresentation: waypointURI
            ),
               let waypoint = try? context.existingObject(with: id) as? RouteWaypoint {
                let dataSource = waypoint.decodeToDataSource()
                if let dataSource = dataSource as? DifferentialGPSStationModel {
                    return dataSource
                }
            }
        }
        return nil
    }

    func getLight(waypointURI: URL?) -> [LightModel]? {
        if let waypointURI = waypointURI {
            if let id = context.persistentStoreCoordinator?.managedObjectID(
                forURIRepresentation: waypointURI
            ),
               let waypoint = try? context.existingObject(with: id) as? RouteWaypoint {
                let dataSource = waypoint.decodeToDataSource()
                if let dataSource = dataSource as? LightModel {
                    // TODO: should lookup the rest of the lights with the featureNumber
                    return [dataSource]
                }
            }
        }
        return nil
    }
}
