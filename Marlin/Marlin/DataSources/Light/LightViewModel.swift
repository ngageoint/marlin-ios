//
//  LightViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 9/18/23.
//

import Foundation

class LightViewModel: ObservableObject, Identifiable {
    @Published var lights: [LightModel] = []
    @Published var predicate: NSPredicate?
    
    var repository: (any LightRepository)?
    
    @discardableResult
    func getLights(featureNumber: String?, volumeNumber: String?, waypointURI: URL?) -> [LightModel] {
        if let featureNumber = featureNumber, let volumeNumber = volumeNumber {
            predicate = NSPredicate(format: "featureNumber == %@ AND volumeNumber == %@", featureNumber, volumeNumber)
            lights = (repository?.getLights(featureNumber: featureNumber, volumeNumber: volumeNumber, waypointURI: waypointURI) ?? [])
                .sorted(by: { one, two in
                    (one.characteristicNumber ?? -1) < (two.characteristicNumber ?? -1)
                })
            return lights
        }
        return []
    }
}
