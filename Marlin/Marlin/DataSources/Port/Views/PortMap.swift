//
//  PortMap.swift
//  Marlin
//
//  Created by Daniel Barela on 8/23/22.
//

import Foundation
import MapKit
import CoreData
import Combine

class PortMap: DataSourceMap {

    override var minZoom: Int {
        get {
            return 2
        }
        set {

        }
    }

    override init(repository: TileRepository) {
        super.init(repository: repository)

        orderPublisher = UserDefaults.standard.orderPublisher(key: DataSources.port.key)
        userDefaultsShowPublisher = UserDefaults.standard.publisher(for: \.showOnMapport)
    }
}
