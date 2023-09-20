//
//  LightProtocol.swift
//  Marlin
//
//  Created by Daniel Barela on 10/14/22.
//

import Foundation
import UIKit
import MapKit
import GeoJSON

class LightModel: NSObject, Locatable, Identifiable, Bookmarkable {
    var canBookmark: Bool = false
    var id: String { self.itemKey }
    var itemTitle: String {
        return "\(self.name ?? "")"
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var light: Light?
    var lightProperties: LightsProperties?
    
    var aidType: String?
    var characteristic: String?
    var characteristicNumber: Int64?
    var deleteFlag: String?
    var featureNumber: String?
    var geopoliticalHeading: String?
    var heightFeet: Float?
    var heightMeters: Float?
    var internationalFeature: String?
    var latitude: Double
    var longitude: Double
    var mgrs10km: String?
    var name: String?
    var noticeNumber: Int64?
    var noticeWeek: String?
    var noticeYear: String?
    var position: String?
    var postNote: String?
    var precedingNote: String?
    var range: String?
    var regionHeading: String?
    var remarks: String?
    var removeFromList: String?
    var sectionHeader: String?
    var structure: String?
    var subregionHeading: String?
    var volumeNumber: String?
    
    init(light: Light) {
        self.light = light
        self.canBookmark = true
        self.aidType = light.aidType
        self.characteristic = light.characteristic
        self.characteristicNumber = light.characteristicNumber
        self.deleteFlag = light.deleteFlag
        self.featureNumber = light.featureNumber
        self.geopoliticalHeading = light.geopoliticalHeading
        self.heightFeet = light.heightFeet
        self.heightMeters = light.heightMeters
        self.internationalFeature = light.internationalFeature
        self.latitude = light.latitude
        self.longitude = light.longitude
        self.mgrs10km = light.mgrs10km
        self.name = light.name
        self.noticeNumber = light.noticeNumber
        self.noticeWeek = light.noticeWeek
        self.noticeYear = light.noticeYear
        self.position = light.position
        self.postNote = light.postNote
        self.precedingNote = light.precedingNote
        self.range = light.range
        self.regionHeading = light.regionHeading
        self.remarks = light.remarks
        self.removeFromList = light.removeFromList
        self.sectionHeader = light.sectionHeader
        self.structure = light.structure
        self.subregionHeading = light.subregionHeading
        self.volumeNumber = light.volumeNumber
    }
    
    init(lightProperties: LightsProperties) {
        self.lightProperties = lightProperties
        self.aidType = lightProperties.aidType
        self.characteristic = lightProperties.characteristic
        if let characteristicNumber = lightProperties.characteristicNumber {
            self.characteristicNumber = Int64(characteristicNumber)
        }
        self.deleteFlag = lightProperties.deleteFlag
        self.featureNumber = lightProperties.featureNumber
        self.geopoliticalHeading = lightProperties.geopoliticalHeading
        self.heightFeet = lightProperties.heightFeet
        self.heightMeters = lightProperties.heightMeters
        self.internationalFeature = lightProperties.internationalFeature
        self.latitude = lightProperties.latitude
        self.longitude = lightProperties.longitude
        self.mgrs10km = lightProperties.mgrs10km
        self.name = lightProperties.name
        if let noticeNumber = lightProperties.noticeNumber {
            self.noticeNumber = Int64(noticeNumber)
        }
        self.noticeWeek = lightProperties.noticeWeek
        self.noticeYear = lightProperties.noticeYear
        self.position = lightProperties.position
        self.postNote = lightProperties.postNote
        self.precedingNote = lightProperties.precedingNote
        self.range = lightProperties.range
        self.regionHeading = lightProperties.regionHeading
        self.remarks = lightProperties.remarks
        self.removeFromList = lightProperties.removeFromList
        self.sectionHeader = lightProperties.sectionHeader
        self.structure = lightProperties.structure
        self.subregionHeading = lightProperties.subregionHeading
        self.volumeNumber = lightProperties.volumeNumber
    }
    
    convenience init?(feature: Feature) {
        if let json = try? JSONEncoder().encode(feature.properties), let string = String(data: json, encoding: .utf8) {
            
            print(string)
            let decoder = JSONDecoder()
            print("json is \(string)")
            let jsonData = Data(string.utf8)
            if let ds = try? decoder.decode(LightsProperties.self, from: jsonData) {
                self.init(lightProperties: ds)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    init(characteristicNumber: Int64, structure: String? = nil, name: String? = nil, volumeNumber: String? = nil, featureNumber: String? = nil, noticeWeek: String? = nil, noticeYear: String? = nil, latitude: Double, longitude: Double, remarks: String? = nil, characteristic: String? = nil, range: String? = nil) {
        self.characteristicNumber = characteristicNumber
        self.structure = structure
        self.name = name
        self.volumeNumber = volumeNumber
        self.featureNumber = featureNumber
        self.noticeWeek = noticeWeek
        self.noticeYear = noticeYear
        self.latitude = latitude
        self.longitude = longitude
        self.remarks = remarks
        self.characteristic = characteristic
        self.range = range
    }
    
    func isEqualTo(_ other: LightModel) -> Bool {
        guard let otherShape = other as? Self else { return false }
        return self.light == otherShape.light
    }
    
    static func == (lhs: LightModel, rhs: LightModel) -> Bool {
        lhs.isEqualTo(rhs)
    }

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
    
    var expandedCharacteristic: String? {
        var expanded = characteristic
        expanded = expanded?.replacingOccurrences(of: "Al.", with: "Alternating ")
        expanded = expanded?.replacingOccurrences(of: "lt.", with: "Lit ")
        expanded = expanded?.replacingOccurrences(of: "bl.", with: "Blast ")
        expanded = expanded?.replacingOccurrences(of: "Mo.", with: "Morse code ")
        expanded = expanded?.replacingOccurrences(of: "Bu.", with: "Blue ")
        expanded = expanded?.replacingOccurrences(of: "min.", with: "Minute ")
        expanded = expanded?.replacingOccurrences(of: "Dir.", with: "Directional ")
        expanded = expanded?.replacingOccurrences(of: "obsc.", with: "Obscured ")
        expanded = expanded?.replacingOccurrences(of: "ec.", with: "Eclipsed ")
        expanded = expanded?.replacingOccurrences(of: "Oc.", with: "Occulting ")
        expanded = expanded?.replacingOccurrences(of: "ev.", with: "Every ")
        expanded = expanded?.replacingOccurrences(of: "Or.", with: "Orange ")
        expanded = expanded?.replacingOccurrences(of: "F.", with: "Fixed ")
        expanded = expanded?.replacingOccurrences(of: "Q.", with: "Quick Flashing ")
        expanded = expanded?.replacingOccurrences(of: "L.Fl.", with: "Long Flashing ")
        expanded = expanded?.replacingOccurrences(of: "Fl.", with: "Flashing ")
        expanded = expanded?.replacingOccurrences(of: "R.", with: "Red ")
        expanded = expanded?.replacingOccurrences(of: "fl.", with: "Flash ")
        expanded = expanded?.replacingOccurrences(of: "s.", with: "Seconds ")
        expanded = expanded?.replacingOccurrences(of: "G.", with: "Green ")
        expanded = expanded?.replacingOccurrences(of: "si.", with: "Silent ")
        expanded = expanded?.replacingOccurrences(of: "horiz.", with: "Horizontal ")
        expanded = expanded?.replacingOccurrences(of: "U.Q.", with: "Ultra Quick ")
        expanded = expanded?.replacingOccurrences(of: "flashing intes.", with: "Intensified ")
        expanded = expanded?.replacingOccurrences(of: "I.Q.", with: "Interrupted Quick ")
        expanded = expanded?.replacingOccurrences(of: "flashing unintens.", with: "Unintensified ")
        expanded = expanded?.replacingOccurrences(of: "vert.", with: "Vertical ")
        expanded = expanded?.replacingOccurrences(of: "Iso.", with: "Isophase ")
        expanded = expanded?.replacingOccurrences(of: "Vi.", with: "Violet ")
        expanded = expanded?.replacingOccurrences(of: "I.V.Q.", with: "Interrupted Very Quick Flashing ")
        expanded = expanded?.replacingOccurrences(of: "vis.", with: "Visible ")
        expanded = expanded?.replacingOccurrences(of: "V.Q.", with: "Very Quick ")
        expanded = expanded?.replacingOccurrences(of: "Km.", with: "Kilometer ")
        expanded = expanded?.replacingOccurrences(of: "W.", with: "White ")
        expanded = expanded?.replacingOccurrences(of: "Y.", with: "Yellow ")
        return expanded
    }
}

extension LightModel: DataSource {
    var color: UIColor {
        Self.color
    }
    var itemKey: String {
        return "\(featureNumber ?? "")--\(volumeNumber ?? "")--\(characteristicNumber ?? 0)"
    }
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }
    
    static var isMappable: Bool = true
    static var dataSourceName: String = NSLocalizedString("Lights", comment: "Lights data source display name")
    static var fullDataSourceName: String = NSLocalizedString("Lights", comment: "Lights data source display name")
    static var key: String = "light"
    static var metricsKey: String = "lights"
    static var imageName: String? = nil
    static var systemImageName: String? = "lightbulb.fill"
    static var color: UIColor = UIColor(argbValue: 0xFFFFC500)
    static var imageScale = UserDefaults.standard.imageScale(key) ?? 0.66
    
    static var defaultSort: [DataSourceSortParameter] = [DataSourceSortParameter(property:DataSourceProperty(name: "Region", key: #keyPath(Light.sectionHeader), type: .string), ascending: true), DataSourceSortParameter(property:DataSourceProperty(name: "Feature Number", key: #keyPath(Light.featureNumber), type: .int), ascending: true)]
    static var defaultFilter: [DataSourceFilterParameter] = []
    
    static var properties: [DataSourceProperty] = [
        DataSourceProperty(name: "Location", key: #keyPath(Light.mgrs10km), type: .location),
        DataSourceProperty(name: "Latitude", key: #keyPath(Light.latitude), type: .latitude),
        DataSourceProperty(name: "Longitude", key: #keyPath(Light.longitude), type: .longitude),
        DataSourceProperty(name: "Feature Number", key: #keyPath(Light.featureNumber), type: .string),
        DataSourceProperty(name: "International Feature Number", key: #keyPath(Light.internationalFeature), type: .string),
        DataSourceProperty(name: "Name", key: #keyPath(Light.name), type: .string),
        DataSourceProperty(name: "Structure", key: #keyPath(Light.structure), type: .string),
        DataSourceProperty(name: "Focal Plane Elevation (ft)", key: #keyPath(Light.heightFeet), type: .double),
        DataSourceProperty(name: "Focal Plane Elevation (m)", key: #keyPath(Light.heightMeters), type: .double),
        DataSourceProperty(name: "Range (nm)", key: #keyPath(Light.lightRange), type: .double, subEntityKey: #keyPath(LightRange.range)),
        DataSourceProperty(name: "Remarks", key: #keyPath(Light.remarks), type: .string),
        DataSourceProperty(name: "Characteristic", key: #keyPath(Light.characteristic), type: .string),
        DataSourceProperty(name: "Signal", key: #keyPath(Light.characteristic), type: .string),
        DataSourceProperty(name: "Notice Number", key: #keyPath(Light.noticeNumber), type: .int),
        DataSourceProperty(name: "Notice Week", key: #keyPath(Light.noticeWeek), type: .string),
        DataSourceProperty(name: "Notice Year", key: #keyPath(Light.noticeYear), type: .string),
        DataSourceProperty(name: "Volume Number", key: #keyPath(Light.volumeNumber), type: .string),
        DataSourceProperty(name: "Preceding Note", key: #keyPath(Light.precedingNote), type: .string),
        DataSourceProperty(name: "Post Note", key: #keyPath(Light.postNote), type: .string),
        DataSourceProperty(name: "Region", key: #keyPath(Light.sectionHeader), type: .string),
        DataSourceProperty(name: "Geopolitical Heading", key: #keyPath(Light.geopoliticalHeading), type: .string),
        DataSourceProperty(name: "Region Heading", key: #keyPath(Light.regionHeading), type: .string),
        DataSourceProperty(name: "Subregion Heading", key: #keyPath(Light.subregionHeading), type: .string),
        DataSourceProperty(name: "Local Heading", key: #keyPath(Light.localHeading), type: .string)
    ]
    
    var coordinateRegion: MKCoordinateRegion? {
        MKCoordinateRegion(center: self.coordinate, zoom: 14.5, bounds: CGRect(x: 0, y: 0, width: 600, height: 600))
    }
}

extension LightModel: MapImage {
    static var cacheTiles: Bool = true
    
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
