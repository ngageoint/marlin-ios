//
//  LightProtocol.swift
//  Marlin
//
//  Created by Daniel Barela on 10/14/22.
//

import Foundation
import UIKit
import MapKit

protocol LightProtocol {
    var volumeNumber: String? { get set }
    var featureNumber: String? { get set }
    var characteristicNumber: Int64 { get set }
    var noticeWeek: String? { get set }
    var noticeYear: String? { get set }
    var latitude: Double { get set }
    var longitude: Double { get set }
    var remarks: String? { get set }
    var characteristic: String? { get set }
    var range: String? { get set }
    var structure: String? { get set }
    var name: String? { get set }
    
    var lightColors: [UIColor]? { get }
    var isBuoy: Bool { get }
    var isLight: Bool { get }
    var isRacon: Bool { get }
    var isFogSignal: Bool { get }
    
    var azimuthCoverage: [ImageSector]? { get }
    var morseCode: String? { get }
    var morseLetter: String { get }
}

extension LightProtocol {
    
    var morseCode: String? {
        guard !isLight, let characteristic = characteristic, let leftParen = characteristic.firstIndex(of: "("), let lastIndex = characteristic.lastIndex(of: ")") else {
            return nil
        }
        
        let firstIndex = characteristic.index(after: leftParen)
        return "\(String(characteristic[firstIndex..<lastIndex]))"
    }
    
    var morseLetter: String {
        if isLight {
            return ""
        }
        if let first = characteristic?.first {
            return String(first)
        }
        return ""
    }
    
    var azimuthCoverage: [ImageSector]? {
        guard let remarks = remarks else {
            return nil
        }
        var sectors: [ImageSector] = []
        //        Azimuth coverage 270^-170^.
        let pattern = #"(?<azimuth>(Azimuth coverage)?).?((?<startdeg>(\d*))\°)?((?<startminutes>[0-9]*)[\`'])?(-(?<enddeg>(\d*))\°)?(?<endminutes>[0-9]*)[\`']?\..*"#
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let nsrange = NSRange(remarks.startIndex..<remarks.endIndex,
                              in: remarks)
        var previousEnd: Double = 0.0
        
        regex?.enumerateMatches(in: remarks, range: nsrange, using: { match, flags, stop in
            guard let match = match else {
                return
            }
            var end: Double = 0.0
            var start: Double?
            for component in ["startdeg", "startminutes", "enddeg", "endminutes"] {
                
                
                let nsrange = match.range(withName: component)
                if nsrange.location != NSNotFound,
                   let range = Range(nsrange, in: remarks)
                {
                    if component == "startdeg" {
                        if start != nil {
                            start = start! + ((Double(remarks[range]) ?? 0.0) + 90)
                        } else {
                            start = (Double(remarks[range]) ?? 0.0) + 90
                        }
                    } else if component == "startminutes" {
                        if start != nil {
                            start = start! + (Double(remarks[range]) ?? 0.0) / 60
                        } else {
                            start = (Double(remarks[range]) ?? 0.0) / 60
                        }
                    } else if component == "enddeg" {
                        end = (Double(remarks[range]) ?? 0.0) + 90
                    } else if component == "endminutes" {
                        end += (Double(remarks[range]) ?? 0.0) / 60
                    }
                }
            }
            if let start = start {
                sectors.append(ImageSector(startDegrees: start, endDegrees: end, color: Light.raconColor))
            } else {
                if end <= previousEnd {
                    end += 360
                }
                sectors.append(ImageSector(startDegrees: previousEnd, endDegrees: end, color: Light.raconColor))
            }
            previousEnd = end
        })
        if sectors.isEmpty {
            return nil
        }
        return sectors
    }
    
    var isFogSignal: Bool {
        guard let remarks = remarks else {
            return false
        }
        return remarks.lowercased().contains("bl.")
    }
    
    var isLight: Bool {
        guard let name = self.name else {
            return false
        }
        let remarks = remarks ?? ""
        return !name.contains("RACON") && !remarks.contains("(3 & 10cm)")
    }
    
