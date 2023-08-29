//
//  NavigationalWarning+MapImage.swift
//  Marlin
//
//  Created by Daniel Barela on 5/16/23.
//

import Foundation
import UIKit
import MapKit
import sf_wkt_ios

extension NavigationalWarning: MapImage {
    static var cacheTiles: Bool = true
    
    func mapImage(marker: Bool, zoomLevel: Int, tileBounds3857: MapBoundingBox?, context: CGContext? = nil) -> [UIImage] {
        var images: [UIImage] = []
        guard let tileBounds3857 = tileBounds3857 else {
            return images
        }
        if let locations = locations {
            for location in locations {
                if let wkt = location["wkt"] {
                    var distance: Double?
                    if let distanceString = location["distance"] {
                        distance = Double(distanceString)
                    }
                    
                    let shape = MKShape.fromWKT(wkt: wkt, distance: distance)
                                        
                    if let point = shape as? MKPointAnnotation {
                        let coordinate = point.coordinate
                        if let distance = distance {
                            let circleCoordinates = coordinate.circleCoordinates(radiusMeters: distance)
                            let path = UIBezierPath()
                            
                            var pixel = circleCoordinates[0].toPixel(zoomLevel: zoomLevel, tileBounds3857: tileBounds3857, tileSize: TILE_SIZE)
                            path.move(to: pixel)
                            for circleCoordinate in circleCoordinates {
                                pixel = circleCoordinate.toPixel(zoomLevel: zoomLevel, tileBounds3857: tileBounds3857, tileSize: TILE_SIZE)
                                path.addLine(to: pixel)
                            }
                            path.lineWidth = 4
                            path.close()
                            NavigationalWarning.color.withAlphaComponent(0.3).setFill()
                            NavigationalWarning.color.setStroke()
                            path.fill()
                            path.stroke()
                        }
                        images.append(contentsOf: defaultMapImage(marker: marker, zoomLevel: zoomLevel, pointCoordinate: coordinate, tileBounds3857: tileBounds3857, context: context, tileSize: 512.0))
                    } else if let polygon = shape as? MKPolygon { // NOTE: this is drawing the visual warning area for nav warnings
//                        let points = polygon.points()
//                        let path = UIBezierPath()
//                        var firstPoint: CLLocationCoordinate2D?
//                        var previousPoint: CLLocationCoordinate2D?
//                        for point in UnsafeBufferPointer(start: points, count: polygon.pointCount) {
//
//                            let pixel = point.coordinate.toPixel(zoomLevel: zoomLevel, tileBounds3857: tileBounds3857, tileSize: TILE_SIZE)
//                            // make a geodesic line between the points and then plot that
//                            if let previousPoint = previousPoint {
//                                var coords: [CLLocationCoordinate2D] = [previousPoint, point.coordinate]
//                                let gl = MKGeodesicPolyline(coordinates: &coords, count: 2)
//
//                                let glpoints = gl.points()
//
//                                for point in UnsafeBufferPointer(start: glpoints, count: gl.pointCount) {
//
//                                    let pixel = point.coordinate.toPixel(zoomLevel: zoomLevel, tileBounds3857: tileBounds3857, tileSize: TILE_SIZE)
//                                    path.addLine(to: pixel)
//
//                                }
//                            } else {
//                                firstPoint = point.coordinate
//                                path.move(to: pixel)
//                            }
//                            previousPoint = point.coordinate
//
//                        }
//
//                        // now draw the geodesic line between the last and the first
//                        if let previousPoint = previousPoint, let firstPoint = firstPoint {
//                            var coords: [CLLocationCoordinate2D] = [previousPoint, firstPoint]
//                            let gl = MKGeodesicPolyline(coordinates: &coords, count: 2)
//
//                            let glpoints = gl.points()
//
//                            for point in UnsafeBufferPointer(start: glpoints, count: gl.pointCount) {
//
//                                let pixel = point.coordinate.toPixel(zoomLevel: zoomLevel, tileBounds3857: tileBounds3857, tileSize: TILE_SIZE)
//                                path.addLine(to: pixel)
//
//                            }
//                        }
//
                        // new
                        let gp = NavigationalWarning.geoDesicPolygon(from: polygon)
                        let path = UIBezierPath()
                        var first = true
                        let points = gp.points()

                        for point in UnsafeBufferPointer(start: points, count: gp.pointCount) {
                            
                            let pixel = point.coordinate.toPixel(zoomLevel: zoomLevel, tileBounds3857: tileBounds3857, tileSize: TILE_SIZE)
                            if first {
                                path.move(to: pixel)
                                first = false
                            } else {
                                path.addLine(to: pixel)
                            }

                        }
                        
                        path.lineWidth = 4
                        path.close()
                        NavigationalWarning.color.withAlphaComponent(0.3).setFill()
                        NavigationalWarning.color.setStroke()
                        path.fill()
                        path.stroke()
                    } else if let lineShape = shape as? MKGeodesicPolyline {
                        
                        let path = UIBezierPath()
                        var first = true
                        let points = lineShape.points()

                        for point in UnsafeBufferPointer(start: points, count: lineShape.pointCount) {
                            
                            let pixel = point.coordinate.toPixel(zoomLevel: zoomLevel, tileBounds3857: tileBounds3857, tileSize: TILE_SIZE)
                            if first {
                                path.move(to: pixel)
                                first = false
                            } else {
                                path.addLine(to: pixel)
                            }
                           
                        }
                        
                        path.lineWidth = 4
                        NavigationalWarning.color.setStroke()
                        path.stroke()
                    }
                }
            }
        }
        
        return images
    }
    
