//
//  Light+MapImage.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import UIKit
import CoreLocation

extension Light: MapImage {
        
    static var cacheTiles: Bool = true
    
    func mapImage(marker: Bool = false, zoomLevel: Int, tileBounds3857: MapBoundingBox? = nil, context: CGContext? = nil) -> [UIImage] {
        var images: [UIImage] = []
        
        if UserDefaults.standard.actualRangeSectorLights, let tileBounds3857 = tileBounds3857, let lightSectors = lightSectors {
            if context == nil {
                let size = CGSize(width: TILE_SIZE, height: TILE_SIZE)
                UIGraphicsBeginImageContext(size)
            }
            if let context: CGContext = context ?? UIGraphicsGetCurrentContext() {
                actualSizeSectorLight(lightSectors: lightSectors, zoomLevel: zoomLevel, tileBounds3857: tileBounds3857, context: context)
            }
        } else if UserDefaults.standard.actualRangeLights, let stringRange = range, let range = Double(stringRange), let tileBounds3857 = tileBounds3857, let lightColors = lightColors {
            if context == nil {
                let size = CGSize(width: TILE_SIZE, height: TILE_SIZE)
                UIGraphicsBeginImageContext(size)
            }
            if let context: CGContext = context ?? UIGraphicsGetCurrentContext() {
                actualSizeNonSectorLight(lightColors: lightColors, range: range, zoomLevel: zoomLevel, tileBounds3857: tileBounds3857, context: context)
            }
        } else {
            images.append(contentsOf: LightImage.image(light: self, zoomLevel: zoomLevel, tileBounds3857: tileBounds3857))
        }
        
        return images
    }
    
    func actualSizeSectorLight(lightSectors: [ImageSector], zoomLevel: Int, tileBounds3857: MapBoundingBox, context: CGContext) {
        for sector in lightSectors.sorted(by: { one, two in
            return one.range ?? 0.0 < two.range ?? 0.0
        }) {
            let nauticalMilesMeasurement = NSMeasurement(doubleValue: sector.range ?? 0.0, unit: UnitLength.nauticalMiles)
            let metersMeasurement = nauticalMilesMeasurement.converting(to: UnitLength.meters)
            if sector.startDegrees >= sector.endDegrees {
                // this could be an error in the data, or sometimes lights are defined as follows:
                // characteristic Q.W.R.
                // remarks R. 289°-007°, W.-007°.
                // that would mean this light flashes between red and white over those angles
                // TODO: figure out what to do with multi colored lights over the same sector
                continue
            }
            let circleCoordinates = circleCoordinates(center: self.coordinate, radiusMeters: metersMeasurement.value, startDegrees: sector.startDegrees + 90.0, endDegrees: sector.endDegrees + 90.0)
            let path = UIBezierPath()
            
            var pixel = self.coordinate.toPixel(zoomLevel: zoomLevel, tileBounds3857: tileBounds3857, tileSize: TILE_SIZE)
            path.move(to: pixel)
            for circleCoordinate in circleCoordinates {
                pixel = circleCoordinate.toPixel(zoomLevel: zoomLevel, tileBounds3857: tileBounds3857, tileSize: TILE_SIZE)
                path.addLine(to: pixel)
            }
            path.close()
            sector.color.withAlphaComponent(0.1).setFill()
            sector.color.setStroke()
            path.lineWidth = 5
            
            path.fill()
            path.stroke()
        }
    }
    
    func actualSizeNonSectorLight(lightColors: [UIColor], range: Double, zoomLevel: Int, tileBounds3857: MapBoundingBox, context: CGContext) {
        let nauticalMilesMeasurement = NSMeasurement(doubleValue: range, unit: UnitLength.nauticalMiles)
        let metersMeasurement = nauticalMilesMeasurement.converting(to: UnitLength.meters)
        
        let circleCoordinates = circleCoordinates(center: self.coordinate, radiusMeters: metersMeasurement.value)
        let path = UIBezierPath()
        
        var pixel = circleCoordinates[0].toPixel(zoomLevel: zoomLevel, tileBounds3857: tileBounds3857, tileSize: TILE_SIZE)
        path.move(to: pixel)
        for circleCoordinate in circleCoordinates {
            pixel = circleCoordinate.toPixel(zoomLevel: zoomLevel, tileBounds3857: tileBounds3857, tileSize: TILE_SIZE)
            path.addLine(to: pixel)
        }
        path.lineWidth = 4
        path.close()
        lightColors[0].withAlphaComponent(0.1).setFill()
        lightColors[0].setStroke()
        path.fill()
        path.stroke()
        
        // put a dot in the middle
        pixel = self.coordinate.toPixel(zoomLevel: zoomLevel, tileBounds3857: tileBounds3857, tileSize: TILE_SIZE)
        let radius = CGFloat(zoomLevel) / 3.0 * UIScreen.main.scale * 0.5
        let centerDot = UIBezierPath(arcCenter: pixel, radius: radius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        centerDot.lineWidth = 0.5
        centerDot.stroke()
        lightColors[0].setFill()
        centerDot.fill()
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
