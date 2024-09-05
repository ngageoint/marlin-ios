//
//  LightViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 9/18/23.
//

import Foundation

class LightViewModel: ObservableObject, Identifiable {
    @Published var lights: [LightModel] = []

    var featureNumber: String?
    var volumeNumber: String?

    var repository: LightRepository? {
        didSet {
            if let featureNumber = featureNumber, let volumeNumber = volumeNumber {
                getLights(featureNumber: featureNumber, volumeNumber: volumeNumber)
            }
        }
    }
    var routeWaypointRepository: RouteWaypointRepository?

    @discardableResult
    func getLights(featureNumber: String?, volumeNumber: String?, waypointURI: URL? = nil) -> [LightModel] {
        if let waypointURI = waypointURI {
            lights = routeWaypointRepository?.getLight(waypointURI: waypointURI) ?? []
        } else {
            lights = repository?.getLight(featureNumber: featureNumber, volumeNumber: volumeNumber) ?? []
            return lights
        }
        return []
    }
}
