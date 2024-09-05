//
//  LightCircle.swift
//  Marlin
//
//  Created by Daniel Barela on 7/8/22.
//

import Foundation
import UIKit

struct LightSector {
    var startDegrees: Double
    var endDegrees: Double
    var color: UIColor
    var text: String
}

class LightImage: DataSourceImage {
    var feature: SFGeometry?
    var light: LightModel

    static var dataSource: any DataSourceDefinition = DataSources.light

    init(light: LightModel) {
        self.light = light
        feature = light.sfGeometry
    }

    func image(
        context: CGContext?,
        zoom: Int,
        tileBounds: MapBoundingBox,
        tileSize: Double
    ) -> [UIImage] {
        let images = mapImage(zoomLevel: zoom, tileBounds3857: tileBounds, context: context)
        for image in images {
            drawImageIntoTile(
                mapImage: image,
                latitude: light.latitude,
                longitude: light.longitude,
                tileBounds3857: tileBounds,
                tileSize: tileSize
            )
        }

        return images
    }

    func mapImage(
        marker: Bool = false,
        zoomLevel: Int,
        tileBounds3857: MapBoundingBox? = nil,
        context: CGContext? = nil
    ) -> [UIImage] {
        let TILE_SIZE = 512.0
        var images: [UIImage] = []

        if UserDefaults.standard.actualRangeSectorLights,
            let tileBounds3857 = tileBounds3857,
           let lightSectors = light.lightSectors {
            // if any sectors have no range, just make a sector image
            if lightSectors.contains(where: { sector in
                sector.range == nil
            }) {
                images.append(
                    contentsOf: LightImage.image(
                        light: light,
                        zoomLevel: zoomLevel,
                        tileBounds3857: tileBounds3857))
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
        } else if light.lightSectors == nil,
                    UserDefaults.standard.actualRangeLights,
                  let stringRange = light.range,
                  let range = Double(stringRange),
                  let tileBounds3857 = tileBounds3857,
                  let lightColors = light.lightColors {
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
            images.append(
                contentsOf: LightImage.image(
                    light: light,
                    zoomLevel: zoomLevel,
                    tileBounds3857: tileBounds3857))
        }

        return images
    }

    func actualSizeSectorLight(
        lightSectors: [ImageSector],
        zoomLevel: Int,
        tileBounds3857: MapBoundingBox,
        context: CGContext
    ) {
        let TILE_SIZE = 512.0
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
            let circleCoordinates = light.coordinate.circleCoordinates(
                radiusMeters: metersMeasurement.value,
                startDegrees: sector.startDegrees + 90.0,
                endDegrees: sector.endDegrees + 90.0)
            let path = UIBezierPath()

            var pixel = light.coordinate.toPixel(
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
        context: CGContext
    ) {
        let TILE_SIZE = 512.0
        let nauticalMilesMeasurement = NSMeasurement(doubleValue: range, unit: UnitLength.nauticalMiles)
        let metersMeasurement = nauticalMilesMeasurement.converting(to: UnitLength.meters)

        let circleCoordinates = light.coordinate.circleCoordinates(radiusMeters: metersMeasurement.value)
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
        pixel = light.coordinate.toPixel(zoomLevel: zoomLevel, tileBounds3857: tileBounds3857, tileSize: TILE_SIZE)
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

    static func image(light: LightModel, zoomLevel: Int, tileBounds3857: MapBoundingBox? = nil) -> [UIImage] {
        var images: [UIImage] = []
        
        let radius = CGFloat(zoomLevel) / 3.0 * UIScreen.main.scale * DataSources.light.imageScale

        // if the zoom level is greater than 12 draw the structure
        if zoomLevel > 12 && light.isBuoy {
            if let structureImage = StructureImage(
                frame: CGRect(x: 0, y: 0, width: 3 * radius, height: 3 * radius),
                structure: light.structure) {
                images.append(structureImage)
            }
        }
        
        if light.isFogSignal {
            if let fogSignalImage = FogSignalImage(
                frame: CGRect(x: 0, y: 0, width: 5 * radius, height: 5 * radius),
                arcWidth: min(3, radius / 3.0),
                drawArcs: zoomLevel > 8) {
                images.append(fogSignalImage)
            }
        }
        
        // draw the sectors starting at zoom level 8
        if zoomLevel > 7, let lightSectors = light.lightSectors {
            if let sectorImage = sectorImage(light: light, lightSectors: lightSectors, scale: 1, zoomLevel: zoomLevel) {
                images.append(sectorImage)
            }
        } else if let lightColors = light.lightColors {
            // otherwise just draw the colors
            if let colorImage = colorImage(light: light, lightColors: lightColors, scale: 1, zoomLevel: zoomLevel) {
                images.append(colorImage)
            }
        }
        
        if light.isRacon {
            if let raconImage = raconImage(
                light: light,
                scale: 1,
                sectors: light.azimuthCoverage,
                zoomLevel: zoomLevel) {
                images.append(raconImage)
            }
        }
        
        return images
    }
    
    static func sectorImage(light: LightModel, lightSectors: [ImageSector], scale: Int, zoomLevel: Int) -> UIImage? {
        let radius = CGFloat(zoomLevel) / 3.0 * UIScreen.main.scale * DataSources.light.imageScale
        - ((CGFloat(light.characteristicNumber ?? 0) - 1.0) * 2)
        if zoomLevel > 7 {
            return CircleImage(
                suggestedFrame: CGRect(x: 0, y: 0, width: 40 * radius, height: 40 * radius),
                sectors: lightSectors,
                radius: 8 * radius,
                fill: false,
                arcWidth: radius * 0.75)
        } else {
            var sectors: [ImageSector] = []
            if let lightColors = light.lightColors {
                var count = 0
                let degreesPerColor = 360.0 / CGFloat(lightColors.count)
                for color in lightColors {
                    sectors.append(ImageSector(
                        startDegrees: degreesPerColor * CGFloat(count),
                        endDegrees: degreesPerColor * (CGFloat(count) + 1.0),
                        color: color))
                    count += 1
                }
            }
            return CircleImage(
                suggestedFrame: CGRect(x: 0, y: 0, width: radius, height: radius),
                sectors: sectors,
                fill: true,
                sectorSeparator: false)
        }
    }
    
    static func colorImage(light: LightModel, lightColors: [UIColor], scale: Int, zoomLevel: Int) -> UIImage? {
        let radius = CGFloat(zoomLevel) / 3.0 * UIScreen.main.scale * DataSources.light.imageScale

        // if zoom level greater than 12, draw the light more detailed, otherwise, draw a dot
        if zoomLevel > 12 {
            return LightColorImage(
                frame: CGRect(x: 0, y: 0, width: 4 * radius, height: 4 * radius),
                colors: lightColors,
                arcWidth: 3.0,
                darkMode: false)
        } else {
            var sectors: [ImageSector] = []
            var count = 0
            let degreesPerColor = 360.0 / CGFloat(lightColors.count)
            for color in lightColors {
                sectors.append(ImageSector(
                    startDegrees: degreesPerColor * CGFloat(count),
                    endDegrees: degreesPerColor * (CGFloat(count) + 1.0),
                    color: color))
                count += 1
            }
            return CircleImage(
                suggestedFrame: CGRect(x: 0, y: 0, width: radius, height: radius),
                sectors: sectors,
                fill: true,
                sectorSeparator: false)
        }
    }
    
    static func raconImage(light: LightModel, scale: Int, sectors: [ImageSector]? = nil, zoomLevel: Int) -> UIImage? {
        let radius = CGFloat(zoomLevel) / 3.0 * UIScreen.main.scale * DataSources.light.imageScale

        if zoomLevel > 10 {
            return RaconImage(
                frame: CGRect(x: 0, y: 0, width: 3 * (radius + 3.0), height: 3 * (radius + 3.0)),
                sectors: sectors,
                arcWidth: 3.0,
                arcRadius: radius + 3.0,
                text: "Racon (\(light.morseLetter))\n\(light.remarks?.replacingOccurrences(of: "\n", with: "") ?? "")",
                darkMode: false)
        } else {
            return CircleImage(color: Light.raconColor, radius: radius, fill: false, arcWidth: min(3.0, radius / 2.0))
        }
    }
}

class LightColorImage: UIImage {
    
    convenience init?(
        frame: CGRect,
        colors: [UIColor],
        arcWidth: CGFloat? = nil,
        outerStroke: Bool = true,
        arcRadius: CGFloat? = nil,
        drawTower: Bool = true,
        darkMode: Bool = false) {
        let strokeWidth = 0.5
        let rect = frame
        let radius = arcRadius ?? min(rect.width / 2.0, rect.height / 2.0) - ((arcWidth ?? strokeWidth) / 2.0)
        let wholeColor = UIColor.lightGray
        let diameter = radius * 2.0
        
        let renderer = UIGraphicsImageRenderer(size: frame.size)
        let image = renderer.image { _ in
            // Fill full circle with wholeColor
            if arcWidth == nil {
                if outerStroke {

                    wholeColor.setStroke()
                    let outerBoundary = UIBezierPath(
                        ovalIn: CGRect(x: strokeWidth / 2.0, y: strokeWidth / 2.0, width: diameter, height: diameter ))
                    outerBoundary.lineWidth = strokeWidth
                    outerBoundary.stroke()
                }
            }
            
            let center = CGPoint(x: rect.width / 2.0, y: rect.height / 2.0)
            var count = 0
            let degreesPerColor = 360.0 / CGFloat(colors.count)
            for color in colors {
                let startAngle = degreesPerColor * CGFloat(count) * (CGFloat.pi / 180.0)
                let endAngle = degreesPerColor * (CGFloat(count) + 1.0) * (CGFloat.pi / 180.0)
                let piePath = UIBezierPath()
                piePath.addArc(withCenter: center, radius: radius,
                               startAngle: startAngle, endAngle: endAngle,
                               clockwise: true)

                if let arcWidth = arcWidth {
                    piePath.lineWidth = arcWidth
                    color.setStroke()
                    piePath.stroke()
                    if drawTower {
                        let towerLine = UIBezierPath()
                        towerLine.move(to: center)
                        
                        towerLine.addLine(to: CGPoint(x: center.x, y: center.y - radius))
                        towerLine.lineWidth = arcWidth
                        towerLine.stroke()
                    }
                } else {
                    piePath.close()
                    color.setFill()
                    piePath.fill()
                }
                count += 1
            }
        }
        
        guard  let cgImage = image.cgImage else {
            return nil
        }
        self.init(cgImage: cgImage)
        
    }
}
