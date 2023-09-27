//
//  RadioBeaconModel.swift
//  Marlin
//
//  Created by Daniel Barela on 9/27/23.
//

import Foundation
import OSLog
import CoreLocation
import mgrs_ios
import GeoJSON

struct RadioBeaconModel: Decodable, Bookmarkable, Locatable {
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var itemKey: String {
        return "\(featureNumber ?? 0)--\(volumeNumber ?? "")"
    }
    var canBookmark: Bool = false
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    private enum CodingKeys: String, CodingKey {
        case aidType
        case characteristic
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
        case removeFromList
        case sectionHeader
        case sequenceText
        case stationRemark
        case volumeNumber
    }
    
    let aidType: String?
    let characteristic: String?
    let deleteFlag: String?
    let featureNumber: Int?
    let frequency: String?
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
    let removeFromList: String?
    let sectionHeader: String?
    let sequenceText: String?
    let stationRemark: String?
    let volumeNumber: String?
    let mgrs10km: String?
    
    init(radioBeacon: RadioBeacon) {
        canBookmark = true
        self.aidType = radioBeacon.aidType
        self.characteristic = radioBeacon.characteristic
        self.deleteFlag = radioBeacon.deleteFlag
        self.featureNumber = Int(radioBeacon.featureNumber)
        self.frequency = radioBeacon.frequency
        self.geopoliticalHeading = radioBeacon.geopoliticalHeading
        self.latitude = radioBeacon.latitude
        self.longitude = radioBeacon.longitude
        self.name = radioBeacon.name
        self.noticeNumber = Int(radioBeacon.noticeNumber)
        self.noticeWeek = radioBeacon.noticeWeek
        self.noticeYear = radioBeacon.noticeYear
        self.position = radioBeacon.position
        self.postNote = radioBeacon.postNote
        self.precedingNote = radioBeacon.precedingNote
        self.range = Int(radioBeacon.range)
        self.regionHeading = radioBeacon.regionHeading
        self.removeFromList = radioBeacon.removeFromList
        self.sectionHeader = radioBeacon.sectionHeader
        self.sequenceText = radioBeacon.sequenceText
        self.stationRemark = radioBeacon.stationRemark
        self.volumeNumber = radioBeacon.volumeNumber
        self.mgrs10km = radioBeacon.mgrs10km
    }
    
