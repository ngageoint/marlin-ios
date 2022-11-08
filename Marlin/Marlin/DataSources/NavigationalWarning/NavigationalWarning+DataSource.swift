//
//  NavigationalWarning+DataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import UIKit
import CoreData

extension NavigationalWarning: DataSource {
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter
    }
    
    static var isMappable: Bool = false
    static var dataSourceName: String = NSLocalizedString("Warnings", comment: "Warnings data source display name")
    static var fullDataSourceName: String = NSLocalizedString("Navigational Warnings", comment: "Warnings data source display name")
    static var key: String = "navWarning"
    static var color: UIColor = UIColor(argbValue: 0xFFD32F2F)
    static var imageName: String? = nil
    static var systemImageName: String? = "exclamationmark.triangle.fill"
    static var imageScale: CGFloat = 0.66

    var color: UIColor {
        return NavigationalWarning.color
    }
    
    static var defaultSort: [DataSourceSortParameter] = [DataSourceSortParameter(property:DataSourceProperty(name: "Navigational Area", key: "navArea", type: .string), ascending: false), DataSourceSortParameter(property:DataSourceProperty(name: "Issue Date", key: "issueDate", type: .date), ascending: false)]
    
    static var defaultFilter: [DataSourceFilterParameter] = []
    
    static var properties: [DataSourceProperty] = []
}

extension NavigationalWarning: BatchImportable {
    
    static var seedDataFiles: [String]? = nil
    static var decodableRoot: Decodable.Type = NavigationalWarningPropertyContainer.self
    
    static func batchImport(value: Decodable?, initialLoad: Bool) async throws -> Int {
        guard let value = value as? NavigationalWarningPropertyContainer else {
            return 0
        }
        let count = value.broadcastWarn.count
        NSLog("Received \(count) \(Self.key) records.")
        return try await Self.importRecords(from: value.broadcastWarn, taskContext: PersistenceController.current.newTaskContext())
    }
    
    static func dataRequest() -> [MSIRouter] {
        return [MSIRouter.readNavigationalWarnings]
    }
    
    static func shouldSync() -> Bool {
        // sync once every hour
        return UserDefaults.standard.dataSourceEnabled(NavigationalWarning.self) && (Date().timeIntervalSince1970 - (60 * 60)) > UserDefaults.standard.lastSyncTimeSeconds(NavigationalWarning.self)
    }
    
    static func newBatchInsertRequest(with propertyList: [NavigationalWarningProperties]) -> NSBatchInsertRequest {
        var index = 0
        let total = propertyList.count
        
        // Provide one dictionary at a time when the closure is called.
        let batchInsertRequest = NSBatchInsertRequest(entity: NavigationalWarning.entity(), dictionaryHandler: { dictionary in
            guard index < total else { return true }
            dictionary.addEntries(from: propertyList[index].dictionaryValue.filter({
                return $0.value != nil
            }) as [AnyHashable : Any])
            index += 1
            return false
        })
        batchInsertRequest.resultType = .statusOnly
        return batchInsertRequest
    }
    
    static func importRecords(from propertiesList: [NavigationalWarningProperties], taskContext: NSManagedObjectContext) async throws -> Int {
        guard !propertiesList.isEmpty else { return 0 }
        
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importNavigationalWarnings"
        
        /// - Tag: performAndWait
        return try await taskContext.perform {
            _ = taskContext.truncateAll(NavigationalWarning.self)
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = NavigationalWarning.newBatchInsertRequest(with: propertiesList)
            batchInsertRequest.resultType = .count
            if let fetchResult = try? taskContext.execute(batchInsertRequest),
               let batchInsertResult = fetchResult as? NSBatchInsertResult {
                try? taskContext.save()
                if let count = batchInsertResult.result as? Int, count > 0 {
                    NSLog("Inserted \(count) NavigationalWarning records")
                    return count
                } else {
                    NSLog("No new NavigationalWarning records")
                }
                return 0
            }
            throw MSIError.batchInsertError
        }
    }
}
