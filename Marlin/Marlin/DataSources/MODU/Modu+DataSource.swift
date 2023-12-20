//
//  Modu+DataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import UIKit
import CoreData

extension Modu: Bookmarkable {
    var canBookmark: Bool {
        return true
    }
    
    var itemKey: String {
        return name ?? ""
    }
    
    static func getItem(context: NSManagedObjectContext, itemKey: String?) -> Bookmarkable? {
        return getModu(context: context, name: itemKey)
    }
    
    static func getModu(context: NSManagedObjectContext, name: String?) -> Modu? {
        if let name = name {
            return context.fetchFirst(Modu.self, key: "name", value: name)
        }
        return nil
    }
}

extension Modu: Locatable, GeoPackageExportable, GeoJSONExportable {
    static var definition: any DataSourceDefinition = DataSourceDefinitions.modu.definition
    var sfGeometry: SFGeometry? {
        return SFPoint(xValue: coordinate.longitude, andYValue: coordinate.latitude)
    }
    static var isMappable: Bool = true
    static var dataSourceName: String = NSLocalizedString("MODU", comment: "MODU data source display name")
    static var fullDataSourceName: String = 
    NSLocalizedString("Mobile Offshore Drilling Units", comment: "MODU data source display name")
    static var key: String = "modu"
    static var metricsKey: String = "modus"
    static var imageName: String? = "modu"
    static var systemImageName: String?
    static var color: UIColor = UIColor(argbValue: 0xFF0042A4)
    static var imageScale = UserDefaults.standard.imageScale(key) ?? 1.0
    
    static var defaultSort: [DataSourceSortParameter] = [
        DataSourceSortParameter(
            property: DataSourceProperty(
                name: "Date",
                key: #keyPath(Modu.date),
                type: .date
            ),
            ascending: false
        )
    ]
    static var defaultFilter: [DataSourceFilterParameter] = []
    
    static var properties: [DataSourceProperty] = [
        DataSourceProperty(name: "Location", key: #keyPath(Modu.mgrs10km), type: .location),
        DataSourceProperty(name: "Subregion", key: #keyPath(Modu.subregion), type: .int),
        DataSourceProperty(name: "Region", key: #keyPath(Modu.region), type: .int),
        DataSourceProperty(name: "Longitude", key: #keyPath(Modu.longitude), type: .longitude),
        DataSourceProperty(name: "Latitude", key: #keyPath(Modu.latitude), type: .latitude),
        DataSourceProperty(name: "Distance", key: #keyPath(Modu.distance), type: .double),
        DataSourceProperty(name: "Special Status", key: #keyPath(Modu.specialStatus), type: .string),
        DataSourceProperty(name: "Rig Status", key: #keyPath(Modu.rigStatus), type: .string),
        DataSourceProperty(name: "Nav Area", key: #keyPath(Modu.navArea), type: .string),
        DataSourceProperty(name: "Name", key: #keyPath(Modu.name), type: .string),
        DataSourceProperty(name: "Date", key: #keyPath(Modu.date), type: .date)
    ]
    
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }

    static func postProcess() {}
}

extension Modu: BatchImportable {
    static var seedDataFiles: [String]? = ["modu"]
    static var decodableRoot: Decodable.Type = ModuPropertyContainer.self
    
    static func batchImport(value: Decodable?, initialLoad: Bool) async throws -> Int {
        guard let value = value as? ModuPropertyContainer else {
            return 0
        }
        let count = value.modu.count
        NSLog("Received \(count) \(Self.key) records.")
        return try await Modu.importRecords(
            from: value.modu,
            taskContext: PersistenceController.current.newTaskContext()
        )
    }
    
    static func dataRequest() -> [MSIRouter] {
        let context = PersistenceController.current.newTaskContext()
        var date: String?
        context.performAndWait {
            let newestModu = try? PersistenceController.current.fetchFirst(
                Modu.self,
                sortBy: [NSSortDescriptor(keyPath: \Modu.date, ascending: false)],
                predicate: nil,
                context: context
            )
            date = newestModu?.dateString
        }
        return [MSIRouter.readModus(date: date)]
    }
    
    static func shouldSync() -> Bool {
        // sync once every hour
        return UserDefaults.standard.dataSourceEnabled(Modu.definition) 
        && (Date().timeIntervalSince1970 - (60 * 60)) > UserDefaults.standard.lastSyncTimeSeconds(Modu.definition)
    }
    
    static func newBatchInsertRequest(with propertyList: [ModuModel]) -> NSBatchInsertRequest {
        var index = 0
        let total = propertyList.count
        
        // Provide one dictionary at a time when the closure is called.
        let batchInsertRequest = NSBatchInsertRequest(entity: Modu.entity(), dictionaryHandler: { dictionary in
            guard index < total else { return true }
            let propertyDictionary = propertyList[index].dictionaryValue
            dictionary.addEntries(from: propertyDictionary.mapValues({ value in
                if let value = value {
                    return value
                }
                return NSNull()
            }) as [AnyHashable: Any])
            
            index += 1
            return false
        })
        return batchInsertRequest
    }
    
    static func importRecords(
        from propertiesList: [ModuModel],
        taskContext: NSManagedObjectContext
    ) async throws -> Int {
        guard !propertiesList.isEmpty else { return 0 }
        
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importModus"
        
        /// - Tag: performAndWait
        return try await taskContext.perform {
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = Modu.newBatchInsertRequest(with: propertiesList)
            batchInsertRequest.resultType = .count
            if let fetchResult = try? taskContext.execute(batchInsertRequest),
               let batchInsertResult = fetchResult as? NSBatchInsertResult {
                try? taskContext.save()
                if let count = batchInsertResult.result as? Int, count > 0 {
                    NSLog("Inserted \(count) MODU records")
                    return count
                } else {
                    NSLog("No new MODU records")
                }
                return 0
            }
            throw MSIError.batchInsertError
        }
    }
}
