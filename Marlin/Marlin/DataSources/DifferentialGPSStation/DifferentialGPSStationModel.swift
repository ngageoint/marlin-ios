//
//  DifferentialGPSStation+Decodable.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import OSLog
import CoreLocation
import mgrs_ios
import GeoJSON

struct DifferentialGPSStationPropertyContainer: Decodable {
    private enum CodingKeys: String, CodingKey {
        case ngalol
    }
    let ngalol: [DifferentialGPSStationModel]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        ngalol = try container.decode([Throwable<DifferentialGPSStationModel>].self, forKey: .ngalol).compactMap { try? $0.result.get() }
    }
}

struct DifferentialGPSStationModel: Locatable, Bookmarkable, Codable, GeoJSONExportable, CustomStringConvertible {    
    static var definition: any DataSourceDefinition = DataSourceDefinitions.dgps.definition
    var sfGeometry: SFGeometry? {
        return SFPoint(xValue: coordinate.longitude, andYValue: coordinate.latitude)
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
        
    var itemKey: String {
        return "\(featureNumber ?? 0)--\(volumeNumber ?? "")"
    }
    var canBookmark: Bool = false
        
    private enum CodingKeys: String, CodingKey {
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
    
    let aidType: String?
    let deleteFlag: String?
    let featureNumber: Int?
    let frequency: Int?
    let geopoliticalHeading: String?
    let latitude: Double
    let longitude: Double
    let name: String?
    let noticeNumber: Int?
    let noticeWeek: String?
    let noticeYear: String?
    let position: String?
    let postNote: String?
    let precedingNote: String?
    let range: Int?
    let regionHeading: String?
    let remarks: String?
    let removeFromList: String?
    let sectionHeader: String?
    let stationID: String?
    let transferRate: Int?
    let volumeNumber: String?
    let mgrs10km: String?
    
    init(differentialGPSStation: DifferentialGPSStation) {
        self.canBookmark = true
        self.differentialGPSStation = differentialGPSStation
        self.aidType = differentialGPSStation.aidType
        self.deleteFlag = differentialGPSStation.deleteFlag
        self.featureNumber = Int(differentialGPSStation.featureNumber)
        self.frequency = Int(differentialGPSStation.frequency)
        self.geopoliticalHeading = differentialGPSStation.geopoliticalHeading
        self.latitude = differentialGPSStation.latitude
        self.longitude = differentialGPSStation.longitude
        self.name = differentialGPSStation.name
        self.noticeNumber = Int(differentialGPSStation.noticeNumber)
        self.noticeWeek = differentialGPSStation.noticeWeek
        self.noticeYear = differentialGPSStation.noticeYear
        self.position = differentialGPSStation.position
        self.postNote = differentialGPSStation.postNote
        self.precedingNote = differentialGPSStation.precedingNote
        self.range = Int(differentialGPSStation.range)
        self.regionHeading = differentialGPSStation.regionHeading
        self.remarks = differentialGPSStation.remarks
        self.removeFromList = differentialGPSStation.removeFromList
        self.sectionHeader = differentialGPSStation.sectionHeader
        self.stationID = differentialGPSStation.stationID
        self.transferRate = Int(differentialGPSStation.transferRate)
        self.volumeNumber = differentialGPSStation.volumeNumber
        self.mgrs10km = differentialGPSStation.mgrs10km
    }
    
    init?(feature: Feature) {
        if let json = try? JSONEncoder().encode(feature.properties), let string = String(data: json, encoding: .utf8) {
            
            let decoder = JSONDecoder()
            let jsonData = Data(string.utf8)
            
            if let ds = try? decoder.decode(DifferentialGPSStationModel.self, from: jsonData) {
                self = ds
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        // this potentially is US and international feature number combined with a new line
        let rawFeatureNumber = try? values.decode(Int.self, forKey: .featureNumber)
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
        self.deleteFlag = try? values.decode(String.self, forKey: .deleteFlag)
        self.featureNumber = featureNumber
        self.frequency = try? values.decode(Int.self, forKey: .frequency)
        self.geopoliticalHeading = try? values.decode(String.self, forKey: .geopoliticalHeading)
        self.name = try? values.decode(String.self, forKey: .name)
        self.noticeNumber = try? values.decode(Int.self, forKey: .noticeNumber)
        self.noticeWeek = try? values.decode(String.self, forKey: .noticeWeek)
        self.noticeYear = try? values.decode(String.self, forKey: .noticeYear)
        self.postNote = try? values.decode(String.self, forKey: .postNote)
        self.precedingNote = try? values.decode(String.self, forKey: .precedingNote)
        self.range = try? values.decode(Int.self, forKey: .range)
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
        let rawStationID = try? values.decode(String.self, forKey: .stationID)
        if let rawStationID = rawStationID {
            if rawStationID.hasSuffix("\n") {
                self.stationID = "\(rawStationID.dropLast(2))"
            } else {
                self.stationID = rawStationID
            }
        } else {
            self.stationID = nil
        }
        self.sectionHeader = try? values.decode(String.self, forKey: .sectionHeader)
        self.transferRate = try? values.decode(Int.self, forKey: .transferRate)
        
        if let position = self.position {
            let coordinate = DifferentialGPSStationModel.parsePosition(position: position)
            self.longitude = coordinate.longitude
            self.latitude = coordinate.latitude
        } else {
            self.longitude = 0.0
            self.latitude = 0.0
        }
        
        let mgrsPosition = MGRS.from(longitude, latitude)
        self.mgrs10km = mgrsPosition.coordinate(.TEN_KILOMETER)
    }
    
    static func parsePosition(position: String) -> CLLocationCoordinate2D {
        var latitude = 0.0
        var longitude = 0.0
        
        let pattern = #"""
            (?<latdeg>[0-9]*)°(?<latminutes>[0-9]*)'(?<latseconds>[0-9]*\.?[0-9]*)\"\
            (?<latdirection>[NS])\
            \n(?<londeg>[0-9]*)°(?<lonminutes>[0-9]*)'(?<lonseconds>[0-9]*\.?[0-9]*)\"\
            (?<londirection>[EW])
        """#
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let nsrange = NSRange(position.startIndex..<position.endIndex,
                              in: position)
        if let match = regex?.firstMatch(in: position,
                                         options: [],
                                         range: nsrange) {
            for component in ["latdeg", "latminutes", "latseconds", "latdirection"] {
                let nsrange = match.range(withName: component)
                if nsrange.location != NSNotFound,
                   let range = Range(nsrange, in: position) {
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
                   let range = Range(nsrange, in: position) {
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

extension DifferentialGPSStationModel: DataSource {
    var itemTitle: String {
        return "\(self.name ?? "\(self.featureNumber ?? 0)")"
    }
    
    var color: UIColor {
        return Self.color
    }
    static var isMappable: Bool = true
    static var dataSourceName: String = NSLocalizedString("DGPS", comment: "Differential GPS Station data source display name")
    static var fullDataSourceName: String = NSLocalizedString("Differential GPS Stations", comment: "Differential GPS Station data source display name")
    
    static var key: String = "differentialGPSStation"
    static var metricsKey: String = "dgpsStations"
    static var imageName: String? = "dgps"
    static var systemImageName: String?
    static var color: UIColor = UIColor(argbValue: 0xFF00E676)
    static var imageScale = UserDefaults.standard.imageScale(key) ?? 0.66
    
    static var defaultSort: [DataSourceSortParameter] = [
        DataSourceSortParameter(
            property: DataSourceProperty(
                name: "Geopolitical Heading",
                key: #keyPath(DifferentialGPSStation.geopoliticalHeading),
                type: .string),
            ascending: true,
            section: true),
        DataSourceSortParameter(
            property: DataSourceProperty(
                name: "Feature Number",
                key: #keyPath(DifferentialGPSStation.featureNumber),
                type: .int),
            ascending: true)
    ]
    static var defaultFilter: [DataSourceFilterParameter] = []
    
    static var properties: [DataSourceProperty] = [
        DataSourceProperty(name: "Location", key: #keyPath(DifferentialGPSStation.mgrs10km), type: .location),
        DataSourceProperty(name: "Latitude", key: #keyPath(DifferentialGPSStation.latitude), type: .latitude),
        DataSourceProperty(name: "Longitude", key: #keyPath(DifferentialGPSStation.longitude), type: .longitude),
        DataSourceProperty(name: "Number", key: #keyPath(DifferentialGPSStation.featureNumber), type: .int),
        DataSourceProperty(name: "Name", key: #keyPath(DifferentialGPSStation.name), type: .string),
        DataSourceProperty(name: "Geopolitical Heading", 
                           key: #keyPath(DifferentialGPSStation.geopoliticalHeading), 
                           type: .string),
        DataSourceProperty(name: "Station ID", key: #keyPath(DifferentialGPSStation.stationID), type: .int),
        DataSourceProperty(name: "Range (nmi)", key: #keyPath(DifferentialGPSStation.range), type: .int),
        DataSourceProperty(name: "Frequency (kHz)", key: #keyPath(DifferentialGPSStation.frequency), type: .int),
        DataSourceProperty(name: "Transfer Rate", key: #keyPath(DifferentialGPSStation.transferRate), type: .int),
        DataSourceProperty(name: "Remarks", key: #keyPath(DifferentialGPSStation.remarks), type: .string),
        DataSourceProperty(name: "Notice Number", key: #keyPath(DifferentialGPSStation.noticeNumber), type: .int),
        DataSourceProperty(name: "Notice Week", key: #keyPath(DifferentialGPSStation.noticeWeek), type: .string),
        DataSourceProperty(name: "Notice Year", key: #keyPath(DifferentialGPSStation.noticeYear), type: .string),
        DataSourceProperty(name: "Volume Number", key: #keyPath(DifferentialGPSStation.volumeNumber), type: .string),
        DataSourceProperty(name: "Preceding Note", key: #keyPath(DifferentialGPSStation.precedingNote), type: .string),
        DataSourceProperty(name: "Post Note", 
                           key: #keyPath(DifferentialGPSStation.postNote), 
                           type: .string)

    ]
    
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }
    
    static func postProcess() {}
}

extension DifferentialGPSStationModel: MapImage {
    static var cacheTiles: Bool = true
    
    func mapImage(marker: Bool, zoomLevel: Int, tileBounds3857: MapBoundingBox?, context: CGContext? = nil) -> [UIImage] {
        return defaultMapImage(marker: marker, zoomLevel: zoomLevel, tileBounds3857: tileBounds3857, context: context, tileSize: 512.0)
    }
}
