//
//  MKPolygonExtensions.swift
//  Marlin
//
//  Created by Joshua Nelson on 8/29/23.
//

import Foundation
import MapKit

extension MKPolygon {
    
    static func buildGeodesicPolyline(points: UnsafePointer<MKMapPoint>, pointCount: Int) -> MKGeodesicPolyline {
        var pointsToConnect = Array(UnsafeBufferPointer(start: points, count: pointCount))
        
        // connect the final point back to the first with a geodesic polyline
        pointsToConnect.append(pointsToConnect[0])
        
        return MKGeodesicPolyline(points: pointsToConnect, count: pointsToConnect.count)
    }
    
    func toGeodesicPolyline() -> MKGeodesicPolyline {
        return MKPolygon.buildGeodesicPolyline(points: points(), pointCount: pointCount)
    }
    
    func getGeodesicClickAreas() -> [MKGeodesicPolyline] {
        var clickAreas: [MKGeodesicPolyline] = []
        let points = Array<MKMapPoint>(UnsafeBufferPointer(start: points(), count: pointCount))
        clickAreas.append(MKPolygon.buildGeodesicPolyline(points: points, pointCount: points.count))
        
        // check for meridian/antimeridian crossing
        var crossesAtIndex = -1
        for i in 0..<points.count {
            if points[i].coordinate.longitude.sign != points[0].coordinate.longitude.sign {
                crossesAtIndex = i
                break
            }
        }
        
        // if shape crosses a meridian, add another click area starting from the other side of the meridian
        if(crossesAtIndex > -1){
            let reorderedPoints: [MKMapPoint] = points.dropFirst(crossesAtIndex) + points.dropLast(points.count - crossesAtIndex)
            clickAreas.append(MKPolygon.buildGeodesicPolyline(points: reorderedPoints, pointCount: reorderedPoints.count))
        }
        
        return clickAreas
    }
}
