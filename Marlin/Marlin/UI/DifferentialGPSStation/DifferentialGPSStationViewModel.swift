//
//  DifferentialGPSStationViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 9/26/23.
//

import Foundation

class DifferentialGPSStationViewModel: ObservableObject, Identifiable {
    @Published var differentialGPSStation: DifferentialGPSStationModel?
    @Published var predicate: NSPredicate?
    
    var repository: DifferentialGPSStationRepository? {
        didSet {
            if let featureNumber = featureNumber, let volumeNumber = volumeNumber {
                getDifferentialGPSStation(featureNumber: featureNumber, volumeNumber: volumeNumber)
            }
        }
    }
    var routeWaypointRepository: RouteWaypointRepository?

    var featureNumber: Int?
    var volumeNumber: String?

    init(featureNumber: Int? = nil, volumeNumber: String? = nil) {
        self.featureNumber = featureNumber
        self.volumeNumber = volumeNumber
    }

    @discardableResult
    func getDifferentialGPSStation(
        featureNumber: Int?,
        volumeNumber: String?,
        waypointURI: URL? = nil
    ) -> DifferentialGPSStationModel? {
        if let waypointURI = waypointURI {
            differentialGPSStation = routeWaypointRepository?.getDifferentialGPSStation(waypointURI: waypointURI)
        } else {
            differentialGPSStation = repository?.getDifferentialGPSStation(
                featureNumber: featureNumber,
                volumeNumber: volumeNumber
            )
        }
        return differentialGPSStation
    }
}
