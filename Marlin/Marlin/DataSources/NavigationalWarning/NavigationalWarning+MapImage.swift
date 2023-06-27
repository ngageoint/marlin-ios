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
                            let circleCoordinates = circleCoordinates(center: coordinate, radiusMeters: distance)
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
                        images.append(contentsOf: defaultMapImage(marker: marker, zoomLevel: zoomLevel, tileBounds3857: tileBounds3857, context: context, tileSize: 512.0))
                    } else if let polygon = shape as? MKPolygon {
                        let points = polygon.points()
                        let path = UIBezierPath()
                        var firstPoint: CLLocationCoordinate2D?
                        var previousPoint: CLLocationCoordinate2D?
                        for point in UnsafeBufferPointer(start: points, count: polygon.pointCount) {
                            
                            let pixel = point.coordinate.toPixel(zoomLevel: zoomLevel, tileBounds3857: tileBounds3857, tileSize: TILE_SIZE)
                            // make a geodesic line between the points and then plot that
                            if let previousPoint = previousPoint {
                                var coords: [CLLocationCoordinate2D] = [previousPoint, point.coordinate]
                                let gl = MKGeodesicPolyline(coordinates: &coords, count: 2)
                                
                                let glpoints = gl.points()
                                
                                for point in UnsafeBufferPointer(start: glpoints, count: gl.pointCount) {
                                    
                                    let pixel = point.coordinate.toPixel(zoomLevel: zoomLevel, tileBounds3857: tileBounds3857, tileSize: TILE_SIZE)
                                    path.addLine(to: pixel)
                                    
                                }
                            } else {
                                firstPoint = point.coordinate
                                path.move(to: pixel)
                            }
                            previousPoint = point.coordinate
                            
                        }
                        
                        // now draw the geodesic line between the last and the first
                        if let previousPoint = previousPoint, let firstPoint = firstPoint {
                            var coords: [CLLocationCoordinate2D] = [previousPoint, firstPoint]
                            let gl = MKGeodesicPolyline(coordinates: &coords, count: 2)
                            
                            let glpoints = gl.points()
                            
                            for point in UnsafeBufferPointer(start: glpoints, count: gl.pointCount) {
                                
                                let pixel = point.coordinate.toPixel(zoomLevel: zoomLevel, tileBounds3857: tileBounds3857, tileSize: TILE_SIZE)
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
    
    func circleCoordinates(center: CLLocationCoordinate2D, radiusMeters: Double, startDegrees: Double = 0.0, endDegrees: Double = 360.0) -> [CLLocationCoordinate2D] {
        var coordinates: [CLLocationCoordinate2D] = []
        let centerLatRad = toRadians(degrees: center.latitude)
        let centerLonRad = toRadians(degrees: center.longitude)
        let dRad = radiusMeters / 6378137
        
        let radial = toRadians(degrees: Double(startDegrees))
        let latRad = asin(sin(centerLatRad) * cos(dRad) + cos(centerLatRad) * sin(dRad) * cos(radial))
        let dlonRad = atan2(sin(radial) * sin(dRad) * cos(centerLatRad), cos(dRad) - sin(centerLatRad) * sin(latRad))
        let lonRad = fmod((centerLonRad + dlonRad + .pi), 2.0 * .pi) - .pi
        coordinates.append(CLLocationCoordinate2D(latitude: toDegrees(radians: latRad), longitude: toDegrees(radians: lonRad)))
        
        if startDegrees >= endDegrees {
            // this could be an error in the data, or sometimes lights are defined as follows:
            // characteristic Q.W.R.
            // remarks R. 289°-007°, W.-007°.
            // that would mean this light flashes between red and white over those angles
            // TODO: figure out what to do with multi colored lights over the same sector
            return coordinates
        }
        for i in Int(startDegrees)...Int(endDegrees) {
            let radial = toRadians(degrees: Double(i))
            let latRad = asin(sin(centerLatRad) * cos(dRad) + cos(centerLatRad) * sin(dRad) * cos(radial))
            let dlonRad = atan2(sin(radial) * sin(dRad) * cos(centerLatRad), cos(dRad) - sin(centerLatRad) * sin(latRad))
            let lonRad = fmod((centerLonRad + dlonRad + .pi), 2.0 * .pi) - .pi
            coordinates.append(CLLocationCoordinate2D(latitude: toDegrees(radians: latRad), longitude: toDegrees(radians: lonRad)))
        }
        
        let endRadial = toRadians(degrees: Double(endDegrees))
        let endLatRad = asin(sin(centerLatRad) * cos(dRad) + cos(centerLatRad) * sin(dRad) * cos(endRadial))
        let endDlonRad = atan2(sin(endRadial) * sin(dRad) * cos(centerLatRad), cos(dRad) - sin(centerLatRad) * sin(endLatRad))
        let endLonRad = fmod((centerLonRad + endDlonRad + .pi), 2.0 * .pi) - .pi
        coordinates.append(CLLocationCoordinate2D(latitude: toDegrees(radians: endLatRad), longitude: toDegrees(radians: endLonRad)))
        
        return coordinates
    }
    
    func toRadians(degrees: Double) -> Double {
        return degrees * .pi / 180.0
    }
    
    func toDegrees(radians: Double) -> Double {
        return radians * 180.0 / .pi
    }
}