    var isRacon: Bool {
        guard let name = self.name else {
            return false
        }
        let remarks = remarks ?? ""
        return name.contains("RACON") || remarks.contains("(3 & 10cm)")
    }
    
    var isBuoy: Bool {
        let structure = structure ?? ""
        return structure.lowercased().contains("pillar") ||
        structure.lowercased().contains("spar") ||
        structure.lowercased().contains("conical") ||
        structure.lowercased().contains("can")
    }
    
    var lightColors: [UIColor]? {
        var lightColors: [UIColor] = []
        guard let characteristic = characteristic else {
            return nil
        }
        
        if characteristic.contains("W.") {
            lightColors.append(Light.whiteLight)
        }
        if characteristic.contains("R.") {
            lightColors.append(Light.redLight)
        }
        // why does green have so many variants without a .?
        if characteristic.contains("G.") || characteristic.contains("Oc.G") || characteristic.contains("G\n") || characteristic.contains("F.G") || characteristic.contains("Fl.G") || characteristic.contains("(G)") {
            lightColors.append(Light.greenLight)
        }
        if characteristic.contains("Y.") {
            lightColors.append(Light.yellowLight)
        }
        if characteristic.contains("Bu.") {
            lightColors.append(Light.blueLight)
        }
        if characteristic.contains("Vi.") {
            lightColors.append(Light.violetLight)
        }
        if characteristic.contains("Or.") {
            lightColors.append(Light.orangeLight)
        }
        
        if lightColors.isEmpty {
            if characteristic.lowercased().contains("lit") {
                lightColors.append(Light.whiteLight)
            }
        }
        
        if lightColors.isEmpty {
            return nil
        }
        return lightColors
    }
    
    var lightSectors: [ImageSector]? {
        guard let remarks = remarks else {
            return nil
        }
        var sectors: [ImageSector] = []
        
        let pattern = #"(?<visible>(Visible)?)(?<fullLightObscured>(bscured)?)((?<color>[A-Z]+)?)\.?(?<unintensified>(\(unintensified\))?)(?<obscured>(\(bscured\))?)( (?<startdeg>(\d*))°)?((?<startminutes>[0-9]*)[\`'])?(-(?<enddeg>(\d*))°)(?<endminutes>[0-9]*)[\`']?"#
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let nsrange = NSRange(remarks.startIndex..<remarks.endIndex,
                              in: remarks)
        var previousEnd: Double = 0.0
        
        var visibleSector: Bool = false
        
        regex?.enumerateMatches(in: remarks, range: nsrange, using: { match, flags, stop in
            guard let match = match else {
                return
            }
            var color: String = ""
            var end: Double = 0.0
            var start: Double?
            var visibleColor: UIColor?
            var obscured: Bool = false
            var fullLightObscured: Bool = false
            for component in ["visible", "fullLightObscured", "color", "unintensified", "obscured", "startdeg", "startminutes", "enddeg", "endminutes"] {
                
                
                let nsrange = match.range(withName: component)
                if nsrange.location != NSNotFound,
                   let range = Range(nsrange, in: remarks),
                   !range.isEmpty
                {
                    if component == "visible" {
                        visibleSector = true
                        visibleColor = lightColors?[0]
                    } else if component == "fullLightObscured" {
                        visibleColor = lightColors?[0]
                        fullLightObscured = true
                    } else if component == "color" {
                        color = "\(remarks[range])"
                    } else if component == "obscured" {
                        obscured = true
                    } else if component == "startdeg" {
                        if start != nil {
                            start = start! + (Double(remarks[range]) ?? 0.0) + 90.0
                        } else {
                            start = (Double(remarks[range]) ?? 0.0) + 90.0
                        }
                    } else if component == "startminutes" {
                        if start != nil {
                            start = start! + (Double(remarks[range]) ?? 0.0) / 60
                        } else {
                            start = (Double(remarks[range]) ?? 0.0) / 60
                        }
                    } else if component == "enddeg" {
                        end = (Double(remarks[range]) ?? 0.0) + 90.0
                    } else if component == "endminutes" {
                        end += (Double(remarks[range]) ?? 0.0) / 60
                    }
                }
            }
            let uicolor: UIColor = {
                if obscured || fullLightObscured {
                    return visibleColor ?? (lightColors?[0] ?? .black)
                } else if color == "W" {
                    return Light.whiteLight
                } else if color == "R" {
                    return Light.redLight
                } else if color == "G" {
                    return Light.greenLight
                } else if color == "Y" {
                    return Light.yellowLight
                }
                return visibleColor ?? (lightColors?[0] ?? UIColor.clear)
            }()
            var sectorRange: Double? = nil
            if let rangeString = range {
                for split in rangeString.components(separatedBy: CharacterSet(charactersIn: ";\n")) {
                    if split.trimmingCharacters(in: .whitespacesAndNewlines).starts(with: color) {
                        let pattern = #"[0-9]+$"#
                        let regex = try? NSRegularExpression(pattern: pattern, options: [])
                        let rangePart = "\(split)".trimmingCharacters(in: .whitespacesAndNewlines)
                        let match = regex?.firstMatch(in: rangePart, range: NSRange(rangePart.startIndex..<rangePart.endIndex, in: rangePart))
                        
                        if let nsrange = match?.range, nsrange.location != NSNotFound,
                           let matchRange = Range(nsrange, in: rangePart),
                           !matchRange.isEmpty
                        {
                            let colorRange = rangePart[matchRange]
                            if !colorRange.isEmpty {
                                sectorRange = Double(colorRange)
                            }
                        }
                    }
                }
            }
            if let start = start {
                if end < start {
                    end += 360
                }
                sectors.append(ImageSector(startDegrees: start, endDegrees: end, color: uicolor, text: color, obscured: obscured || fullLightObscured, range: sectorRange))
            } else {
                if end <= previousEnd {
                    end += 360
                }
                sectors.append(ImageSector(startDegrees: previousEnd, endDegrees: end, color: uicolor, text: color, obscured: obscured || fullLightObscured, range: sectorRange))
            }
            if fullLightObscured && !visibleSector {
                // add the sector for the part of the light which is not obscured
                sectors.append(ImageSector(startDegrees: end, endDegrees: (start ?? 0) + 360, color: visibleColor ?? (lightColors?[0] ?? UIColor.clear), range: sectorRange))
            }
            previousEnd = end
        })
        if sectors.isEmpty {
            return nil
        }
        return sectors
    }
}

