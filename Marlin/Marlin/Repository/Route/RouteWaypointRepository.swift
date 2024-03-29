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
}
