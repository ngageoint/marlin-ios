//
//  Light+Decodable.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import OSLog
import CoreLocation
import mgrs_ios

struct LightsPropertyContainer: Decodable {
    private enum CodingKeys: String, CodingKey {
        case ngalol
    }
    let ngalol: [LightModel]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        ngalol = try container.decode([Throwable<LightModel>].self, forKey: .ngalol).compactMap { try? $0.result.get() }
    }
}

struct LightsProperties: Codable {
        
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
    
    let aidType: String?
    let characteristic: String?
    let characteristicNumber: Int?
    let deleteFlag: String?
    let featureNumber: String?
    let geopoliticalHeading: String?
    let heightFeet: Float?
    let heightMeters: Float?
    let internationalFeature: String?
    let localHeading: String?
    let name: String?
    let noticeNumber: Int?
    let noticeWeek: String?
    let noticeYear: String?
    let position: String?
    let postNote: String?
    let precedingNote: String?
    let range: String?
    let regionHeading: String?
    let remarks: String?
    let removeFromList: String?
    let structure: String?
    let subregionHeading: String?
    let volumeNumber: String?
    let latitude: Double
    let longitude: Double
    let mgrs10km: String?
    let requiresPostProcessing: Bool?
    let sectionHeader: String?
    
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
        if self.featureNumber == "3808" {
            NSLog("Remarks are in decodable \(remarks)")
        }
        self.removeFromList = try? values.decode(String.self, forKey: .removeFromList)
        self.structure = try? values.decode(String.self, forKey: .structure)
        self.subregionHeading = try? values.decode(String.self, forKey: .subregionHeading)
        
        if let position = self.position {
            let coordinate = LightsProperties.parsePosition(position: position)
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
        
        let mgrsPosition = MGRS.from(longitude, latitude)
        self.mgrs10km = mgrsPosition.coordinate(.TEN_KILOMETER)
        self.sectionHeader = nil
    }
    
    static func parsePosition(position: String) -> CLLocationCoordinate2D {
        var latitude = 0.0
        var longitude = 0.0
        
        let pattern = #"(?<latdeg>[0-9]*)°(?<latminutes>[0-9]*)'(?<latseconds>[0-9]*\.?[0-9]*)\"(?<latdirection>[NS]) \n(?<londeg>[0-9]*)°(?<lonminutes>[0-9]*)'(?<lonseconds>[0-9]*\.?[0-9]*)\"(?<londirection>[EW])"#
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let nsrange = NSRange(position.startIndex..<position.endIndex,
                              in: position)
        if let match = regex?.firstMatch(in: position,
                                         options: [],
                                         range: nsrange)
        {
            for component in ["latdeg", "latminutes", "latseconds", "latdirection"] {
                let nsrange = match.range(withName: component)
                if nsrange.location != NSNotFound,
                   let range = Range(nsrange, in: position)
                {
                    if component == "latdeg" {
                        latitude = Double(position[range]) ?? 0.0
                    } else if component == "latminutes" {
                        latitude += (Double(position[range]) ?? 0.0) / 60
                    } else if component == "latseconds" {
                        latitude += (Double(position[range]) ?? 0.0) / 3600
                    } else if component == "latdirection", position[range] == "S" {
                        latitude *= -1
                    }
                }
            }
            for component in ["londeg", "lonminutes", "lonseconds", "londirection"] {
                let nsrange = match.range(withName: component)
                if nsrange.location != NSNotFound,
                   let range = Range(nsrange, in: position)
                {
                    if component == "londeg" {
                        longitude = Double(position[range]) ?? 0.0
                    } else if component == "lonminutes" {
                        longitude += (Double(position[range]) ?? 0.0) / 60
                    } else if component == "lonseconds" {
                        longitude += (Double(position[range]) ?? 0.0) / 3600
                    } else if component == "londirection", position[range] == "W" {
                        longitude *= -1
                    }
                }
            }
        }
        
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
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
}
