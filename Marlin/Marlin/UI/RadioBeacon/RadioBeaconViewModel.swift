//
//  RadioBeaconViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 9/27/23.
//

import Foundation

class RadioBeaconViewModel: ObservableObject, Identifiable {
    @Published var radioBeacon: RadioBeaconModel?
    @Published var predicate: NSPredicate?
    
    var repository: (any RadioBeaconRepository)?
    
    @discardableResult
    func getRadioBeacon(featureNumber: Int?, volumeNumber: String?, waypointURI: URL?) -> RadioBeaconModel? {
        if let featureNumber = featureNumber, let volumeNumber = volumeNumber {
            predicate = NSPredicate(format: "featureNumber = %ld AND volumeNumber = %@", argumentArray: [featureNumber, volumeNumber])
        }
        radioBeacon = repository?.getRadioBeacon(featureNumber: featureNumber, volumeNumber: volumeNumber, waypointURI: waypointURI)
        return radioBeacon
    }
}
