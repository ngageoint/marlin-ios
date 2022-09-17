//
//  RadioBeacon+DataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import UIKit
import CoreData

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
}

extension RadioBeacon: BatchImportable {
    static var seedDataFiles: [String]? = ["radioBeacon"]
    static var decodableRoot: Decodable.Type = RadioBeaconPropertyContainer.self
    
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
    
    static func shouldSync() -> Bool {
        // sync once every week
        return UserDefaults.standard.dataSourceEnabled(RadioBeacon.self) && (Date().timeIntervalSince1970 - (60 * 60 * 24 * 7)) > UserDefaults.standard.lastSyncTimeSeconds(RadioBeacon.self)
    }
    
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
    
}
