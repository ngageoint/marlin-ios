//
//  DifferentialGPSStation+CoreDataClass.swift
//  Marlin
//
//  Created by Daniel Barela on 8/30/22.
//

import Foundation
import UIKit
import CoreData
import MapKit
import OSLog
import SwiftUI

extension DifferentialGPSStation: DataSource {
    var color: UIColor {
        return DifferentialGPSStation.color
    }
    static var isMappable: Bool = true
    static var dataSourceName: String = NSLocalizedString("DGPS", comment: "Differential GPS Station data source display name")
    static var fullDataSourceName: String = NSLocalizedString("Differential GPS Stations", comment: "Differential GPS Station data source display name")

    static var key: String = "differentialGPSStation"
    static var imageName: String? = "dgps"
    static var systemImageName: String? = nil
    static var color: UIColor = UIColor(argbValue: 0xFFFFB300)
    static var imageScale = UserDefaults.standard.imageScale(key) ?? 0.66
}

extension DifferentialGPSStation: DataSourceViewBuilder {
    var detailView: AnyView {
        AnyView(DifferentialGPSStationDetailView(differentialGPSStation: self))
    }
    
    func summaryView(showMoreDetails: Bool = false, showSectionHeader: Bool = false) -> AnyView {
        AnyView(DifferentialGPSStationSummaryView(differentialGPSStation: self, showMoreDetails: showMoreDetails, showSectionHeader: showSectionHeader))
    }
}

class DifferentialGPSStation: NSManagedObject, MKAnnotation, AnnotationWithView, MapImage {
    
    var clusteringIdentifier: String? = nil
    
    var additionalKeyValues: [KeyValue] {
        return [
            KeyValue(key: "Number", value: "\(featureNumber)"),
            KeyValue(key: "Name & Location", value: name),
            KeyValue(key: "Geopolitical Heading", value: geopoliticalHeading),
            KeyValue(key: "Position", value: position),
            KeyValue(key: "Station ID", value: stationID),
            KeyValue(key: "Range (nmi)", value: "\(range)"),
            KeyValue(key: "Frequency (kHz)", value: "\(frequency)"),
            KeyValue(key: "Transfer Rate", value: "\(transferRate)"),
            KeyValue(key: "Remarks", value: "\(remarks ?? "")"),
            KeyValue(key: "Notice Number", value: "\(noticeNumber)"),
            KeyValue(key: "Preceding Note", value: precedingNote),
            KeyValue(key: "Post Note", value: postNote)
        ]
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func mapImage(marker: Bool, zoomLevel: Int, tileBounds3857: MapBoundingBox?) -> [UIImage] {
        return defaultMapImage(marker: marker, zoomLevel: zoomLevel, tileBounds3857: tileBounds3857)
    }

    func view(on: MKMapView) -> MKAnnotationView {
        let annotationView = on.dequeueReusableAnnotationView(withIdentifier: DifferentialGPSStation.key, for: self)
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
    
    static func newBatchInsertRequest(with propertyList: [DifferentialGPSStationProperties]) -> NSBatchInsertRequest {
        var index = 0
        let total = propertyList.count
        NSLog("Creating batch insert request of Differential GPS Stations for \(total) Differential GPS Stations")
        
        struct PreviousLocation {
            var previousRegionHeading: String?
            var previousSubregionHeading: String?
            var previousLocalHeading: String?
        }
        
        var previousHeadingPerVolume: [String : PreviousLocation] = [:]
        // Provide one dictionary at a time when the closure is called.
        let batchInsertRequest = NSBatchInsertRequest(entity: DifferentialGPSStation.entity(), dictionaryHandler: { dictionary in
            guard index < total else { return true }
            let propertyDictionary = propertyList[index].dictionaryValue
            let volumeNumber = propertyDictionary["volumeNumber"] as? String ?? ""
            var previousLocation = previousHeadingPerVolume[volumeNumber]
            let region = propertyDictionary["regionHeading"] as? String ?? previousLocation?.previousRegionHeading
            
            var correctedLocationDictionary: [String:String?] = [
                "regionHeading": propertyDictionary["regionHeading"] as? String ?? previousLocation?.previousRegionHeading
            ]
            correctedLocationDictionary["sectionHeader"] = "\(propertyDictionary["geopoliticalHeading"] as? String ?? "")\(correctedLocationDictionary["regionHeading"] != nil ? ": \(correctedLocationDictionary["regionHeading"] as? String ?? "")" : "")"
            if let rh = correctedLocationDictionary["regionHeading"] as? String {
                correctedLocationDictionary["sectionHeader"] = "\(propertyDictionary["geopoliticalHeading"] as? String ?? ""): \(rh)"
            } else {
                correctedLocationDictionary["sectionHeader"] = "\(propertyDictionary["geopoliticalHeading"] as? String ?? "")"
            }
            
            if previousLocation?.previousRegionHeading != region {
                previousLocation?.previousRegionHeading = region
            }
            previousHeadingPerVolume[volumeNumber] = previousLocation ?? PreviousLocation(previousRegionHeading: region, previousSubregionHeading: nil, previousLocalHeading: nil)
            
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
    
    static func batchImport(from propertiesList: [DifferentialGPSStationProperties], taskContext: NSManagedObjectContext) async throws {
        guard !propertiesList.isEmpty else { return }
        
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importDGPS"
        
        /// - Tag: performAndWait
        try await taskContext.perform {
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = DifferentialGPSStation.newBatchInsertRequest(with: propertiesList)
            batchInsertRequest.resultType = .count
            if let fetchResult = try? taskContext.execute(batchInsertRequest),
               let batchInsertResult = fetchResult as? NSBatchInsertResult {
                if let count = batchInsertResult.result as? Int, count > 0 {
                    NSLog("Inserted \(count) DGPS records")
                    NotificationCenter.default.post(name: .DataSourceUpdated, object: DataSourceItem(dataSource: DifferentialGPSStation.self))
                } else {
                    NSLog("No new DGPS records")
                }
                return
            }
            throw MSIError.batchInsertError
        }
    }
    
    override var description: String {
        return "Differential GPS Station\n\n" +
        "aidType \(aidType ?? "")\n" +
        "deleteFlag \(deleteFlag ?? "")\n" +
        "featureNumber \(featureNumber)\n" +
        "frequency \(frequency)\n" +
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
        "remarks \(remarks ?? "")\n" +
        "regionHeading \(regionHeading ?? "")\n" +
        "removeFromList \(removeFromList ?? "")\n" +
        "stationID \(stationID ?? "")\n" +
        "transferRate \(transferRate)\n" +
        "volumeNumber \(volumeNumber ?? "")"
    }
}

struct DifferentialGPSStationPropertyContainer: Decodable {
    private enum CodingKeys: String, CodingKey {
        case ngalol
    }
    let ngalol: [DifferentialGPSStationProperties]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        ngalol = try container.decode([Throwable<DifferentialGPSStationProperties>].self, forKey: .ngalol).compactMap { try? $0.result.get() }
    }
}

struct DifferentialGPSStationProperties: Decodable {
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    // MARK: Codable
    
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
        case stationID
        case transferRate
        case volumeNumber
    }
    
    let aidType: String?
    let deleteFlag: String?
    let featureNumber: Int?
    let frequency: Int?
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
    let remarks: String?
    let removeFromList: String?
    let stationID: String?
    let transferRate: Int?
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
        self.transferRate = try? values.decode(Int.self, forKey: .transferRate)
        
        if let position = self.position {
            let coordinate = DifferentialGPSStationProperties.parsePosition(position: position)
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
            "volumeNumber": volumeNumber
            
        ]
    }
}
