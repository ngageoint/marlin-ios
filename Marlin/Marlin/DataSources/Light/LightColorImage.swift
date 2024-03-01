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
        let images = light.mapImage(zoomLevel: zoom, tileBounds3857: tileBounds, context: context)
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
