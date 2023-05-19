//
//  SFGeometryExtensions.swift
//  Marlin
//
//  Created by Daniel Barela on 5/11/23.
//

import Foundation
import CoreLocation

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
}
