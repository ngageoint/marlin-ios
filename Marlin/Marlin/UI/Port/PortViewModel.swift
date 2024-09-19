//
//  PortViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 9/21/23.
//

import Foundation

@MainActor
class PortViewModel: ObservableObject, Identifiable {
    @Published var port: PortModel?

    var portNumber: Int?

    @Injected(\.portRepository)
    private var repository: PortRepository
    var routeWaypointRepository: RouteWaypointRepository?

    @discardableResult
    func getPort(portNumber: Int?, waypointURI: URL? = nil) async -> PortModel? {
        if let waypointURI = waypointURI {
            port = routeWaypointRepository?.getPort(waypointURI: waypointURI)
            return port
        } else {
            port = await repository.getPort(portNumber: portNumber)
            return port
        }
    }
}
