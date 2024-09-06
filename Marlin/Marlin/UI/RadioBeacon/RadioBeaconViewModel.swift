//
//  RadioBeaconViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 9/27/23.
//

import Foundation

class RadioBeaconViewModel: ObservableObject, Identifiable {
    @Published var radioBeacon: RadioBeaconModel?

    var featureNumber: Int?
    var volumeNumber: String?

    @Injected(\.radioBeaconRepository)
    private var repository: RadioBeaconRepository
    var routeWaypointRepository: RouteWaypointRepository?

    @discardableResult
    func getRadioBeacon(featureNumber: Int?, volumeNumber: String?, waypointURI: URL? = nil) -> RadioBeaconModel? {
        if let waypointURI = waypointURI {
            radioBeacon = routeWaypointRepository?.getRadioBeacon(waypointURI: waypointURI)
        } else {
            radioBeacon = repository.getRadioBeacon(featureNumber: featureNumber, volumeNumber: volumeNumber)
        }
        return radioBeacon
    }
}
