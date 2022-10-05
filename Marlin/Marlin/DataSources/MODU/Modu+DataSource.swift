//
//  Modu+DataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import UIKit
import CoreData

extension Modu: DataSource {
    static var isMappable: Bool = true
    static var dataSourceName: String = NSLocalizedString("MODU", comment: "MODU data source display name")
    static var fullDataSourceName: String = NSLocalizedString("Mobile Offshore Drilling Units", comment: "MODU data source display name")
    static var key: String = "modu"
    static var imageName: String? = "modu"
    static var systemImageName: String? = nil
    static var color: UIColor = UIColor(argbValue: 0xFF0042A4)
    static var imageScale = UserDefaults.standard.imageScale(key) ?? 1.0
    
    static var defaultSort: [DataSourceSortParameter] = [DataSourceSortParameter(property:DataSourceProperty(name: "Date", key: #keyPath(Modu.date), type: .date), ascending: false)]
    
    static var properties: [DataSourceProperty] = [
        DataSourceProperty(name: "Subregion", key: #keyPath(Modu.subregion), type: .int),
        DataSourceProperty(name: "Region", key: #keyPath(Modu.region), type: .int),
        DataSourceProperty(name: "Longitude", key: #keyPath(Modu.longitude), type: .double),
        DataSourceProperty(name: "Latitude", key: #keyPath(Modu.latitude), type: .double),
        DataSourceProperty(name: "Distance", key: #keyPath(Modu.distance), type: .double),
        DataSourceProperty(name: "Special Status", key: #keyPath(Modu.specialStatus), type: .string),
        DataSourceProperty(name: "Rig Status", key: #keyPath(Modu.rigStatus), type: .string),
        DataSourceProperty(name: "Nav Area", key: #keyPath(Modu.navArea), type: .string),
        DataSourceProperty(name: "Name", key: #keyPath(Modu.name), type: .string),
        DataSourceProperty(name: "Date", key: #keyPath(Modu.date), type: .date),
    ]
    
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }
}

extension Modu: BatchImportable {
    static var seedDataFiles: [String]? = ["modu"]
    static var decodableRoot: Decodable.Type = ModuPropertyContainer.self
    
    static func batchImport(value: Decodable?) async throws -> Int {
        guard let value = value as? ModuPropertyContainer else {
            return 0
        }
        let count = value.modu.count
        NSLog("Received \(count) \(Self.key) records.")
        return try await Modu.importRecords(from: value.modu, taskContext: PersistenceController.shared.newTaskContext())
    }
    
    static func dataRequest() -> [MSIRouter] {
        let newestModu = try? PersistenceController.shared.container.viewContext.fetchFirst(Modu.self, sortBy: [NSSortDescriptor(keyPath: \Modu.date, ascending: false)])
        return [MSIRouter.readModus(date: newestModu?.dateString)]
    }
    
    static func shouldSync() -> Bool {
        // sync once every hour
        return UserDefaults.standard.dataSourceEnabled(Modu.self) && (Date().timeIntervalSince1970 - (60 * 60)) > UserDefaults.standard.lastSyncTimeSeconds(Modu.self)
    }
    
    static func newBatchInsertRequest(with propertyList: [ModuProperties]) -> NSBatchInsertRequest {
        var index = 0
        let total = propertyList.count
        
        // Provide one dictionary at a time when the closure is called.
        let batchInsertRequest = NSBatchInsertRequest(entity: Modu.entity(), dictionaryHandler: { dictionary in
            guard index < total else { return true }
            dictionary.addEntries(from: propertyList[index].dictionaryValue.filter({
                return $0.value != nil
            }) as [AnyHashable : Any])
            index += 1
            return false
        })
        return batchInsertRequest
    }
    
    static func importRecords(from propertiesList: [ModuProperties], taskContext: NSManagedObjectContext) async throws -> Int {
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
