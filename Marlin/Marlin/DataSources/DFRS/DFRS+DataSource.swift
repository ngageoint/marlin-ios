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
}

extension DFRS: BatchImportable {
    static var seedDataFiles: [String]? = ["dfrs"]
    static var decodableRoot: Decodable.Type = DFRSPropertyContainer.self
    
    static func batchImport(value: Decodable?) async throws {
        guard let value = value as? DFRSPropertyContainer else {
            return
        }
        let count = value.dfrs.count
        NSLog("Received \(count) \(Self.key) records.")
        try await Self.batchImport(from: value.dfrs, taskContext: PersistenceController.shared.newTaskContext())
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
    
    static func batchImport(from propertiesList: [DFRSProperties], taskContext: NSManagedObjectContext) async throws {
        guard !propertiesList.isEmpty else { return }
        
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importDFRS"
        
        /// - Tag: performAndWait
        try await taskContext.perform {
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = DFRS.newBatchInsertRequest(with: propertiesList)
            batchInsertRequest.resultType = .count
            if let fetchResult = try? taskContext.execute(batchInsertRequest),
               let batchInsertResult = fetchResult as? NSBatchInsertResult {
                if let count = batchInsertResult.result as? Int, count > 0 {
                    NSLog("Inserted \(count) DFRS records")
                    NotificationCenter.default.post(name: .DataSourceUpdated, object: DataSourceItem(dataSource: DFRS.self))
                } else {
                    NSLog("No new DFRS records")
                }
                return
            }
            throw MSIError.batchInsertError
        }
    }
}
