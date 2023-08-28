//
//  SFGeometryExtensions.swift
//  Marlin
//
//  Created by Daniel Barela on 5/11/23.
//

import Foundation
import CoreLocation
import GeoJSON

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
                            positions.append(Position(longitude: point.x.doubleValue, latitude: point.y.doubleValue, altitude: nil))
                        }
                    }
                }
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
                    positions.append(Position(longitude: point.x.doubleValue, latitude: point.y.doubleValue, altitude: nil))
                }
            }
        }
        return try? LineString(coordinates: positions)
    }
}
