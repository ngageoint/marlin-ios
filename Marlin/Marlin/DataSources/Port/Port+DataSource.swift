//
//  Port+DataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import UIKit
import CoreData

extension Port: DataSource {
    var color: UIColor {
        return Port.color
    }
    
    static var isMappable: Bool = true
    static var dataSourceName: String = NSLocalizedString("Ports", comment: "Port data source display name")
    static var fullDataSourceName: String = NSLocalizedString("World Ports", comment: "Port data source display name")
    static var key: String = "port"
    static var imageName: String? = "port"
    static var systemImageName: String? = nil
    static var color: UIColor = UIColor(argbValue: 0xFF5856d6)
    static var imageScale = UserDefaults.standard.imageScale(key) ?? 1.0
}

extension Port: BatchImportable {
    static var seedDataFiles: [String]? = ["port"]
    static var decodableRoot: Decodable.Type = PortPropertyContainer.self
    
    static func batchImport(value: Decodable?) async throws {
        guard let value = value as? PortPropertyContainer else {
            return
        }
        let count = value.ports.count
        NSLog("Received \(count) \(Self.key) records.")
        try await Port.batchImport(from: value.ports, taskContext: PersistenceController.shared.newTaskContext())
    }
    
    static func dataRequest() -> [MSIRouter] {
        return [MSIRouter.readPorts]
    }
    
    static func shouldSync() -> Bool {
        // sync once every week
        return UserDefaults.standard.dataSourceEnabled(Port.self) && (Date().timeIntervalSince1970 - (60 * 60 * 24 * 7)) > UserDefaults.standard.lastSyncTimeSeconds(Port.self)
    }
    
    static func newBatchInsertRequest(with propertyList: [PortProperties]) -> NSBatchInsertRequest {
        var index = 0
        let total = propertyList.count
        
        // Provide one dictionary at a time when the closure is called.
        let batchInsertRequest = NSBatchInsertRequest(entity: Port.entity(), dictionaryHandler: { dictionary in
            guard index < total else { return true }
            dictionary.addEntries(from: propertyList[index].dictionaryValue.filter({
                return $0.value != nil
            }) as [AnyHashable : Any])
            index += 1
            return false
        })
        return batchInsertRequest
    }
    
    static func batchImport(from propertiesList: [PortProperties], taskContext: NSManagedObjectContext) async throws {
        guard !propertiesList.isEmpty else { return }
        
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importPorts"
        
        try await taskContext.perform {
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = Port.newBatchInsertRequest(with: propertiesList)
            batchInsertRequest.resultType = .count
            if let fetchResult = try? taskContext.execute(batchInsertRequest),
               let batchInsertResult = fetchResult as? NSBatchInsertResult {
                if let count = batchInsertResult.result as? Int, count > 0 {
                    NSLog("Inserted \(count) Port records")
                    NotificationCenter.default.post(name: .DataSourceUpdated, object: DataSourceItem(dataSource: Port.self))
                } else {
                    NSLog("No new Port records")
                }
                return
            }
            throw MSIError.batchInsertError
        }
    }
}
