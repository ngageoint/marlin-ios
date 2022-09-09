//
//  RadioBeacon+CoreDataClass.swift
//  Marlin
//
//  Created by Daniel Barela on 8/25/22.
//

import Foundation
import CoreData
import MapKit
import OSLog
import SwiftUI

struct RadioBeaconVolume {
    var volumeQuery: String
    var volumeNumber: String
}

extension RadioBeacon: DataSource {
    var color: UIColor {
        return RadioBeacon.color
    }
    static var isMappable: Bool = true
    static var dataSourceName: String = NSLocalizedString("Beacons", comment: "Radio Beacons data source display name")
    static var fullDataSourceName: String = NSLocalizedString("Radio Beacons", comment: "Radio Beacons data source display name")
    static var key: String = "radioBeacon"
    static var imageName: String? = nil
    static var systemImageName: String? = "antenna.radiowaves.left.and.right"
    static var color: UIColor = UIColor(argbValue: 0xFF007BFF)
    static var imageScale = UserDefaults.standard.imageScale(key) ?? 0.66
    static var seedDataFiles: [String]? = ["radioBeacon"]
    
    static func batchImport(value: Decodable?) async throws {
        guard let value = value as? RadioBeaconPropertyContainer else {
            return
        }
        let count = value.ngalol.count
        NSLog("Received \(count) \(Self.key) records.")
        try await Self.batchImport(from: value.ngalol, taskContext: PersistenceController.shared.newTaskContext())
    }
    
    static func dataRequest() -> [MSIRouter] {
        let newestRadioBeacon = try? PersistenceController.shared.container.viewContext.fetchFirst(RadioBeacon.self, sortBy: [NSSortDescriptor(keyPath: \RadioBeacon.noticeNumber, ascending: false)])
        
        let noticeWeek = Int(newestRadioBeacon?.noticeWeek ?? "0") ?? 0
        
        print("Query for radio beacons after year:\(newestRadioBeacon?.noticeYear ?? "") week:\(noticeWeek)")
        return [MSIRouter.readRadioBeacons(noticeYear: newestRadioBeacon?.noticeYear, noticeWeek: String(format: "%02d", noticeWeek + 1))]
    }
    
}

extension RadioBeacon: DataSourceViewBuilder {
    var detailView: AnyView {
        AnyView(RadioBeaconDetailView(radioBeacon: self))
    }
    
    func summaryView(showMoreDetails: Bool = false, showSectionHeader: Bool = false) -> AnyView {
        AnyView(RadioBeaconSummaryView(radioBeacon: self, showMoreDetails: showMoreDetails, showSectionHeader: showSectionHeader))
    }
}

class RadioBeacon: NSManagedObject, MKAnnotation, AnnotationWithView, MapImage {
    
    var clusteringIdentifier: String? = nil
    
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
            KeyValue(key: "Number", value: "\(featureNumber)"),
            KeyValue(key: "Name & Location", value: name),
            KeyValue(key: "Geopolitical Heading", value: geopoliticalHeading),
            KeyValue(key: "Position", value: "\(position ?? "")"),
            KeyValue(key: "Characteristic", value: expandedCharacteristic),
            KeyValue(key: "Range (nmi)", value: "\(range)"),
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
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
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
    
