//
//  LightModel.swift
//  Marlin
//
//  Created by Daniel Barela on 10/14/22.
//

import Foundation
import UIKit
import MapKit
import GeoJSON
import sf_ios
import OSLog
import mgrs_ios

struct LightListModel: Hashable, Identifiable {
    var canBookmark: Bool = false
    var id: String { self.itemKey }

    var featureNumber: String?
    var volumeNumber: String?
    var characteristicNumber: Int?
    var internationalFeature: String?
    var name: String?
    var sectionHeader: String?
    var structure: String?
    var latitude: Double
    var longitude: Double

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(light: Light) {
        canBookmark = true
        featureNumber = light.featureNumber
        volumeNumber = light.volumeNumber
        characteristicNumber = Int(light.characteristicNumber)
        internationalFeature = light.internationalFeature
        name = light.name
        sectionHeader = light.sectionHeader
        structure = light.structure
        latitude = light.latitude
        longitude = light.longitude
    }

    init(lightModel: LightModel) {
        canBookmark = lightModel.canBookmark
        featureNumber = lightModel.featureNumber
        volumeNumber = lightModel.volumeNumber
        characteristicNumber = lightModel.characteristicNumber
        internationalFeature = lightModel.internationalFeature
        name = lightModel.name
        sectionHeader = lightModel.sectionHeader
        structure = lightModel.structure
        latitude = lightModel.latitude
        longitude = lightModel.longitude
    }

    var itemTitle: String {
        return "\(self.name ?? "")"
    }
}

extension LightListModel: Bookmarkable {
    static var definition: any DataSourceDefinition {
        DataSources.light
    }

    var itemKey: String {
        return "\(featureNumber ?? "")--\(volumeNumber ?? "")--\(characteristicNumber ?? 0)"
    }

    var key: String {
        DataSources.light.key
    }
}

struct LightRangeModel: Hashable {
    var color: String?
    var range: Double?

    init(range: LightRange) {
        self.color = range.color
        self.range = range.range
    }
}

// this is being refactored soon so disable this check
// swiftlint:disable type_body_length
// swiftlint:disable file_length
struct LightModel: Locatable, Bookmarkable, Codable, CustomStringConvertible, Hashable, Identifiable {
    var canBookmark: Bool = false
    var id: String { self.itemKey }
    var itemTitle: String {
        return "\(self.name ?? "")"
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var uri: URL?
//    var light: Light?

    private enum CodingKeys: String, CodingKey {
        case volumeNumber
        case aidType
        case geopoliticalHeading
        case regionHeading
        case subregionHeading
        case localHeading
        case precedingNote
        case featureNumber
        case name
        case position
        case charNo
        case characteristic
        case heightFeetMeters
        case range
        case structure
        case remarks
        case postNote
        case noticeNumber
        case removeFromList
        case deleteFlag
        case noticeWeek
        case noticeYear
        case sectionHeader
    }
    
    var aidType: String?
    var characteristic: String?
    var characteristicNumber: Int?
    var deleteFlag: String?
    var featureNumber: String?
    var geopoliticalHeading: String?
    var heightFeet: Float?
    var heightMeters: Float?
    var internationalFeature: String?
    var localHeading: String?
    var latitude: Double
    var longitude: Double
    var mgrs10km: String?
    var name: String?
    var noticeNumber: Int?
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
    var requiresPostProcessing: Bool?
    var lightRange: Set<LightRangeModel>?

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(aidType, forKey: .aidType)
        try? container.encode(characteristic, forKey: .characteristic)
        try? container.encode(characteristicNumber, forKey: .charNo)
        try? container.encode(deleteFlag, forKey: .deleteFlag)
        if let featureNumber = featureNumber, let internationalFeature = internationalFeature {
            try? container.encode("\(featureNumber)\n\(internationalFeature)", forKey: .featureNumber)
        } else if let featureNumber = featureNumber {
            try? container.encode("\(featureNumber)", forKey: .featureNumber)
        }
        try? container.encode(geopoliticalHeading, forKey: .geopoliticalHeading)
        if let heightFeet = heightFeet, let heightMeters = heightMeters {
            try? container.encode("\(heightFeet)\n\(heightMeters)", forKey: .heightFeetMeters)
        }
        try? container.encode(localHeading, forKey: .localHeading)
        try? container.encode(name, forKey: .name)
        try? container.encode(noticeNumber, forKey: .noticeNumber)
        try? container.encode(noticeWeek, forKey: .noticeWeek)
        try? container.encode(noticeYear, forKey: .noticeYear)
        try? container.encode(postNote, forKey: .postNote)
        try? container.encode(precedingNote, forKey: .precedingNote)
        try? container.encode(range, forKey: .range)
        try? container.encode(regionHeading, forKey: .regionHeading)
        try? container.encode(remarks, forKey: .remarks)
        try? container.encode(removeFromList, forKey: .removeFromList)
        try? container.encode(structure, forKey: .structure)
        try? container.encode(subregionHeading, forKey: .subregionHeading)
        try? container.encode(position, forKey: .position)
        try? container.encode(volumeNumber, forKey: .volumeNumber)
    }

