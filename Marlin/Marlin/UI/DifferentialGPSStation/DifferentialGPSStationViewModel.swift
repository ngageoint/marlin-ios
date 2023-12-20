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
    
    var repository: (any DifferentialGPSStationRepository)?
    
    @discardableResult
    func getDifferentialGPSStation(
        featureNumber: Int?,
        volumeNumber: String?,
        waypointURI: URL?
    ) -> DifferentialGPSStationModel? {
        if let waypointURI = waypointURI {
            differentialGPSStation = repository?.getDifferentialGPSStation(
                featureNumber: featureNumber,
                volumeNumber: volumeNumber,
                waypointURI: waypointURI
            )
        } else if let featureNumber = featureNumber, let volumeNumber = volumeNumber {
            predicate = NSPredicate(format: "featureNumber == %i AND volumeNumber == %@", featureNumber, volumeNumber)
            differentialGPSStation = repository?.getDifferentialGPSStation(
                featureNumber: featureNumber,
                volumeNumber: volumeNumber,
                waypointURI: waypointURI
            )
        }
        return differentialGPSStation
    }
}
