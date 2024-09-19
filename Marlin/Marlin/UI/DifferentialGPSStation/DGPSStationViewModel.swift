//
//  DGPSStationViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 9/26/23.
//

import Foundation

@MainActor
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
    ) async -> DGPSStationModel? {
        if let waypointURI = waypointURI {
            dgpsStation = routeWaypointRepository?.getDGPSStation(waypointURI: waypointURI)
        } else {
            dgpsStation = await repository.getDGPSStation(
                featureNumber: featureNumber,
                volumeNumber: volumeNumber
            )
        }
        return dgpsStation
    }
}
