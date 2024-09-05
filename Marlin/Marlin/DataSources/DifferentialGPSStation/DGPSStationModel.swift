//
//  DifferentialGPSStation+Decodable.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import OSLog
import CoreLocation

struct DGPSStationModel: 
    Locatable,
    Bookmarkable,
    Codable,
    GeoJSONExportable,
    CustomStringConvertible,
    Hashable,
    Identifiable {
    var id: String {
        "\(featureNumber ?? 0)--\(volumeNumber ?? "")"
    }

    static var definition: any DataSourceDefinition = DataSourceDefinitions.differentialGPSStation.definition
    var sfGeometry: SFGeometry? {
        return SFPoint(xValue: coordinate.longitude, andYValue: coordinate.latitude)
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var itemTitle: String {
        return "\(self.name ?? "\(self.featureNumber ?? 0)")"
    }

    var itemKey: String {
        return "\(featureNumber ?? 0)--\(volumeNumber ?? "")"
    }

    var key: String {
        DataSources.dgps.key
    }

    var canBookmark: Bool = false
        
    enum CodingKeys: String, CodingKey {
        case aidType
        case deleteFlag
        case featureNumber
        case frequency
        case geopoliticalHeading
        case name
        case noticeNumber
        case noticeWeek
        case noticeYear
        case position
        case postNote
        case precedingNote
        case range
        case regionHeading
        case remarks
        case removeFromList
        case sectionHeader
        case stationID
        case transferRate
        case volumeNumber
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(aidType, forKey: .aidType)
        try? container.encode(deleteFlag, forKey: .deleteFlag)
        try? container.encode(featureNumber, forKey: .featureNumber)
        try? container.encode(frequency, forKey: .frequency)
        try? container.encode(geopoliticalHeading, forKey: .geopoliticalHeading)
        try? container.encode(name, forKey: .name)
        try? container.encode(noticeNumber, forKey: .noticeNumber)
        try? container.encode(noticeWeek, forKey: .noticeWeek)
        try? container.encode(noticeYear, forKey: .noticeYear)
        try? container.encode(position, forKey: .position)
        try? container.encode(postNote, forKey: .postNote)
        try? container.encode(precedingNote, forKey: .precedingNote)
        try? container.encode(range, forKey: .range)
        try? container.encode(regionHeading, forKey: .regionHeading)
        try? container.encode(remarks, forKey: .remarks)
        try? container.encode(removeFromList, forKey: .removeFromList)
        try? container.encode(sectionHeader, forKey: .sectionHeader)
        try? container.encode(stationID, forKey: .stationID)
        try? container.encode(transferRate, forKey: .transferRate)
        try? container.encode(volumeNumber, forKey: .volumeNumber)
    }
    
    var differentialGPSStation: DifferentialGPSStation?
    
    var aidType: String?
    var deleteFlag: String?
    var featureNumber: Int?
    var frequency: Int?
    var geopoliticalHeading: String?
    var latitude: Double
    var longitude: Double
    var name: String?
    var noticeNumber: Int?
    var noticeWeek: String?
    var noticeYear: String?
    var position: String?
    var postNote: String?
    var precedingNote: String?
    var range: Int?
    var regionHeading: String?
    var remarks: String?
    var removeFromList: String?
    var sectionHeader: String?
    var stationID: String?
    var transferRate: Int?
    var volumeNumber: String?
    var mgrs10km: String?
    
    init() {
        self.canBookmark = false
        self.latitude = kCLLocationCoordinate2DInvalid.latitude
        self.longitude = kCLLocationCoordinate2DInvalid.longitude
    }
    
    // The keys must have the same name as the attributes of the Lights entity.
    var dictionaryValue: [String: Any?] {
        [
            "aidType": aidType,
            "deleteFlag": deleteFlag,
            "featureNumber": featureNumber,
            "frequency": frequency,
            "geopoliticalHeading": geopoliticalHeading,
            "latitude": latitude,
            "longitude": longitude,
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
            "stationID": stationID,
            "transferRate": transferRate,
            "volumeNumber": volumeNumber,
            "sectionHeader": sectionHeader
            
        ]
    }
    
    var additionalKeyValues: [KeyValue] {
        return [
            KeyValue(key: "Number", value: featureNumber?.zeroIsEmptyString),
            KeyValue(key: "Name & Location", value: name),
            KeyValue(key: "Geopolitical Heading", value: geopoliticalHeading),
            KeyValue(key: "Position", value: position),
            KeyValue(key: "Station ID", value: stationID),
            KeyValue(key: "Range (nmi)", value: range?.zeroIsEmptyString),
            KeyValue(key: "Frequency (kHz)", value: frequency?.zeroIsEmptyString),
            KeyValue(key: "Transfer Rate", value: transferRate?.zeroIsEmptyString),
            KeyValue(key: "Remarks", value: remarks),
            KeyValue(key: "Notice Number", value: noticeNumber?.zeroIsEmptyString),
            KeyValue(key: "Preceding Note", value: precedingNote),
            KeyValue(key: "Post Note", value: postNote)
        ]
    }
    
    var description: String {
        return "Differential GPS Station\n\n" +
        "aidType \(aidType ?? "")\n" +
        "deleteFlag \(deleteFlag ?? "")\n" +
        "featureNumber \(featureNumber ?? 0)\n" +
        "frequency \(frequency ?? 0)\n" +
        "geopoliticalHeading \(geopoliticalHeading ?? "")\n" +
        "latitude \(latitude)\n" +
        "longitude \(longitude)\n" +
        "name \(name ?? "")\n" +
        "noticeNumber \(noticeNumber ?? 0)\n" +
        "noticeWeek \(noticeWeek ?? "")\n" +
        "noticeYear \(noticeYear ?? "")\n" +
        "position \(position ?? "")\n" +
        "postNote \(postNote ?? "")\n" +
        "precedingNote \(precedingNote ?? "")\n" +
        "range \(range ?? 0)\n" +
        "remarks \(remarks ?? "")\n" +
        "regionHeading \(regionHeading ?? "")\n" +
        "removeFromList \(removeFromList ?? "")\n" +
        "stationID \(stationID ?? "")\n" +
        "transferRate \(transferRate ?? 0)\n" +
        "volumeNumber \(volumeNumber ?? "")"
    }
}
