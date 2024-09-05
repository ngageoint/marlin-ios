//
//  RadioBeaconMap.swift
//  Marlin
//
//  Created by Daniel Barela on 8/25/22.
//

import Foundation
import MapKit
import CoreData
import Combine

class RadioBeaconMap: DataSourceMap {

    override var minZoom: Int {
        get {
            return 2
        }
        set {

        }
    }

    override init(repository: TileRepository? = nil, mapFeatureRepository: MapFeatureRepository? = nil) {
        super.init(repository: repository, mapFeatureRepository: mapFeatureRepository)

        orderPublisher = UserDefaults.standard.orderPublisher(key: DataSources.radioBeacon.key)
        userDefaultsShowPublisher = UserDefaults.standard.publisher(for: \.showOnMapradioBeacon)
    }
}