    init() {
        self.canBookmark = false
        self.latitude = kCLLocationCoordinate2DInvalid.latitude
        self.longitude = kCLLocationCoordinate2DInvalid.longitude
    }

    init(light: Light) {
//        self.light = light
        self.uri = light.objectID.uriRepresentation()
        self.canBookmark = true
        self.aidType = light.aidType
        self.characteristic = light.characteristic
        self.characteristicNumber = Int(light.characteristicNumber)
        self.deleteFlag = light.deleteFlag
        self.featureNumber = light.featureNumber
        self.geopoliticalHeading = light.geopoliticalHeading
        self.heightFeet = light.heightFeet
        self.heightMeters = light.heightMeters
        self.internationalFeature = light.internationalFeature
        self.latitude = light.latitude
        self.localHeading = light.localHeading
        self.longitude = light.longitude
        self.mgrs10km = light.mgrs10km
        self.name = light.name
        self.noticeNumber = Int(light.noticeNumber)
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
        self.requiresPostProcessing = light.requiresPostProcessing
        let ranges: [LightRangeModel] = light.lightRange?.compactMap({ range in
            if let range = range as? LightRange {
                return LightRangeModel(range: range)
            }
            return nil
        }) ?? []
        self.lightRange = Set<LightRangeModel>(ranges)
    }
    
