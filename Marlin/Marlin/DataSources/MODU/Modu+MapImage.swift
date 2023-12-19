//
//  Modu+MapImage.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import UIKit
import CoreLocation

extension Modu: MapImage {
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    static var cacheTiles: Bool = true
    
    func mapImage(marker: Bool, zoomLevel: Int, tileBounds3857: MapBoundingBox?, context: CGContext? = nil) -> [UIImage] {
        var images: [UIImage] = []
        if let tileBounds3857 = tileBounds3857, distance > 0 {
            let circleCoordinates = coordinate.circleCoordinates(radiusMeters: distance * 1852)
            let path = UIBezierPath()
            var pixel = circleCoordinates[0].toPixel(zoomLevel: zoomLevel, tileBounds3857: tileBounds3857, tileSize: TILE_SIZE)
            path.move(to: pixel)
            for circleCoordinate in circleCoordinates {
                pixel = circleCoordinate.toPixel(zoomLevel: zoomLevel, tileBounds3857: tileBounds3857, tileSize: TILE_SIZE)
                path.addLine(to: pixel)
            }
            path.lineWidth = 4
            path.close()
            Modu.color.withAlphaComponent(0.3).setFill()
            Modu.color.setStroke()
            path.fill()
            path.stroke()
        }
        images.append(contentsOf: defaultMapImage(marker: marker, zoomLevel: zoomLevel, tileBounds3857: tileBounds3857, context: context, tileSize: 512.0))
        return images
    }
}
