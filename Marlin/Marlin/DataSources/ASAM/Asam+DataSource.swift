//
//  Asam+DataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import UIKit
import CoreData

extension Asam: DataSource {
    static var isMappable: Bool = true
    static var dataSourceName: String = NSLocalizedString("ASAM", comment: "ASAM data source display name")
    static var fullDataSourceName: String = NSLocalizedString("Anti-Shipping Activity Messages", comment: "ASAM data source display name")
    static var key: String = "asam"
    static var imageName: String? = "asam"
    static var systemImageName: String? = nil
    
    static var color: UIColor = .black
    static var imageScale = UserDefaults.standard.imageScale(key) ?? 1.0
}

extension Asam: BatchImportable {
    static var seedDataFiles: [String]? = ["asam"]
    static var decodableRoot: Decodable.Type = AsamPropertyContainer.self
    
    static func batchImport(value: Decodable?) async throws {
        guard let value = value as? AsamPropertyContainer else {
            return
        }
        let count = value.asam.count
        NSLog("Received \(count) \(Self.key) records.")
        try await Self.importRecords(from: value.asam, taskContext: PersistenceController.shared.newTaskContext())
    }
    
    static func dataRequest() -> [MSIRouter] {
        let newestAsam = try? PersistenceController.shared.container.viewContext.fetchFirst(Asam.self, sortBy: [NSSortDescriptor(keyPath: \Asam.date, ascending: false)])
        return [MSIRouter.readAsams(date: newestAsam?.dateString)]
    }
    
    static func shouldSync() -> Bool {
        // sync once every hour
        return UserDefaults.standard.dataSourceEnabled(Asam.self) && (Date().timeIntervalSince1970 - (60 * 60)) > UserDefaults.standard.lastSyncTimeSeconds(Asam.self)
    }
    
    static func newBatchInsertRequest(with propertyList: [AsamProperties]) -> NSBatchInsertRequest {
        var index = 0
        let total = propertyList.count
        
        // Provide one dictionary at a time when the closure is called.
        let batchInsertRequest = NSBatchInsertRequest(entity: Asam.entity(), dictionaryHandler: { dictionary in
            guard index < total else { return true }
            dictionary.addEntries(from: propertyList[index].dictionaryValue.filter({
                return $0.value != nil
            }) as [AnyHashable : Any])
            index += 1
            return false
        })
        return batchInsertRequest
    }
    
    static func importRecords(from propertiesList: [AsamProperties], taskContext: NSManagedObjectContext) async throws {
        guard !propertiesList.isEmpty else { return }
        
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importAsams"
        
        /// - Tag: performAndWait
        try await taskContext.perform {
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = Asam.newBatchInsertRequest(with: propertiesList)
            batchInsertRequest.resultType = .count
            if let fetchResult = try? taskContext.execute(batchInsertRequest),
               let batchInsertResult = fetchResult as? NSBatchInsertResult {
                if let count = batchInsertResult.result as? Int, count > 0 {
                    NSLog("Inserted \(count) ASAM records")
                    NotificationCenter.default.post(name: .DataSourceUpdated, object: DataSourceItem(dataSource: Asam.self))
                } else {
                    NSLog("No new ASAM records")
                }
                return
            }
            throw MSIError.batchInsertError
        }
    }
}
