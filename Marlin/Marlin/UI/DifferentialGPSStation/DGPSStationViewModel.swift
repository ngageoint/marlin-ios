//
//  DGPSStationViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 9/26/23.
//

import Foundation

class DGPSStationViewModel: ObservableObject, Identifiable {
    @Published var dgpsStation: DGPSStationModel?
    @Published var predicate: NSPredicate?
    
    @Injected(\.dgpsRepository)
    var repository: DGPSStationRepository
    var routeWaypointRepository: RouteWaypointRepository?

    var featureNumber: Int?
    var volumeNumber: String?

    init(featureNumber: Int? = nil, volumeNumber: String? = nil) {
        self.featureNumber = featureNumber
        self.volumeNumber = volumeNumber
    }

    @discardableResult
    func getDGPSStation(
        featureNumber: Int?,
        volumeNumber: String?,
        waypointURI: URL? = nil
    ) -> DGPSStationModel? {
        if let waypointURI = waypointURI {
            dgpsStation = routeWaypointRepository?.getDGPSStation(waypointURI: waypointURI)
        } else {
            dgpsStation = repository.getDGPSStation(
                featureNumber: featureNumber,
                volumeNumber: volumeNumber
            )
        }
        return dgpsStation
    }
}
