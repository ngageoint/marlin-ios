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
}

extension Modu: BatchImportable {
    static var seedDataFiles: [String]? = ["modu"]
    static var decodableRoot: Decodable.Type = ModuPropertyContainer.self
    
    static func batchImport(value: Decodable?) async throws {
        guard let value = value as? ModuPropertyContainer else {
            return
        }
        let count = value.modu.count
        NSLog("Received \(count) \(Self.key) records.")
        try await Modu.batchImport(from: value.modu, taskContext: PersistenceController.shared.newTaskContext())
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
    
    static func batchImport(from propertiesList: [ModuProperties], taskContext: NSManagedObjectContext) async throws {
        guard !propertiesList.isEmpty else { return }
        
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importModus"
        
        /// - Tag: performAndWait
        try await taskContext.perform {
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = Modu.newBatchInsertRequest(with: propertiesList)
            batchInsertRequest.resultType = .count
            if let fetchResult = try? taskContext.execute(batchInsertRequest),
               let batchInsertResult = fetchResult as? NSBatchInsertResult {
                if let count = batchInsertResult.result as? Int, count > 0 {
                    NSLog("Inserted \(count) MODU records")
                    NotificationCenter.default.post(name: .DataSourceUpdated, object: DataSourceItem(dataSource: Modu.self))
                } else {
                    NSLog("No new MODU records")
                }
                return
            }
            throw MSIError.batchInsertError
        }
    }
}
