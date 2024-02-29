//
//  RouteWaypointStaticLocalDataSource.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/11/24.
//

import Foundation

@testable import Marlin

class RouteWaypointStaticLocalDataSource: RouteWaypointLocalDataSource {
    func getNavigationalWarning(waypointURI: URL?) -> Marlin.NavigationalWarningModel? {
        if let waypointURI = waypointURI {
            return waypoints[waypointURI] as? NavigationalWarningModel
        }
        return nil
    }
    
    var waypoints: [URL: Any] = [:]

    func getAsam(waypointURI: URL?) -> Marlin.AsamModel? {
        if let waypointURI = waypointURI {
            return waypoints[waypointURI] as? AsamModel
        }
        return nil
    }
    
    func getModu(waypointURI: URL?) -> Marlin.ModuModel? {
        if let waypointURI = waypointURI {
            return waypoints[waypointURI] as? ModuModel
        }
        return nil
    }
    
    func getPort(waypointURI: URL?) -> Marlin.PortModel? {
        if let waypointURI = waypointURI {
            return waypoints[waypointURI] as? PortModel
        }
        return nil
    }
    
    func getDifferentialGPSStation(waypointURI: URL?) -> Marlin.DGPSStationModel? {
        if let waypointURI = waypointURI {
            return waypoints[waypointURI] as? DGPSStationModel
        }
        return nil
    }
    
    func getLight(waypointURI: URL?) -> [Marlin.LightModel]? {
        if let waypointURI = waypointURI {
            return waypoints[waypointURI] as? [LightModel]
        }
        return nil
    }
    
    func getRadioBeacon(waypointURI: URL?) -> Marlin.RadioBeaconModel? {
        if let waypointURI = waypointURI {
            return waypoints[waypointURI] as? RadioBeaconModel
        }
        return nil
    }
    

}
