//
//  DFRS+MapImage.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import UIKit
import CoreLocation

extension DFRS: MapImage {
    var coordinate: CLLocationCoordinate2D {
        if txPosition != nil {
            return txCoordinate
        } else if rxPosition != nil {
            return rxCoordinate
        }
        return kCLLocationCoordinate2DInvalid
    }
    
    static var cacheTiles: Bool = true

    func mapImage(marker: Bool, zoomLevel: Int, tileBounds3857: MapBoundingBox?, context: CGContext? = nil) -> [UIImage] {
        return defaultMapImage(marker: marker, zoomLevel: zoomLevel, tileBounds3857: tileBounds3857, context: context, tileSize: 512.0)
    }
}