protocol LightMapViewModelProtocol: LightProtocol, MapImage, DataSourceLocation {
    
}

extension LightMapViewModelProtocol {
    func mapImage(marker: Bool = false, zoomLevel: Int, tileBounds3857: MapBoundingBox? = nil, context: CGContext? = nil) -> [UIImage] {
        var images: [UIImage] = []
        
        if UserDefaults.standard.actualRangeSectorLights, let tileBounds3857 = tileBounds3857, let lightSectors = lightSectors {
            // if any sectors have no range, just make a sector image
            if lightSectors.contains(where: { sector in
                sector.range == nil
            }) {
                images.append(contentsOf: LightImage.image(light: self, zoomLevel: zoomLevel, tileBounds3857: tileBounds3857))
            } else {
                
                if context == nil {
                    let size = CGSize(width: TILE_SIZE, height: TILE_SIZE)
                    UIGraphicsBeginImageContext(size)
                }
                if let context: CGContext = context ?? UIGraphicsGetCurrentContext() {
                    actualSizeSectorLight(lightSectors: lightSectors, zoomLevel: zoomLevel, tileBounds3857: tileBounds3857, context: context)
                }
            }
        } else if lightSectors == nil, UserDefaults.standard.actualRangeLights, let stringRange = range, let range = Double(stringRange), let tileBounds3857 = tileBounds3857, let lightColors = lightColors {
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
            if sector.obscured {
                continue
            }
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
            let circleCoordinates = coordinate.circleCoordinates(radiusMeters: metersMeasurement.value, startDegrees: sector.startDegrees + 90.0, endDegrees: sector.endDegrees + 90.0)
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
        
        let circleCoordinates = coordinate.circleCoordinates(radiusMeters: metersMeasurement.value)
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
}
