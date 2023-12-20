//
//  RadioBeacon+MapImage.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import UIKit
import CoreLocation

extension RadioBeacon: MapImage {
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    static var cacheTiles: Bool = true
    
    func mapImage(
        marker: Bool,
        zoomLevel: Int,
        tileBounds3857: MapBoundingBox?,
        context: CGContext? = nil) -> [UIImage] {
        let scale = marker ? 1 : 2
        
        var images: [UIImage] = []
        if let raconImage = raconImage(scale: scale, azimuthCoverage: azimuthCoverage, zoomLevel: zoomLevel) {
            images.append(raconImage)
        }
        return images
    }
    
    func raconImage(scale: Int, azimuthCoverage: [ImageSector]? = nil, zoomLevel: Int) -> UIImage? {
        let radius = CGFloat(zoomLevel) / 3.0 * UIScreen.main.scale * RadioBeacon.imageScale
        let sectors = azimuthCoverage ?? [ImageSector(startDegrees: 0, endDegrees: 360, color: RadioBeacon.color)]
        
        if zoomLevel > 8 {
            return RaconImage(
                frame: CGRect(x: 0, y: 0, width: 3 * (radius + 3.0), height: 3 * (radius + 3.0)),
                sectors: sectors,
                arcWidth: 3.0,
                arcRadius: radius + 3.0,
                text: "Racon (\(morseLetter))",
                darkMode: false)
        } else {
            return CircleImage(
                color: RadioBeacon.color,
                radius: radius,
                fill: false,
                arcWidth: min(3.0, radius / 2.0))
        }
    }
}
