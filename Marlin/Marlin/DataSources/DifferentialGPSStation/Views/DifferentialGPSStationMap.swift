//
//  DifferentialGPSStationMap.swift
//  Marlin
//
//  Created by Daniel Barela on 8/30/22.
//

import Foundation
import MapKit
import CoreData
import Combine

class DifferentialGPSStationMap: DataSourceMap {

    override var minZoom: Int {
        get {
            return 2
        }
        set {

        }
    }

    override init(repository: TileRepository) {
        super.init(repository: repository)

        orderPublisher = UserDefaults.standard.orderPublisher(key: DataSources.dgps.key)
        userDefaultsShowPublisher = UserDefaults.standard.publisher(for: \.showOnMapdifferentialGPSStation)
    }
}
