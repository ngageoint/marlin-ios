//
//  RouteWaypointRepository.swift
//  Marlin
//
//  Created by Daniel Barela on 10/30/23.
//

import Foundation

class RouteWaypointRepository: ObservableObject {
    private var localDataSource: RouteWaypointLocalDataSource
    init(localDataSource: RouteWaypointLocalDataSource) {
        self.localDataSource = localDataSource
    }
    func getAsam(waypointURI: URL?) -> AsamModel? {
        localDataSource.getAsam(waypointURI: waypointURI)
    }
    func getModu(waypointURI: URL?) -> ModuModel? {
        localDataSource.getModu(waypointURI: waypointURI)
    }
    func getPort(waypointURI: URL?) -> PortModel? {
        localDataSource.getPort(waypointURI: waypointURI)
    }
    func getDGPSStation(waypointURI: URL?) -> DGPSStationModel? {
        localDataSource.getDifferentialGPSStation(waypointURI: waypointURI)
    }
    func getLight(waypointURI: URL?) -> [LightModel]? {
        localDataSource.getLight(waypointURI: waypointURI)
    }
    func getRadioBeacon(waypointURI: URL?) -> RadioBeaconModel? {
        localDataSource.getRadioBeacon(waypointURI: waypointURI)
    }
    func getNavigationalWarning(waypointURI: URL?) -> NavigationalWarningModel? {
        localDataSource.getNavigationalWarning(waypointURI: waypointURI)
    }
}
