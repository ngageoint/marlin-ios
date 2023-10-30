//
//  DifferentialGPSStation+DataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import UIKit
import CoreData

extension DifferentialGPSStation: Bookmarkable {
    var canBookmark: Bool {
        return true
    }
    
    var itemKey: String {
        return "\(featureNumber)--\(volumeNumber ?? "")"
    }
    
    static func getItem(context: NSManagedObjectContext, itemKey: String?) -> Bookmarkable? {
        if let split = itemKey?.split(separator: "--"), split.count == 2 {
            return getDifferentialGPSStation(context: context, featureNumber: "\(split[0])", volumeNumber: "\(split[1])")
        }
        
        return nil
    }
    
    static func getDifferentialGPSStation(context: NSManagedObjectContext, featureNumber: String?, volumeNumber: String?) -> DifferentialGPSStation? {
        if let featureNumber = featureNumber, let volumeNumber = volumeNumber {
            return try? context.fetchFirst(DifferentialGPSStation.self, predicate: NSPredicate(format: "featureNumber = %@ AND volumeNumber = %@", argumentArray: [featureNumber, volumeNumber]))
        }
        return nil
    }
}

extension DifferentialGPSStation: Locatable, GeoPackageExportable, GeoJSONExportable {
    static var definition: any DataSourceDefinition = DataSourceDefinitions.dgps.definition
    var sfGeometry: SFGeometry? {
        return SFPoint(xValue: coordinate.longitude, andYValue: coordinate.latitude)
    }
    
    var color: UIColor {
        return DifferentialGPSStation.color
    }
    static var isMappable: Bool = true
    static var dataSourceName: String = NSLocalizedString("DGPS", comment: "Differential GPS Station data source display name")
    static var fullDataSourceName: String = NSLocalizedString("Differential GPS Stations", comment: "Differential GPS Station data source display name")
    
    static var key: String = "differentialGPSStation"
    static var metricsKey: String = "dgpsStations"
    static var imageName: String? = "dgps"
    static var systemImageName: String? = nil
    static var color: UIColor = UIColor(argbValue: 0xFF00E676)
    static var imageScale = UserDefaults.standard.imageScale(key) ?? 0.66
    
    static var defaultSort: [DataSourceSortParameter] = [DataSourceSortParameter(property:DataSourceProperty(name: "Geopolitical Heading", key: #keyPath(DifferentialGPSStation.geopoliticalHeading), type: .string), ascending: true, section: true), DataSourceSortParameter(property:DataSourceProperty(name: "Feature Number", key: #keyPath(DifferentialGPSStation.featureNumber), type: .int), ascending: true)]
    static var defaultFilter: [DataSourceFilterParameter] = []
    
    static var properties: [DataSourceProperty] = [
        DataSourceProperty(name: "Location", key: #keyPath(DifferentialGPSStation.mgrs10km), type: .location),
        DataSourceProperty(name: "Latitude", key: #keyPath(DifferentialGPSStation.latitude), type: .latitude),
        DataSourceProperty(name: "Longitude", key: #keyPath(DifferentialGPSStation.longitude), type: .longitude),
        DataSourceProperty(name: "Number", key: #keyPath(DifferentialGPSStation.featureNumber), type: .int),
        DataSourceProperty(name: "Name", key: #keyPath(DifferentialGPSStation.name), type: .string),
        DataSourceProperty(name: "Geopolitical Heading", key: #keyPath(DifferentialGPSStation.geopoliticalHeading), type: .string),
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
        DataSourceProperty(name: "Post Note", key: #keyPath(DifferentialGPSStation.postNote), type: .string),

    ]
    
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }
    
    static func postProcess() {}
}

extension DifferentialGPSStation: BatchImportable {
    static var seedDataFiles: [String]? = ["dgps"]
    static var decodableRoot: Decodable.Type = DifferentialGPSStationPropertyContainer.self
    
    static func batchImport(value: Decodable?, initialLoad: Bool) async throws -> Int {
        guard let value = value as? DifferentialGPSStationPropertyContainer else {
            return 0
        }
        let count = value.ngalol.count
        NSLog("Received \(count) \(Self.key) records.")
        return try await Self.importRecords(from: value.ngalol, taskContext: PersistenceController.current.newTaskContext())
    }
    
    static func dataRequest() -> [MSIRouter] {
        let context = PersistenceController.current.newTaskContext()
        var noticeWeek = 0
        var noticeYear: String?
        
        context.performAndWait {
            let newestDifferentialGPSStation = try? PersistenceController.current.fetchFirst(DifferentialGPSStation.self, sortBy: [NSSortDescriptor(keyPath: \DifferentialGPSStation.noticeNumber, ascending: false)], predicate: nil, context: context)
            noticeWeek = Int(newestDifferentialGPSStation?.noticeWeek ?? "0") ?? 0
            noticeYear = newestDifferentialGPSStation?.noticeYear
        }
        
        print("Query for differential gps stations after year:\(noticeYear ?? "") week:\(noticeWeek)")
        
        return [MSIRouter.readDifferentialGPSStations(noticeYear: noticeYear, noticeWeek: String(format: "%02d", noticeWeek + 1))]
    }
    
    static func shouldSync() -> Bool {
        // sync once every week
        return UserDefaults.standard.dataSourceEnabled(DifferentialGPSStation.definition) && (Date().timeIntervalSince1970 - (60 * 60 * 24 * 7)) > UserDefaults.standard.lastSyncTimeSeconds(DifferentialGPSStation.definition)
    }
    
    static func newBatchInsertRequest(with propertyList: [DifferentialGPSStationModel]) -> NSBatchInsertRequest {
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
            if let rh = correctedLocationDictionary["regionHeading"] as? String {
                correctedLocationDictionary["sectionHeader"] = "\(propertyDictionary["geopoliticalHeading"] as? String ?? ""): \(rh)"
            } else {
                correctedLocationDictionary["sectionHeader"] = "\(propertyDictionary["geopoliticalHeading"] as? String ?? "")"
            }
            
            if previousLocation?.previousRegionHeading != region {
                previousLocation?.previousRegionHeading = region
            }
            previousHeadingPerVolume[volumeNumber] = previousLocation ?? PreviousLocation(previousRegionHeading: region, previousSubregionHeading: nil, previousLocalHeading: nil)
            
            dictionary.addEntries(from: propertyDictionary.mapValues({ value in
                if let value = value {
                    return value
                }
                return NSNull()
            }) as [AnyHashable : Any])
            dictionary.addEntries(from: correctedLocationDictionary.mapValues({ value in
                if let value = value {
                    return value
                }
                return NSNull()
            }) as [AnyHashable : Any])
            index += 1
            return false
        })
        return batchInsertRequest
    }
    
    static func importRecords(from propertiesList: [DifferentialGPSStationModel], taskContext: NSManagedObjectContext) async throws -> Int {
        guard !propertiesList.isEmpty else { return 0 }
        
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importDGPS"
        
        /// - Tag: performAndWait
        return try await taskContext.perform {
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = DifferentialGPSStation.newBatchInsertRequest(with: propertiesList)
            batchInsertRequest.resultType = .count
            if let fetchResult = try? taskContext.execute(batchInsertRequest),
               let batchInsertResult = fetchResult as? NSBatchInsertResult {
                try? taskContext.save()
                if let count = batchInsertResult.result as? Int, count > 0 {
                    NSLog("Inserted \(count) DGPS records")
                    return count
                } else {
                    NSLog("No new DGPS records")
                }
                return 0
            }
            throw MSIError.batchInsertError
        }
    }
}
