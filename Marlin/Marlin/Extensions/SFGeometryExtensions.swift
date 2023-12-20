//
//  SFGeometryExtensions.swift
//  Marlin
//
//  Created by Daniel Barela on 5/11/23.
//

import Foundation
import CoreLocation
import GeoJSON
import sf_ios

// Need this here so that XCode will compile the SFGeometryCollection class before it is used in a subsequent file
// why XCode will not just compile the class in the file it is referenced in is beyond me..... DRB 2023 OCT 4
extension SFGeometryCollection {
    var thingToMakeItCompile: String {
        "hi"
    }
}

extension SFPolygon {

    convenience init(locations: [String]) {
        var points: [SFPoint] = []
        for locationPoint in locations {
            if let coordinate = CLLocationCoordinate2D(coordinateString: locationPoint) {
                points.append(SFPoint(xValue: coordinate.longitude, andYValue: coordinate.latitude))
            }
        }
        
        self.init(ring: SFLineString(points: NSMutableArray(array: points)))
    }
    
    func toGeoJSON() -> Polygon? {
        var linearRings: [Polygon.LinearRing] = []
        for ring in self.rings {
            if let ring = ring as? SFLineString {
                var positions: [Position] = []
                if let points = ring.points {
                    for point in points {
                        if let point = point as? SFPoint {
                            positions.append(
                                Position(longitude: point.x.doubleValue, latitude: point.y.doubleValue, altitude: nil)
                            )
                        }
                    }
                }
                try? linearRings.append(Polygon.LinearRing(coordinates: positions))
            }
        }
        return Polygon(coordinates: linearRings)
    }
}

extension SFLineString {
    convenience init(locations: [String]) {
        var points: [SFPoint] = []
        for locationPoint in locations {
            if let coordinate = CLLocationCoordinate2D(coordinateString: locationPoint) {
                points.append(SFPoint(xValue: coordinate.longitude, andYValue: coordinate.latitude))
            }
        }
        self.init(points: NSMutableArray(array: points))
    }
    
    func toGeoJSON() -> LineString? {
        var positions: [Position] = []
        if let points = self.points {
            for point in points {
                if let point = point as? SFPoint {
                    positions.append(
                        Position(longitude: point.x.doubleValue, latitude: point.y.doubleValue, altitude: nil)
                    )
                }
            }
        }
        return try? LineString(coordinates: positions)
    }
}
