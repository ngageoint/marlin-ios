//
//  MKShapeExtensions.swift
//  Marlin
//
//  Created by Daniel Barela on 5/4/23.
//

import Foundation
import MapKit
import sf_wkt_ios

extension MKShape {
    static func fromWKT(wkt: String, distance: Double?) -> MKShape? {
        let geometry = SFWTGeometryReader.readGeometry(withText: wkt)
        
        var mapPoints: [MKMapPoint] = []
        if let point = geometry as? SFPoint {
            let coordinate = CLLocationCoordinate2D(latitude: point.y.doubleValue, longitude: point.x.doubleValue)
            if let distance = distance {
                // this is really a circle
                return MKCircle(center: coordinate, radius: distance)
            }
            let point = MKPointAnnotation()
            point.coordinate = coordinate
            return point
        } else if let polygon = geometry as? SFPolygon {
            if let lineString = polygon.ring(at: 0) {
                if let points = lineString.points {
                    for point in points {
                        if let point = point as? SFPoint {
                            mapPoints.append(MKMapPoint(CLLocationCoordinate2D(latitude: point.y.doubleValue, longitude: point.x.doubleValue)))
                        }
                    }
                }
            }
            return MKPolygon(points: &mapPoints, count: mapPoints.count)
        } else if let line = geometry as? SFLineString {
            if let points = line.points {
                for point in points {
                    if let point = point as? SFPoint {
                        mapPoints.append(MKMapPoint(CLLocationCoordinate2D(latitude: point.y.doubleValue, longitude: point.x.doubleValue)))
                    }
                }
            }
            return MKGeodesicPolyline(points: &mapPoints, count: mapPoints.count)
        }
        return nil
    }
}
