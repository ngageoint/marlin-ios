//
//  DifferentialGPSStation+DataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import UIKit
import CoreData

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

extension DifferentialGPSStation: BatchImportable {
    static var seedDataFiles: [String]? = ["dgps"]
    static var decodableRoot: Decodable.Type = DifferentialGPSStationPropertyContainer.self
    
    static func batchImport(value: Decodable?) async throws {
        guard let value = value as? DifferentialGPSStationPropertyContainer else {
            return
        }
        let count = value.ngalol.count
        NSLog("Received \(count) \(Self.key) records.")
        try await Self.batchImport(from: value.ngalol, taskContext: PersistenceController.shared.newTaskContext())
    }
    
    static func dataRequest() -> [MSIRouter] {
        let newestDifferentialGPSStation = try? PersistenceController.shared.container.viewContext.fetchFirst(DifferentialGPSStation.self, sortBy: [NSSortDescriptor(keyPath: \DifferentialGPSStation.noticeNumber, ascending: false)])
        
        let noticeWeek = Int(newestDifferentialGPSStation?.noticeWeek ?? "0") ?? 0
        
        print("Query for differential gps stations after year:\(newestDifferentialGPSStation?.noticeYear ?? "") week:\(noticeWeek)")
        
        return [MSIRouter.readDifferentialGPSStations(noticeYear: newestDifferentialGPSStation?.noticeYear, noticeWeek: String(format: "%02d", noticeWeek + 1))]
    }
    
    static func shouldSync() -> Bool {
        // sync once every week
        return UserDefaults.standard.dataSourceEnabled(DifferentialGPSStation.self) && (Date().timeIntervalSince1970 - (60 * 60 * 24 * 7)) > UserDefaults.standard.lastSyncTimeSeconds(DifferentialGPSStation.self)
    }
    
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
}
