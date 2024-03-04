//
//  PortViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 9/21/23.
//

import Foundation

class PortViewModel: ObservableObject, Identifiable {
    @Published var port: PortModel?

    var portNumber: Int?

    var repository: PortRepository? {
        didSet {
            if let portNumber = portNumber {
                getPort(portNumber: portNumber)
            }
        }
    }
    var routeWaypointRepository: RouteWaypointRepository?

    @discardableResult
    func getPort(portNumber: Int?, waypointURI: URL? = nil) -> PortModel? {
        if let waypointURI = waypointURI {
            port = routeWaypointRepository?.getPort(waypointURI: waypointURI)
            return port
        } else {
            port = repository?.getPort(portNumber: portNumber)
            return port
        }
    }
}
