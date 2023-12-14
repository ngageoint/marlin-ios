//
//  BottomSheetItem.swift
//  Marlin
//
//  Created by Daniel Barela on 8/9/22.
//

import Foundation
import MapKit

class BottomSheetItem: NSObject, Identifiable {
    var item: (any DataSource)?
    var mapName: String?
    var zoom: Bool
    
    var itemKey: String?
    var dataSourceKey: String?
    
    init(item: (any DataSource)? = nil, mapName: String? = nil, zoom: Bool, itemKey: String? = nil, dataSourceKey: String? = nil) {
        self.item = item
        self.mapName = mapName
        self.zoom = zoom
        
        self.itemKey = itemKey
        self.dataSourceKey = dataSourceKey
    }
}