    func mapImage(marker: Bool, zoomLevel: Int, tileBounds3857: MapBoundingBox?) -> [UIImage] {
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
    
    
    func view(on: MKMapView) -> MKAnnotationView {
        let annotationView = on.dequeueReusableAnnotationView(withIdentifier: RadioBeacon.key, for: self)
        let images = self.mapImage(marker: true, zoomLevel: on.zoomLevel, tileBounds3857: nil)
        
        let largestSize = images.reduce(CGSize(width: 0, height: 0)) { partialResult, image in
            return CGSize(width: max(partialResult.width, image.size.width), height: max(partialResult.height, image.size.height))
        }
        
        UIGraphicsBeginImageContext(largestSize)
        for image in images {
            image.draw(at: CGPoint(x: (largestSize.width / 2.0) - (image.size.width / 2.0), y: (largestSize.height / 2.0) - (image.size.height / 2.0)))
        }
        
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        guard let cgImage = newImage.cgImage else {
            return annotationView
        }
        let image = UIImage(cgImage: cgImage)
        
        if let lav = annotationView as? ImageAnnotationView {
            lav.combinedImage = image
        } else {
            annotationView.image = image
        }
        self.annotationView = annotationView
        return annotationView
    }
    
    var annotationView: MKAnnotationView?
    
    static func newBatchInsertRequest(with propertyList: [RadioBeaconProperties]) -> NSBatchInsertRequest {
        var index = 0
        let total = propertyList.count
        NSLog("Creating batch insert request of radio beacons for \(total) radio beacons")
        
        struct PreviousLocation {
            var previousRegionHeading: String?
            var previousSubregionHeading: String?
            var previousLocalHeading: String?
        }
        
        var previousHeadingPerVolume: [String : PreviousLocation] = [:]
        // Provide one dictionary at a time when the closure is called.
        let batchInsertRequest = NSBatchInsertRequest(entity: RadioBeacon.entity(), dictionaryHandler: { dictionary in
            guard index < total else { return true }
            let propertyDictionary = propertyList[index].dictionaryValue
            let volumeNumber = propertyDictionary["volumeNumber"] as? String ?? ""
            var previousLocation = previousHeadingPerVolume[volumeNumber]
            let region = propertyDictionary["regionHeading"] as? String ?? previousLocation?.previousRegionHeading
            let subregion = propertyDictionary["subregionHeading"] as? String ?? previousLocation?.previousSubregionHeading
            let local = propertyDictionary["localHeading"] as? String ?? previousLocation?.previousSubregionHeading
            
            var correctedLocationDictionary: [String:String?] = [
                "regionHeading": propertyDictionary["regionHeading"] as? String ?? previousLocation?.previousRegionHeading,
                "subregionHeading": propertyDictionary["subregionHeading"] as? String ?? previousLocation?.previousSubregionHeading,
                "localHeading": propertyDictionary["localHeading"] as? String ?? previousLocation?.previousSubregionHeading
            ]
            correctedLocationDictionary["sectionHeader"] = "\(propertyDictionary["geopoliticalHeading"] as? String ?? "")\(correctedLocationDictionary["regionHeading"] != nil ? ": \(correctedLocationDictionary["regionHeading"] as? String ?? "")" : "")"
            if let rh = correctedLocationDictionary["regionHeading"] as? String {
                correctedLocationDictionary["sectionHeader"] = "\(propertyDictionary["geopoliticalHeading"] as? String ?? ""): \(rh)"
            } else {
                correctedLocationDictionary["sectionHeader"] = "\(propertyDictionary["geopoliticalHeading"] as? String ?? "")"
            }
            
            if previousLocation?.previousRegionHeading != region {
                previousLocation?.previousRegionHeading = region
                previousLocation?.previousSubregionHeading = nil
                previousLocation?.previousLocalHeading = nil
            } else if previousLocation?.previousSubregionHeading != subregion {
                previousLocation?.previousSubregionHeading = subregion
                previousLocation?.previousLocalHeading = nil
            } else if previousLocation?.previousLocalHeading != local {
                previousLocation?.previousLocalHeading = local
            }
            previousHeadingPerVolume[volumeNumber] = previousLocation ?? PreviousLocation(previousRegionHeading: region, previousSubregionHeading: subregion, previousLocalHeading: local)
            
            dictionary.addEntries(from: propertyDictionary.filter({
                return $0.value != nil
            }) as [AnyHashable : Any])
            dictionary.addEntries(from: correctedLocationDictionary.filter({
                return $0.value != nil
            }) as [AnyHashable : Any])
            index += 1
            return false
        })
        return batchInsertRequest
    }
    
    static func batchImport(from propertiesList: [RadioBeaconProperties], taskContext: NSManagedObjectContext) async throws {
        guard !propertiesList.isEmpty else { return }
        
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importRadioBeacon"
        
        /// - Tag: performAndWait
        try await taskContext.perform {
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = RadioBeacon.newBatchInsertRequest(with: propertiesList)
            batchInsertRequest.resultType = .count
            if let fetchResult = try? taskContext.execute(batchInsertRequest),
               let batchInsertResult = fetchResult as? NSBatchInsertResult {
                if let count = batchInsertResult.result as? Int, count > 0 {
                    NSLog("Inserted \(count) RadioBeacon records")
                    NotificationCenter.default.post(name: .DataSourceUpdated, object: DataSourceItem(dataSource: RadioBeacon.self))
                } else {
                    NSLog("No new RadioBeacon records")
                }
                return
            }
            batchInsertRequest.resultType = .count
            throw MSIError.batchInsertError
        }
    }
    
    override var description: String {
        return "RADIO BEACON\n\n" +
        "aidType \(aidType ?? "")\n" +
        "characteristic \(characteristic ?? "")\n" +
        "deleteFlag \(deleteFlag ?? "")\n" +
        "featureNumber \(featureNumber)\n" +
        "geopoliticalHeading \(geopoliticalHeading ?? "")\n" +
        "latitude \(latitude)\n" +
        "longitude \(longitude)\n" +
        "name \(name ?? "")\n" +
        "noticeNumber \(noticeNumber)\n" +
        "noticeWeek \(noticeWeek ?? "")\n" +
        "noticeYear \(noticeYear ?? "")\n" +
        "position \(position ?? "")\n" +
        "postNote \(postNote ?? "")\n" +
        "precedingNote \(precedingNote ?? "")\n" +
        "range \(range)\n" +
        "regionHeading \(regionHeading ?? "")\n" +
        "removeFromList \(removeFromList ?? "")\n" +
        "sequenceText \(sequenceText ?? "")\n" +
        "stationRemark \(stationRemark ?? "")\n" +
        "volumeNumber \(volumeNumber ?? "")"
    }
}

struct RadioBeaconPropertyContainer: Decodable {
    private enum CodingKeys: String, CodingKey {
        case ngalol
    }
    let ngalol: [RadioBeaconProperties]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        ngalol = try container.decode([Throwable<RadioBeaconProperties>].self, forKey: .ngalol).compactMap { try? $0.result.get() }
    }
}

struct RadioBeaconProperties: Decodable {
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    // MARK: Codable
    
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
    let latitude: Double?
    let longitude: Double?
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
    let sequenceText: String?
    let stationRemark: String?
    let volumeNumber: String?

    
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
        self.sequenceText = try? values.decode(String.self, forKey: .sequenceText)
        self.stationRemark = try? values.decode(String.self, forKey: .stationRemark)
        
        if let position = self.position {
            let coordinate = LightsProperties.parsePosition(position: position)
            self.longitude = coordinate.longitude
            self.latitude = coordinate.latitude
        } else {
            self.longitude = 0.0
            self.latitude = 0.0
        }
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
}


