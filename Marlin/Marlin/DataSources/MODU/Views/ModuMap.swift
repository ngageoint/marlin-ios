//
//  ModuMap.swift
//  Marlin
//
//  Created by Daniel Barela on 6/17/22.
//

import Foundation
import MapKit
import CoreData
import Combine

class ModuMap: DataSourceMap {

    override var minZoom: Int {
        get {
            return 2
        }
        set {

        }
    }

    override init(repository: TileRepository) {
        super.init(repository: repository)

        orderPublisher = UserDefaults.standard.orderPublisher(key: DataSources.modu.key)
        userDefaultsShowPublisher = UserDefaults.standard.publisher(for: \.showOnMapmodu)
    }
}