    init?(feature: Feature) {
        if let json = try? JSONEncoder().encode(feature.properties), let string = String(data: json, encoding: .utf8) {
            
            let decoder = JSONDecoder()
            let jsonData = Data(string.utf8)
            if let model = try? decoder.decode(LightModel.self, from: jsonData) {
                self = model
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    // there are a lot of properties
    // swiftlint:disable function_body_length
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        // this potentially is US and international feature number combined with a new line
        let rawFeatureNumber = try? values.decode(String.self, forKey: .featureNumber)
        let rawVolumeNumber = try? values.decode(String.self, forKey: .volumeNumber)
        let rawPosition = try? values.decode(String.self, forKey: .position)
        
        guard let featureNumber = rawFeatureNumber,
              let volumeNumber = rawVolumeNumber,
              let position = rawPosition
        else {
            let values = "featureNumber = \(rawFeatureNumber?.description ?? "nil"), "
            + "volumeNumber = \(rawVolumeNumber?.description ?? "nil"), "
            + "position = \(rawPosition?.description ?? "nil")"
            
            let logger = Logger(subsystem: "mil.nga.msi.Marlin", category: "parsing")
            logger.debug("Ignored: \(values)")
            
            throw MSIError.missingData
        }
        
        self.volumeNumber = volumeNumber
        self.position = position
        self.aidType = try? values.decode(String.self, forKey: .aidType)
        self.characteristic = try? values.decode(String.self, forKey: .characteristic)
        self.characteristicNumber = try? values.decode(Int.self, forKey: .charNo)
        self.deleteFlag = try? values.decode(String.self, forKey: .deleteFlag)
        let featureNumberSplit = featureNumber.split(separator: "\n")
        self.featureNumber = "\(featureNumberSplit[0])"
        if featureNumberSplit.count == 2 {
            self.internationalFeature = "\(featureNumberSplit[1])"
        } else {
            self.internationalFeature = nil
        }
        self.geopoliticalHeading = try? values.decode(String.self, forKey: .geopoliticalHeading)
        let heightFeetMeters = try? values.decode(String.self, forKey: .heightFeetMeters)
        let heightFeetMetersSplit = heightFeetMeters?.split(separator: "\n")
        self.heightFeet = Float(heightFeetMetersSplit?[0] ?? "0.0")
        self.heightMeters = Float(heightFeetMetersSplit?[1] ?? "0.0")
        self.localHeading = try? values.decode(String.self, forKey: .localHeading)
        self.name = try? values.decode(String.self, forKey: .name)
        self.noticeNumber = try? values.decode(Int.self, forKey: .noticeNumber)
        self.noticeWeek = try? values.decode(String.self, forKey: .noticeWeek)
        self.noticeYear = try? values.decode(String.self, forKey: .noticeYear)
        self.postNote = try? values.decode(String.self, forKey: .postNote)
        self.precedingNote = try? values.decode(String.self, forKey: .precedingNote)
        self.range = try? values.decode(String.self, forKey: .range)
        if let range = self.range {
            if Double(range) != nil {
                self.requiresPostProcessing = false
            } else {
                self.requiresPostProcessing = true
            }
        } else {
            self.requiresPostProcessing = false
        }
        // TODO: should post process characterstic (colors) and remarks (sectors)
        if var rawRegionHeading = try? values.decode(String.self, forKey: .regionHeading) {
            if rawRegionHeading.last == ":" {
                rawRegionHeading.removeLast()
            }
            self.regionHeading = rawRegionHeading
        } else {
            self.regionHeading = nil
        }
        self.remarks = try? values.decode(String.self, forKey: .remarks)
        self.removeFromList = try? values.decode(String.self, forKey: .removeFromList)
        self.structure = try? values.decode(String.self, forKey: .structure)
        self.subregionHeading = try? values.decode(String.self, forKey: .subregionHeading)
        
        if let position = self.position,
           let coordinate = CLLocationCoordinate2D(coordinateString: position) {
            self.longitude = coordinate.longitude
            self.latitude = coordinate.latitude
        } else {
            self.longitude = 0.0
            self.latitude = 0.0
        }
        
        if characteristic == "" && remarks == nil && name == "" {
            let logger = Logger(subsystem: "mil.nga.msi.Marlin", category: "parsing")
            logger.debug("Ignored \(featureNumber ) \(volumeNumber ) due to no name, remarks, and characteristic")
            
            throw MSIError.missingData
        }
        
        if CLLocationCoordinate2DIsValid(CLLocationCoordinate2D(
            latitude: latitude, longitude: longitude
        )) {
            let mgrsPosition = MGRS.from(longitude, latitude)
            self.mgrs10km = mgrsPosition.coordinate(.TEN_KILOMETER)
        }
        self.sectionHeader = nil
    }
    // swiftlint:enable function_body_length

    // The keys must have the same name as the attributes of the Lights entity.
    var dictionaryValue: [String: Any?] {
        [
            "aidType": aidType,
            "characteristic": characteristic,
            "characteristicNumber": characteristicNumber,
            "deleteFlag": deleteFlag,
            "featureNumber": featureNumber,
            "geopoliticalHeading": geopoliticalHeading,
            "heightFeet": heightFeet,
            "heightMeters": heightMeters,
            "internationalFeature": internationalFeature,
            "localHeading": localHeading,
            "name": name,
            "noticeNumber": noticeNumber,
            "noticeWeek": noticeWeek,
            "noticeYear": noticeYear,
            "position": position,
            "postNote": postNote,
            "precedingNote": precedingNote,
            "range": range,
            "regionHeading": regionHeading,
            "remarks": remarks,
            "removeFromList": removeFromList,
            "structure": structure,
            "subregionHeading": subregionHeading,
            "volumeNumber": volumeNumber,
            "latitude": latitude,
            "longitude": longitude,
            "requiresPostProcessing": requiresPostProcessing
        ]
    }
    
    init(
        characteristicNumber: Int64,
        structure: String? = nil,
        name: String? = nil,
        volumeNumber: String? = nil,
        featureNumber: String? = nil,
        noticeWeek: String? = nil,
        noticeYear: String? = nil,
        latitude: Double,
        longitude: Double,
        remarks: String? = nil,
        characteristic: String? = nil,
        range: String? = nil) {
        self.characteristicNumber = Int(characteristicNumber)
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
        return self.uri == other.uri
    }
    
    static func == (lhs: LightModel, rhs: LightModel) -> Bool {
        lhs.isEqualTo(rhs)
    }

    var morseCode: String? {
        guard !isLight, 
                let characteristic = characteristic,
                let leftParen = characteristic.firstIndex(of: "("),
                let lastIndex = characteristic.lastIndex(of: ")") else {
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
        // swiftlint:disable line_length
        let pattern = #"(?<azimuth>(Azimuth coverage)?).?((?<startdeg>(\d*))\°)?((?<startminutes>[0-9]*)[\`'])?(-(?<enddeg>(\d*))\°)?(?<endminutes>[0-9]*)[\`']?\..*"#
        // swiftlint:enable line_length
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let nsrange = NSRange(remarks.startIndex..<remarks.endIndex,
                              in: remarks)
        var previousEnd: Double = 0.0
        
        regex?.enumerateMatches(in: remarks, range: nsrange, using: { match, _, _ in
            guard let match = match else {
                return
            }
            var end: Double = 0.0
            var start: Double?
            for component in ["startdeg", "startminutes", "enddeg", "endminutes"] {
                
                let nsrange = match.range(withName: component)
                if nsrange.location != NSNotFound,
                   let range = Range(nsrange, in: remarks) {
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
        if characteristic.contains("G.") 
            || characteristic.contains("Oc.G")
            || characteristic.contains("G\n")
            || characteristic.contains("F.G")
            || characteristic.contains("Fl.G")
            || characteristic.contains("(G)") {
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
        
        // swiftlint:disable line_length
        let pattern = #"(?<visible>(Visible)?)(?<fullLightObscured>(bscured)?)((?<color>[A-Z]+)?)\.?(?<unintensified>(\(unintensified\))?)(?<obscured>(\(bscured\))?)( (?<startdeg>(\d*))°)?((?<startminutes>[0-9]*)[\`'])?(-(?<enddeg>(\d*))°)(?<endminutes>[0-9]*)[\`']?"#
        // swiftlint:enable line_length
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let nsrange = NSRange(remarks.startIndex..<remarks.endIndex,
                              in: remarks)
        var previousEnd: Double = 0.0
        
        var visibleSector: Bool = false
        
        regex?.enumerateMatches(in: remarks, range: nsrange, using: { match, _, _ in
            guard let match = match else {
                return
            }
            var color: String = ""
            var end: Double = 0.0
            var start: Double?
            var visibleColor: UIColor?
            var obscured: Bool = false
            var fullLightObscured: Bool = false
            for component in [
                "visible",
                "fullLightObscured",
                "color",
                "unintensified",
                "obscured",
                "startdeg",
                "startminutes",
                "enddeg",
                "endminutes"] {
                
                let nsrange = match.range(withName: component)
                if nsrange.location != NSNotFound,
                   let range = Range(nsrange, in: remarks),
                   !range.isEmpty {
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
            var sectorRange: Double?
            if let rangeString = range {
                for split in rangeString.components(separatedBy: CharacterSet(charactersIn: ";\n"))
                where split.trimmingCharacters(in: .whitespacesAndNewlines).starts(with: color) {
                    let pattern = #"[0-9]+$"#
                    let regex = try? NSRegularExpression(pattern: pattern, options: [])
                    let rangePart = "\(split)".trimmingCharacters(in: .whitespacesAndNewlines)
                    let match = regex?.firstMatch(
                        in: rangePart,
                        range: NSRange(rangePart.startIndex..<rangePart.endIndex, in: rangePart))

                    if let nsrange = match?.range, nsrange.location != NSNotFound,
                       let matchRange = Range(nsrange, in: rangePart),
                       !matchRange.isEmpty {
                        let colorRange = rangePart[matchRange]
                        if !colorRange.isEmpty {
                            sectorRange = Double(colorRange)
                        }
                    }
                }
            }
            if let start = start {
                if end < start {
                    end += 360
                }
                sectors.append(
                    ImageSector(
                        startDegrees: start,
                        endDegrees: end,
                        color: uicolor,
                        text: color,
                        obscured: obscured || fullLightObscured,
                        range: sectorRange))
            } else {
                if end <= previousEnd {
                    end += 360
                }
                sectors.append(
                    ImageSector(
                        startDegrees: previousEnd,
                        endDegrees: end,
                        color: uicolor,
                        text: color,
                        obscured: obscured || fullLightObscured,
                        range: sectorRange))
            }
            if fullLightObscured && !visibleSector {
                // add the sector for the part of the light which is not obscured
                sectors.append(
                    ImageSector(
                        startDegrees: end,
                        endDegrees: (start ?? 0) + 360,
                        color: visibleColor ?? (lightColors?[0] ?? UIColor.clear),
                        range: sectorRange))
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
    
    var description: String {
        return "LIGHT\n\n" +
        "aidType \(aidType ?? "")\n" +
        "characteristic \(characteristic ?? "")\n" +
        "characteristicNumber \(characteristicNumber ?? 0)\n" +
        "deleteFlag \(deleteFlag ?? "")\n" +
        "featureNumber \(featureNumber ?? "")\n" +
        "geopoliticalHeading \(geopoliticalHeading ?? "")\n" +
        "heightFeet \(heightFeet ?? 0)\n" +
        "heightMeters \(heightMeters ?? 0)\n" +
        "internationalFeature \(internationalFeature ?? "")\n" +
        "localHeading \(localHeading ?? "")\n" +
        "name \(name ?? "")\n" +
        "noticeNumber \(noticeNumber ?? 0)\n" +
        "noticeWeek \(noticeWeek ?? "")\n" +
        "noticeYear \(noticeYear ?? "")\n" +
        "position \(position ?? "")\n" +
        "postNote \(postNote ?? "")\n" +
        "precedingNote \(precedingNote ?? "")\n" +
        "range \(range ?? "")\n" +
        "regionHeading \(regionHeading ?? "")\n" +
        "remarks \(remarks ?? "")\n" +
        "removeFromList \(removeFromList ?? "")\n" +
        "structure \(structure ?? "")\n" +
        "subregionHeading \(subregionHeading ?? "")\n" +
        "volumeNumber \(volumeNumber ?? "")"
    }
}
// swiftlint:enable type_body_length

extension LightModel: GeoJSONExportable {
    var itemKey: String {
        return "\(featureNumber ?? "")--\(volumeNumber ?? "")--\(characteristicNumber ?? 0)"
    }

    static var definition: any DataSourceDefinition = DataSourceDefinitions.light.definition

    func sfGeometryByColor() -> [UIColor: SFGeometry?]? {
        var geometryByColor: [UIColor: SFGeometry] = [:]
        if let lightSectors = lightSectors {
            let sectorsByColor = Dictionary(grouping: lightSectors, by: \.color)
            for (color, sectors) in sectorsByColor {
                let collection = SFGeometryCollection()
                
                for sector in sectors {
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

                    let ring = SFLineString()
                    ring?.addPoint(SFPoint(xValue: coordinate.longitude, andYValue: coordinate.latitude))
                    for circleCoordinate in circleCoordinates {
                        let point = SFPoint(xValue: circleCoordinate.longitude, andYValue: circleCoordinate.latitude)
                        ring?.addPoint(point)
                    }
                    let poly = SFPolygon(ring: ring)
                    if let poly = poly {
                        collection?.addGeometry(poly)
                    }
                }
                geometryByColor[color] = collection
            }
            
            return geometryByColor
        } else if let stringRange = range, let range = Double(stringRange), let lightColors = lightColors {
            let nauticalMilesMeasurement = NSMeasurement(doubleValue: range, unit: UnitLength.nauticalMiles)
            let metersMeasurement = nauticalMilesMeasurement.converting(to: UnitLength.meters)
            
            let circleCoordinates = coordinate.circleCoordinates(radiusMeters: metersMeasurement.value)
            
            let ring = SFLineString()
            for circleCoordinate in circleCoordinates {
                let point = SFPoint(xValue: circleCoordinate.longitude, andYValue: circleCoordinate.latitude)
                ring?.addPoint(point)
            }
            let poly = SFPolygon(ring: ring)
            if let poly = poly {
                geometryByColor[lightColors[0]] = poly
            }
            return geometryByColor
        }
        return nil
    }
    
    var sfGeometry: SFGeometry? {
        if let geometryByColor = sfGeometryByColor() {
            
            let collection = SFGeometryCollection()
            
            for geometry in geometryByColor.values {
                collection?.addGeometry(geometry)
            }
            return collection
        } else {
            return SFPoint(xValue: coordinate.longitude, andYValue: coordinate.latitude)
        }
    }

    var coordinateRegion: MKCoordinateRegion? {
        MKCoordinateRegion(center: self.coordinate, zoom: 11.5, bounds: CGRect(x: 0, y: 0, width: 600, height: 600))
    }
}
