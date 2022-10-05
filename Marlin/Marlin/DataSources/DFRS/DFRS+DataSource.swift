//
//  DFRS+DataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import UIKit
import CoreData

extension DFRS: DataSource {
    var color: UIColor {
        return DFRS.color
    }
    
    static var isMappable: Bool = true
    static var dataSourceName: String = NSLocalizedString("DFRS", comment: "Radio Direction Finders and Radar station data source display name")
    static var fullDataSourceName: String = NSLocalizedString("Radio Direction Finders & Radar Stations", comment: "Radio Direction Finders and Radar station data source display name")
    static var key: String = "dfrs"
    static var imageName: String? = nil
    static var systemImageName: String? = "antenna.radiowaves.left.and.right.circle"
    static var color: UIColor = UIColor(argbValue: 0xFF00E676)
    static var imageScale = UserDefaults.standard.imageScale(key) ?? 0.66
    
    static var defaultSort: [DataSourceSortParameter] = [DataSourceSortParameter(property:DataSourceProperty(name: "Area Name", key: #keyPath(DFRS.areaName), type: .string), ascending: true), DataSourceSortParameter(property:DataSourceProperty(name: "Station Number", key: #keyPath(DFRS.stationNumber), type: .double), ascending: true)]
    
    static var properties: [DataSourceProperty] = [
        DataSourceProperty(name: "Latitude", key: #keyPath(DFRS.latitude), type: .double),
        DataSourceProperty(name: "Longitude", key: #keyPath(DFRS.longitude), type: .double),
        DataSourceProperty(name: "Station Number", key: #keyPath(DFRS.stationNumber), type: .double),
        DataSourceProperty(name: "Station Name", key: #keyPath(DFRS.stationName), type: .string),
        DataSourceProperty(name: "Station Type", key: #keyPath(DFRS.stationType), type: .string),
        DataSourceProperty(name: "Area Name", key: #keyPath(DFRS.areaName), type: .string),
        DataSourceProperty(name: "Notes", key: #keyPath(DFRS.notes), type: .string),
        DataSourceProperty(name: "Remarks", key: #keyPath(DFRS.remarks), type: .string),
        DataSourceProperty(name: "Frequency", key: #keyPath(DFRS.frequency), type: .string),
        DataSourceProperty(name: "procedureText", key: #keyPath(DFRS.procedureText), type: .string),
        DataSourceProperty(name: "Range", key: #keyPath(DFRS.range), type: .double),
        DataSourceProperty(name: "Rx Latitude", key: #keyPath(DFRS.rxLatitude), type: .double),
        DataSourceProperty(name: "Rx Longitude", key: #keyPath(DFRS.rxLongitude), type: .double),
        DataSourceProperty(name: "Tx Latitude", key: #keyPath(DFRS.txLatitude), type: .double),
        DataSourceProperty(name: "Tx Longitude", key: #keyPath(DFRS.txLongitude), type: .double),
    ]
    
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }
}

extension DFRS: BatchImportable {
    static var seedDataFiles: [String]? = ["dfrs"]
    static var decodableRoot: Decodable.Type = DFRSPropertyContainer.self
    
    static func batchImport(value: Decodable?) async throws -> Int {
        guard let value = value as? DFRSPropertyContainer else {
            return 0
        }
        let count = value.dfrs.count
        NSLog("Received \(count) \(Self.key) records.")
        return try await Self.importRecords(from: value.dfrs, taskContext: PersistenceController.shared.newTaskContext())
    }
    
    static func dataRequest() -> [MSIRouter] {
        return [MSIRouter.readDFRS]
    }
    
    static func shouldSync() -> Bool {
        // sync once every week
        return UserDefaults.standard.dataSourceEnabled(DFRS.self) && (Date().timeIntervalSince1970 - (60 * 60 * 24 * 7)) > UserDefaults.standard.lastSyncTimeSeconds(DFRS.self)
    }
    
    static func newBatchInsertRequest(with propertyList: [DFRSProperties]) -> NSBatchInsertRequest {
        var index = 0
        let total = propertyList.count
        
        // Provide one dictionary at a time when the closure is called.
        let batchInsertRequest = NSBatchInsertRequest(entity: DFRS.entity(), dictionaryHandler: { dictionary in
            guard index < total else { return true }
            dictionary.addEntries(from: propertyList[index].dictionaryValue.filter({
                return $0.value != nil
            }) as [AnyHashable : Any])
            index += 1
            return false
        })
        return batchInsertRequest
    }
    
    static func importRecords(from propertiesList: [DFRSProperties], taskContext: NSManagedObjectContext) async throws -> Int {
        guard !propertiesList.isEmpty else { return 0 }
        
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importDFRS"
        
        /// - Tag: performAndWait
        return try await taskContext.perform {
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = DFRS.newBatchInsertRequest(with: propertiesList)
            batchInsertRequest.resultType = .count
            if let fetchResult = try? taskContext.execute(batchInsertRequest),
               let batchInsertResult = fetchResult as? NSBatchInsertResult {
                if let count = batchInsertResult.result as? Int, count > 0 {
                    NSLog("Inserted \(count) DFRS records")
                    return count
                } else {
                    NSLog("No new DFRS records")
                }
                return 0
            }
            throw MSIError.batchInsertError
        }
    }
}
