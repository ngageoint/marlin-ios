//
//  AsamMap.swift
//  Marlin
//
//  Created by Daniel Barela on 6/14/22.
//

import Foundation
import MapKit
import CoreData
import Combine

class AsamMap: DataSourceMap {

    override var minZoom: Int {
        get {
            return 2
        }
        set {

        }
    }

    override init(repository: TileRepository) {
        super.init(repository: repository)

        orderPublisher = UserDefaults.standard.orderPublisher(key: DataSources.asam.key)
        userDefaultsShowPublisher = UserDefaults.standard.publisher(for: \.showOnMapasam)
    }
}
