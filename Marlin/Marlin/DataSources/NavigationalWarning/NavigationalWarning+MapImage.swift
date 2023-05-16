//
//  NavigationalWarning+MapImage.swift
//  Marlin
//
//  Created by Daniel Barela on 5/16/23.
//

import Foundation
import UIKit

extension NavigationalWarning: MapImage {
    static var cacheTiles: Bool = true
    
    func mapImage(marker: Bool, zoomLevel: Int, tileBounds3857: MapBoundingBox?, context: CGContext? = nil) -> [UIImage] {
        return defaultMapImage(marker: marker, zoomLevel: zoomLevel, tileBounds3857: tileBounds3857, context: context, tileSize: 512.0)
    }
}
