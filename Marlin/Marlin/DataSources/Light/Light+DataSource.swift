//
//  Light+DataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import UIKit
import CoreData
import Alamofire
import MapKit

extension Light: DataSourceLocation, GeoPackageExportable {
    var sfGeometry: SFGeometry? {
        return SFPoint(xValue: coordinate.longitude, andYValue: coordinate.latitude)
    }
    
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }
    
    static var isMappable: Bool = true
    static var dataSourceName: String = NSLocalizedString("Lights", comment: "Lights data source display name")
    static var fullDataSourceName: String = NSLocalizedString("Lights", comment: "Lights data source display name")
    static var key: String = "light"
    static var metricsKey: String = "lights"
    static var imageName: String? = nil
    static var systemImageName: String? = "lightbulb.fill"
    static var color: UIColor = UIColor(argbValue: 0xFFFFC500)
    static var imageScale = UserDefaults.standard.imageScale(key) ?? 0.66
    
    static var defaultSort: [DataSourceSortParameter] = [DataSourceSortParameter(property:DataSourceProperty(name: "Region", key: #keyPath(Light.sectionHeader), type: .string), ascending: true), DataSourceSortParameter(property:DataSourceProperty(name: "Feature Number", key: #keyPath(Light.featureNumber), type: .int), ascending: true)]
    static var defaultFilter: [DataSourceFilterParameter] = []
    
    static var properties: [DataSourceProperty] = [
        DataSourceProperty(name: "Location", key: #keyPath(Light.mgrs10km), type: .location),
        DataSourceProperty(name: "Latitude", key: #keyPath(Light.latitude), type: .latitude),
        DataSourceProperty(name: "Longitude", key: #keyPath(Light.longitude), type: .longitude),
        DataSourceProperty(name: "Feature Number", key: #keyPath(Light.featureNumber), type: .string),
        DataSourceProperty(name: "International Feature Number", key: #keyPath(Light.internationalFeature), type: .string),
        DataSourceProperty(name: "Name", key: #keyPath(Light.name), type: .string),
        DataSourceProperty(name: "Structure", key: #keyPath(Light.structure), type: .string),
        DataSourceProperty(name: "Focal Plane Elevation (ft)", key: #keyPath(Light.heightFeet), type: .double),
        DataSourceProperty(name: "Focal Plane Elevation (m)", key: #keyPath(Light.heightMeters), type: .double),
        DataSourceProperty(name: "Range (nm)", key: #keyPath(Light.lightRange), type: .double, subEntityKey: #keyPath(LightRange.range)),
        DataSourceProperty(name: "Remarks", key: #keyPath(Light.remarks), type: .string),
        DataSourceProperty(name: "Characteristic", key: #keyPath(Light.characteristic), type: .string),
        DataSourceProperty(name: "Signal", key: #keyPath(Light.characteristic), type: .string),
        DataSourceProperty(name: "Notice Number", key: #keyPath(Light.noticeNumber), type: .int),
        DataSourceProperty(name: "Notice Week", key: #keyPath(Light.noticeWeek), type: .string),
        DataSourceProperty(name: "Notice Year", key: #keyPath(Light.noticeYear), type: .string),
        DataSourceProperty(name: "Volume Number", key: #keyPath(Light.volumeNumber), type: .string),
        DataSourceProperty(name: "Preceding Note", key: #keyPath(Light.precedingNote), type: .string),
        DataSourceProperty(name: "Post Note", key: #keyPath(Light.postNote), type: .string),
        DataSourceProperty(name: "Region", key: #keyPath(Light.sectionHeader), type: .string),
        DataSourceProperty(name: "Geopolitical Heading", key: #keyPath(Light.geopoliticalHeading), type: .string),
        DataSourceProperty(name: "Region Heading", key: #keyPath(Light.regionHeading), type: .string),
        DataSourceProperty(name: "Subregion Heading", key: #keyPath(Light.subregionHeading), type: .string),
        DataSourceProperty(name: "Local Heading", key: #keyPath(Light.localHeading), type: .string)
    ]
    
    var coordinateRegion: MKCoordinateRegion? {
        MKCoordinateRegion(center: self.coordinate, zoom: 14.5, bounds: CGRect(x: 0, y: 0, width: 600, height: 600))
    }
}

extension Light: BatchImportable {
    static var seedDataFiles: [String]? = ["lights"]
    static var decodableRoot: Decodable.Type = LightsPropertyContainer.self
    
    static func getRequeryRequest(initialRequest: URLRequestConvertible) -> URLRequestConvertible? {
        guard let url = initialRequest.urlRequest?.url else {
            return nil
        }
        let components = URLComponents(string: url.absoluteString)
        var volume: String? = nil
        if let queryItems = components?.queryItems {
            for queryItem in queryItems {
                if queryItem.name == "volume" {
                    volume = queryItem.value
                }
            }
        }
        if let volume = volume {
            return MSIRouter.readLights(volume: volume)
        }
        return nil
    }
    
    static func batchImport(value: Decodable?, initialLoad: Bool = false) async throws -> Int {
        guard let value = value as? LightsPropertyContainer else {
            return 0
        }
        let count = value.ngalol.count
        NSLog("Received \(count) \(Self.key) records.")
        // if this is not the first load and we got back records, re-query
        if count != 0 && !initialLoad {
            return -1
        }
        return try await Light.importRecords(from: value.ngalol, taskContext: PersistenceController.current.newTaskContext())
    }
    
    static func dataRequest() -> [MSIRouter] {
        var requests: [MSIRouter] = []
        
        for lightVolume in Light.lightVolumes {
            let context = PersistenceController.current.newTaskContext()
            context.performAndWait {
                let newestLight = try? PersistenceController.current.fetchFirst(Light.self, sortBy: [NSSortDescriptor(keyPath: \Light.noticeNumber, ascending: false)], predicate: NSPredicate(format: "volumeNumber = %@", lightVolume.volumeNumber), context: context)
                
                let noticeWeek = Int(newestLight?.noticeWeek ?? "0") ?? 0
                
                print("Query for lights in volume \(lightVolume) after year:\(newestLight?.noticeYear ?? "") week:\(noticeWeek)")
                
                requests.append(MSIRouter.readLights(volume: lightVolume.volumeQuery, noticeYear: newestLight?.noticeYear, noticeWeek: String(format: "%02d", noticeWeek + 1)))
            }
        }
        
        return requests
    }
    
    static func shouldSync() -> Bool {
        // sync once every week
        return UserDefaults.standard.dataSourceEnabled(Light.self) && (Date().timeIntervalSince1970 - (60 * 60 * 24 * 7)) > UserDefaults.standard.lastSyncTimeSeconds(Light.self)
    }
    
    static func newBatchInsertRequest(with propertyList: [LightsProperties]) -> NSBatchInsertRequest {
        var index = 0
        let total = propertyList.count
        NSLog("Creating batch insert request of lights for \(total) lights")
        
        struct PreviousLocation {
            var previousRegionHeading: String?
            var previousSubregionHeading: String?
            var previousLocalHeading: String?
        }
        
        var previousHeadingPerVolume: [String : PreviousLocation] = [:]
        // Provide one dictionary at a time when the closure is called.
        let batchInsertRequest = NSBatchInsertRequest(entity: Light.entity(), dictionaryHandler: { dictionary in
            guard index < total else { return true }
            let propertyDictionary = propertyList[index].dictionaryValue
            let volumeNumber = propertyDictionary["volumeNumber"] as? String ?? ""
            var previousLocation = previousHeadingPerVolume[volumeNumber]
            
            let region = propertyDictionary["regionHeading"] as? String ?? previousLocation?.previousRegionHeading
            let subregion = propertyDictionary["subregionHeading"] as? String ?? previousLocation?.previousSubregionHeading
            let local = propertyDictionary["localHeading"] as? String ?? previousLocation?.previousLocalHeading
            
            var correctedLocationDictionary: [String:String?] = [
                "regionHeading": propertyDictionary["regionHeading"] as? String ?? previousLocation?.previousRegionHeading,
                "subregionHeading": propertyDictionary["subregionHeading"] as? String ?? previousLocation?.previousSubregionHeading,
                "localHeading": propertyDictionary["localHeading"] as? String ?? previousLocation?.previousLocalHeading
            ]
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
    
    static func importRecords(from propertiesList: [LightsProperties], taskContext: NSManagedObjectContext) async throws -> Int {
        guard !propertiesList.isEmpty else { return 0 }
        
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importLight"
        
        /// - Tag: performAndWait
        return try await taskContext.perform {
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = Light.newBatchInsertRequest(with: propertiesList)
            batchInsertRequest.resultType = .count
            do {
                let fetchResult = try taskContext.execute(batchInsertRequest)
                if let batchInsertResult = fetchResult as? NSBatchInsertResult {
                    try? taskContext.save()
                    if let count = batchInsertResult.result as? Int, count > 0 {
                        NSLog("Inserted \(count) Light records")
                        return count
                    } else {
                        NSLog("No new Light records")
                    }
                    // if there were already lights in the db for this volume and this was an update and we got back a light we have to go redo the query due to regions not being populated on all returned objects
                    return 0
                }
            } catch {
                print("error was \(error)")
            }
            throw MSIError.batchInsertError
        }
    }
}
