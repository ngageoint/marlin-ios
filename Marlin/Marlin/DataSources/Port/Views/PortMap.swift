//
//  PortMap.swift
//  Marlin
//
//  Created by Daniel Barela on 8/23/22.
//

import Foundation
import MapKit
import Combine

class PortMap: DataSourceMap {

    override var minZoom: Int {
        get {
            return 2
        }
        set {

        }
    }

    override init(repository: TileRepository? = nil, mapFeatureRepository: MapFeatureRepository? = nil) {
        super.init(repository: repository, mapFeatureRepository: mapFeatureRepository)

        orderPublisher = UserDefaults.standard.orderPublisher(key: DataSources.port.key)
        userDefaultsShowPublisher = UserDefaults.standard.publisher(for: \.showOnMapport)
    }
}