    static func geoDesicPolygon(from polygon: MKPolygon) -> MKGeodesicPolyline {
        print("**** making geoDesic polygon")
        // connect first and last points
        let points = UnsafeMutablePointer<MKMapPoint>.allocate(capacity: polygon.pointCount + 1)
        points.initialize(from: polygon.points(), count: polygon.pointCount)
        points.advanced(by: polygon.pointCount).initialize(from: polygon.points(), count: 1)
        
        for point in UnsafeBufferPointer(start: points, count: polygon.pointCount+1) {
            print("**** Point - lat: \(point.coordinate.latitude) - lon: \(point.coordinate.longitude)")
        }
        
        // create geodesic polyline bordering the polygon
        let gp = MKGeodesicPolyline(points: points, count: polygon.pointCount + 1)
        return gp
    }
    
    static func geoDesicClickAreas(from polygon: MKPolygon) -> [MKGeodesicPolyline] {
        print("**** making geoDesic clickArea")
        var gp: [MKGeodesicPolyline] = []
        // connect first and last points
        let points = UnsafeMutablePointer<MKMapPoint>.allocate(capacity: polygon.pointCount + 1)
        points.initialize(from: polygon.points(), count: polygon.pointCount)
        points.advanced(by: polygon.pointCount).initialize(from: polygon.points(), count: 1)
        
        // create geodesic polyline bordering the polygon
        gp.append(MKGeodesicPolyline(points: points, count: polygon.pointCount + 1))
        
        // check for meridian/antimeridian crossing
        // compare polarity of each point to the previous
        // if there is a change, add the checked points to the end and make another polygon
        let safePoints = Array<MKMapPoint>(UnsafeBufferPointer(start: polygon.points(), count: polygon.pointCount))
        
        var crossesAtIndex = -1
        var isFirstPointPositive = true
        for (i, point) in safePoints.enumerated() {
            let isCurrentPointPositive = point.coordinate.longitude > 0
            if(i==0) {
                isFirstPointPositive = isCurrentPointPositive
            } else if (isCurrentPointPositive != isFirstPointPositive){
                crossesAtIndex = i
                break
            }
        }
        
        if(crossesAtIndex > -1){
            var reorderedPoints: [MKMapPoint] = safePoints.dropFirst(crossesAtIndex) + safePoints.dropLast(safePoints.count - crossesAtIndex)
            reorderedPoints.append(reorderedPoints[0])
            gp.append(MKGeodesicPolyline(points: reorderedPoints, count: reorderedPoints.count))
        }
        
        return gp
    }
}
