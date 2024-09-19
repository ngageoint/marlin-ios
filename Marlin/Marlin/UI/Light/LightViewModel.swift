//
//  LightViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 9/18/23.
//

import Foundation

@MainActor
class LightViewModel: ObservableObject, Identifiable {
    @Published var lights: [LightModel] = []

    var featureNumber: String?
    var volumeNumber: String?

    @Injected(\.lightRepository)
    private var repository: LightRepository
    
    var routeWaypointRepository: RouteWaypointRepository?

    @discardableResult
    func getLights(featureNumber: String?, volumeNumber: String?, waypointURI: URL? = nil) async -> [LightModel] {
        if let waypointURI = waypointURI {
            lights = routeWaypointRepository?.getLight(waypointURI: waypointURI) ?? []
        } else {
            lights = await repository.getLight(featureNumber: featureNumber, volumeNumber: volumeNumber) ?? []
            return lights
        }
        return []
    }
}
