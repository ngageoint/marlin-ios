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
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
        
    static var cacheTiles: Bool = true
    
    func mapImage(
        marker: Bool = false,
        zoomLevel: Int,
        tileBounds3857: MapBoundingBox? = nil,
        context: CGContext? = nil) -> [UIImage] {
        var images: [UIImage] = []
        
        if UserDefaults.standard.actualRangeSectorLights, 
            let tileBounds3857 = tileBounds3857,
            let lightSectors = lightSectors {
            // if any sectors have no range, just make a sector image
            if lightSectors.contains(where: { sector in
                sector.range == nil
            }) {
                images.append(contentsOf: LightImage.image(light: LightModel(light: self), zoomLevel: zoomLevel, tileBounds3857: tileBounds3857))
            } else {
                
                if context == nil {
                    let size = CGSize(width: TILE_SIZE, height: TILE_SIZE)
                    UIGraphicsBeginImageContext(size)
                }
                if let context: CGContext = context ?? UIGraphicsGetCurrentContext() {
                    actualSizeSectorLight(
                        lightSectors: lightSectors,
                        zoomLevel: zoomLevel,
                        tileBounds3857: tileBounds3857,
                        context: context)
                }
            }
        } else if lightSectors == nil, 
                    UserDefaults.standard.actualRangeLights,
                    let stringRange = range,
                    let range = Double(stringRange),
                    let tileBounds3857 = tileBounds3857,
                    let lightColors = lightColors {
            if context == nil {
                let size = CGSize(width: TILE_SIZE, height: TILE_SIZE)
                UIGraphicsBeginImageContext(size)
            }
            if let context: CGContext = context ?? UIGraphicsGetCurrentContext() {
                actualSizeNonSectorLight(
                    lightColors: lightColors,
                    range: range,
                    zoomLevel: zoomLevel,
                    tileBounds3857: tileBounds3857,
                    context: context)
            }
        } else {
            images.append(contentsOf: LightImage.image(
                light: LightModel(light: self),
                zoomLevel: zoomLevel,
                tileBounds3857: tileBounds3857))
        }
        
        return images
    }
    
    func actualSizeSectorLight(lightSectors: [ImageSector], zoomLevel: Int, tileBounds3857: MapBoundingBox, context: CGContext) {
        for sector in lightSectors.sorted(by: { one, two in
            return one.range ?? 0.0 < two.range ?? 0.0
        }) {
            if sector.obscured {
                continue
            }
            let nauticalMilesMeasurement = NSMeasurement(
                doubleValue: sector.range ?? 0.0,
                unit: UnitLength.nauticalMiles)
            let metersMeasurement = nauticalMilesMeasurement.converting(to: UnitLength.meters)
            if sector.startDegrees >= sector.endDegrees {
                // this could be an error in the data, or sometimes lights are defined as follows:
                // characteristic Q.W.R.
                // remarks R. 289°-007°, W.-007°.
                // that would mean this light flashes between red and white over those angles
                // TODO: figure out what to do with multi colored lights over the same sector
                continue
            }
            let circleCoordinates = coordinate.circleCoordinates(
                radiusMeters: metersMeasurement.value,
                startDegrees: sector.startDegrees + 90.0,
                endDegrees: sector.endDegrees + 90.0)
            let path = UIBezierPath()
            
            var pixel = self.coordinate.toPixel(
                zoomLevel: zoomLevel,
                tileBounds3857: tileBounds3857,
                tileSize: TILE_SIZE)
            path.move(to: pixel)
            for circleCoordinate in circleCoordinates {
                pixel = circleCoordinate.toPixel(
                    zoomLevel: zoomLevel,
                    tileBounds3857: tileBounds3857,
                    tileSize: TILE_SIZE)
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
    
    func actualSizeNonSectorLight(
        lightColors: [UIColor],
        range: Double,
        zoomLevel: Int,
        tileBounds3857: MapBoundingBox,
        context: CGContext) {
        let nauticalMilesMeasurement = NSMeasurement(doubleValue: range, unit: UnitLength.nauticalMiles)
        let metersMeasurement = nauticalMilesMeasurement.converting(to: UnitLength.meters)
        
        let circleCoordinates = coordinate.circleCoordinates(radiusMeters: metersMeasurement.value)
        let path = UIBezierPath()
        
        var pixel = circleCoordinates[0].toPixel(
            zoomLevel: zoomLevel,
            tileBounds3857: tileBounds3857,
            tileSize: TILE_SIZE)
        path.move(to: pixel)
        for circleCoordinate in circleCoordinates {
            pixel = circleCoordinate.toPixel(
                zoomLevel: zoomLevel,
                tileBounds3857: tileBounds3857,
                tileSize: TILE_SIZE)
            path.addLine(to: pixel)
        }
        path.lineWidth = 4
        path.close()
        lightColors[0].withAlphaComponent(0.1).setFill()
        lightColors[0].setStroke()
        path.fill()
        path.stroke()
        
        // put a dot in the middle
        pixel = self.coordinate.toPixel(
            zoomLevel: zoomLevel,
            tileBounds3857: tileBounds3857,
            tileSize: TILE_SIZE)
        let radius = CGFloat(zoomLevel) / 3.0 * UIScreen.main.scale * 0.5
        let centerDot = UIBezierPath(
            arcCenter: pixel,
            radius: radius,
            startAngle: 0,
            endAngle: 2 * CGFloat.pi,
            clockwise: true)
        centerDot.lineWidth = 0.5
        centerDot.stroke()
        lightColors[0].setFill()
        centerDot.fill()
    }
}
