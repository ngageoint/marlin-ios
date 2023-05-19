//
//  BottomSheetItem.swift
//  Marlin
//
//  Created by Daniel Barela on 8/9/22.
//

import Foundation
import MapKit

class BottomSheetItem: NSObject, Identifiable {
    var item: any DataSource
    var mapName: String?
    var zoom: Bool
    
    init(item: any DataSource, mapName: String? = nil, zoom: Bool) {
        self.item = item
        self.mapName = mapName
        self.zoom = zoom
    }
}