    init?(feature: Feature) {
        if let json = try? JSONEncoder().encode(feature.properties), let string = String(data: json, encoding: .utf8) {
            
            let decoder = JSONDecoder()
            let jsonData = Data(string.utf8)
            
            if let ds = try? decoder.decode(RadioBeaconModel.self, from: jsonData) {
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
        self.characteristic = try? values.decode(String.self, forKey: .characteristic)
        self.deleteFlag = try? values.decode(String.self, forKey: .deleteFlag)
        self.featureNumber = featureNumber
        self.frequency = try? values.decode(String.self, forKey: .frequency)
        self.geopoliticalHeading = try? values.decode(String.self, forKey: .geopoliticalHeading)
        self.name = try? values.decode(String.self, forKey: .name)
        self.noticeNumber = try? values.decode(Int.self, forKey: .noticeNumber)
        self.noticeWeek = try? values.decode(String.self, forKey: .noticeWeek)
        self.noticeYear = try? values.decode(String.self, forKey: .noticeYear)
        self.postNote = try? values.decode(String.self, forKey: .postNote)
        self.precedingNote = try? values.decode(String.self, forKey: .precedingNote)
        if let rangeString = try? values.decode(String.self, forKey: .range) {
            self.range = Int(rangeString)
        } else {
            self.range = nil
        }
        if var rawRegionHeading = try? values.decode(String.self, forKey: .regionHeading) {
            if rawRegionHeading.last == ":" {
                rawRegionHeading.removeLast()
            }
            self.regionHeading = rawRegionHeading
        } else {
            self.regionHeading = nil
        }
        self.removeFromList = try? values.decode(String.self, forKey: .removeFromList)
        self.sectionHeader = try? values.decode(String.self, forKey: .sectionHeader)
        self.sequenceText = try? values.decode(String.self, forKey: .sequenceText)
        self.stationRemark = try? values.decode(String.self, forKey: .stationRemark)
        
        if let position = self.position {
            let coordinate = RadioBeaconModel.parsePosition(position: position)
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
            "removeFromList": removeFromList,
            "sequenceText": sequenceText,
            "stationRemark": stationRemark,
            "volumeNumber": volumeNumber
            
        ]
    }
    
    static let radioBeaconVolumes = [
        RadioBeaconVolume(volumeQuery: "110", volumeNumber: "PUB 110"),
        RadioBeaconVolume(volumeQuery: "111", volumeNumber: "PUB 111"),
        RadioBeaconVolume(volumeQuery: "112", volumeNumber: "PUB 112"),
        RadioBeaconVolume(volumeQuery: "113", volumeNumber: "PUB 113"),
        RadioBeaconVolume(volumeQuery: "114", volumeNumber: "PUB 114"),
        RadioBeaconVolume(volumeQuery: "115", volumeNumber: "PUB 115"),
        RadioBeaconVolume(volumeQuery: "116", volumeNumber: "PUB 116")
    ]
    
    var additionalKeyValues: [KeyValue] {
        return [
            KeyValue(key: "Number", value: featureNumber?.zeroIsEmptyString),
            KeyValue(key: "Name & Location", value: name),
            KeyValue(key: "Geopolitical Heading", value: geopoliticalHeading),
            KeyValue(key: "Position", value: position),
            KeyValue(key: "Characteristic", value: expandedCharacteristic),
            KeyValue(key: "Range (nmi)", value: range?.zeroIsEmptyString),
            KeyValue(key: "Sequence", value: sequenceText),
            KeyValue(key: "Frequency (kHz)", value: frequency),
            KeyValue(key: "Remarks", value: stationRemark),
        ]
    }
    
    var expandedCharacteristicWithoutCode: String? {
        guard let characteristic = characteristic, let range = characteristic.range(of: ").\\n") else {
            return nil
        }
        
        let lastIndex = range.upperBound
        
        var withoutCode = "\(String(characteristic[lastIndex..<characteristic.endIndex]))"
        withoutCode = withoutCode.replacingOccurrences(of: "aero", with: "aeronautical")
        withoutCode = withoutCode.replacingOccurrences(of: "si", with: "silence")
        withoutCode = withoutCode.replacingOccurrences(of: "tr", with: "transmission")
        return withoutCode
    }
    
    var expandedCharacteristic: String? {
        var expanded = characteristic
        expanded = expanded?.replacingOccurrences(of: "aero", with: "aeronautical")
        expanded = expanded?.replacingOccurrences(of: "si", with: "silence")
        expanded = expanded?.replacingOccurrences(of: "tr", with: "transmission")
        return expanded
    }
    
    var morseCode: String? {
        guard let characteristic = characteristic, let leftParen = characteristic.firstIndex(of: "("), let lastIndex = characteristic.firstIndex(of: ")") else {
            return nil
        }
        
        let firstIndex = characteristic.index(after: leftParen)
        return "\(String(characteristic[firstIndex..<lastIndex]))"
    }
    
    var morseLetter: String {
        guard let characteristic = characteristic, let newline = characteristic.firstIndex(of: "\n") else {
            return ""
        }
        
        return "\(String(characteristic[characteristic.startIndex..<newline]))"
    }
    
    var azimuthCoverage: [ImageSector]? {
        guard let remarks = stationRemark else {
            return nil
        }
        var sectors: [ImageSector] = []
        let pattern = #"(?<azimuth>(Azimuth coverage)?).?((?<startdeg>(\d*))\^)?((?<startminutes>[0-9]*)[\`'])?(-(?<enddeg>(\d*))\^)?(?<endminutes>[0-9]*)[\`']?\."#
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
                            start = start! + ((Double(remarks[range]) ?? 0.0) - 90)
                        } else {
                            start = (Double(remarks[range]) ?? 0.0) - 90
                        }
                    } else if component == "startminutes" {
                        if start != nil {
                            start = start! + (Double(remarks[range]) ?? 0.0) / 60
                        } else {
                            start = (Double(remarks[range]) ?? 0.0) / 60
                        }
                    } else if component == "enddeg" {
                        end = (Double(remarks[range]) ?? 0.0) - 90
                    } else if component == "endminutes" {
                        end += (Double(remarks[range]) ?? 0.0) / 60
                    }
                }
            }
            if let start = start {
                sectors.append(ImageSector(startDegrees: start, endDegrees: end, color: RadioBeacon.color))
            } else {
                if end <= previousEnd {
                    end += 360
                }
                sectors.append(ImageSector(startDegrees: previousEnd, endDegrees: end, color: RadioBeacon.color))
            }
            previousEnd = end
        })
        if sectors.isEmpty {
            return nil
        }
        return sectors
    }
        
    var description: String {
        return "RADIO BEACON\n\n" +
        "aidType \(aidType ?? "")\n" +
        "characteristic \(characteristic ?? "")\n" +
        "deleteFlag \(deleteFlag ?? "")\n" +
        "featureNumber \(featureNumber ?? 0)\n" +
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
        "regionHeading \(regionHeading ?? "")\n" +
        "removeFromList \(removeFromList ?? "")\n" +
        "sequenceText \(sequenceText ?? "")\n" +
        "stationRemark \(stationRemark ?? "")\n" +
        "volumeNumber \(volumeNumber ?? "")"
    }
}

extension RadioBeaconModel: DataSource {
    var itemTitle: String {
        return "\(self.name ?? "\(self.featureNumber ?? 0)")"
    }
    
    var sfGeometry: SFGeometry? {
        return SFPoint(xValue: coordinate.longitude, andYValue: coordinate.latitude)
    }
    
    var color: UIColor {
        return RadioBeacon.color
    }
    static var isMappable: Bool = true
    static var dataSourceName: String = NSLocalizedString("Beacons", comment: "Radio Beacons data source display name")
    static var fullDataSourceName: String = NSLocalizedString("Radio Beacons", comment: "Radio Beacons data source display name")
    static var key: String = "radioBeacon"
    static var metricsKey: String = "radioBeacons"
    static var imageName: String? = nil
    static var systemImageName: String? = "antenna.radiowaves.left.and.right"
    static var color: UIColor = UIColor(argbValue: 0xFF007BFF)
    static var imageScale = UserDefaults.standard.imageScale(key) ?? 0.66
    
    static var defaultSort: [DataSourceSortParameter] = [DataSourceSortParameter(property:DataSourceProperty(name: "Geopolitical Heading", key: #keyPath(RadioBeacon.geopoliticalHeading), type: .string), ascending: true, section: true), DataSourceSortParameter(property:DataSourceProperty(name: "Feature Number", key: #keyPath(RadioBeacon.featureNumber), type: .int), ascending: true)]
    static var defaultFilter: [DataSourceFilterParameter] = []
    
    static var properties: [DataSourceProperty] = [
        DataSourceProperty(name: "Location", key: #keyPath(RadioBeacon.mgrs10km), type: .location),
        DataSourceProperty(name: "Latitude", key: #keyPath(RadioBeacon.latitude), type: .latitude),
        DataSourceProperty(name: "Longitude", key: #keyPath(RadioBeacon.longitude), type: .longitude),
        DataSourceProperty(name: "Feature Number", key: #keyPath(RadioBeacon.featureNumber), type: .int),
        DataSourceProperty(name: "Geopolitical Heading", key: #keyPath(RadioBeacon.geopoliticalHeading), type: .string),
        DataSourceProperty(name: "Name", key: #keyPath(RadioBeacon.name), type: .string),
        DataSourceProperty(name: "Range (nm)", key: #keyPath(RadioBeacon.range), type: .int),
        DataSourceProperty(name: "Frequency (kHz)", key: #keyPath(RadioBeacon.frequency), type: .string),
        DataSourceProperty(name: "Station Remark", key: #keyPath(RadioBeacon.stationRemark), type: .string),
        DataSourceProperty(name: "Characteristic", key: #keyPath(RadioBeacon.characteristic), type: .string),
        DataSourceProperty(name: "Sequence Text", key: #keyPath(RadioBeacon.sequenceText), type: .string),
        DataSourceProperty(name: "Notice Number", key: #keyPath(RadioBeacon.noticeNumber), type: .int),
        DataSourceProperty(name: "Notice Week", key: #keyPath(RadioBeacon.noticeWeek), type: .string),
        DataSourceProperty(name: "Notice Year", key: #keyPath(RadioBeacon.noticeYear), type: .string),
        DataSourceProperty(name: "Volume Number", key: #keyPath(RadioBeacon.volumeNumber), type: .string),
        DataSourceProperty(name: "Preceding Note", key: #keyPath(RadioBeacon.precedingNote), type: .string),
        DataSourceProperty(name: "Post Note", key: #keyPath(RadioBeacon.postNote), type: .string),
        DataSourceProperty(name: "Aid Type", key: #keyPath(RadioBeacon.aidType), type: .string),
        DataSourceProperty(name: "Region Heading", key: #keyPath(RadioBeacon.regionHeading), type: .string),
        DataSourceProperty(name: "Remove From List", key: #keyPath(RadioBeacon.removeFromList), type: .string),
        DataSourceProperty(name: "Delete Flag", key: #keyPath(RadioBeacon.deleteFlag), type: .string)
    ]
    
    static func postProcess() {}
}

extension RadioBeaconModel: MapImage {
    
    static var cacheTiles: Bool = true
    
    func mapImage(marker: Bool, zoomLevel: Int, tileBounds3857: MapBoundingBox?, context: CGContext? = nil) -> [UIImage] {
        let scale = marker ? 1 : 2
        
        var images: [UIImage] = []
        if let raconImage = raconImage(scale: scale, azimuthCoverage: azimuthCoverage, zoomLevel: zoomLevel) {
            images.append(raconImage)
        }
        return images
    }
    
    func raconImage(scale: Int, azimuthCoverage: [ImageSector]? = nil, zoomLevel: Int) -> UIImage? {
        let radius = CGFloat(zoomLevel) / 3.0 * UIScreen.main.scale * RadioBeacon.imageScale
        let sectors = azimuthCoverage ?? [ImageSector(startDegrees: 0, endDegrees: 360, color: RadioBeacon.color)]
        
        if zoomLevel > 8 {
            return RaconImage(frame: CGRect(x: 0, y: 0, width: 3 * (radius + 3.0), height: 3 * (radius + 3.0)), sectors: sectors, arcWidth: 3.0, arcRadius: radius + 3.0, text: "Racon (\(morseLetter))", darkMode: false)
        } else {
            return CircleImage(color: RadioBeacon.color, radius: radius, fill: false, arcWidth: min(3.0, radius / 2.0))
        }
    }
}
