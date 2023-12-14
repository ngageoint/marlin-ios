//
//  DFRSArea+CoreDataClass.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import CoreData

extension DFRSArea: BatchImportable {
    static var definition: any DataSourceDefinition = DataSources.dfrs
    static var seedDataFiles: [String]? = ["dfrsAreas"]
    static var key: String = "dfrsAreas"
    static var decodableRoot: Decodable.Type = DFRSAreaPropertyContainer.self
    
    static func batchImport(value: Decodable?, initialLoad: Bool) async throws -> Int {
        guard let value = value as? DFRSAreaPropertyContainer else {
            return 0
        }
        let count = value.areas.count
        NSLog("Received \(count) DFRS Area records.")
        return try await Self.batchImport(from: value.areas, taskContext: PersistenceController.current.newTaskContext())
    }
    
    static func dataRequest() -> [MSIRouter] {
        return [MSIRouter.readDFRSAreas]
    }
    
    static func shouldSync() -> Bool {
        // sync once every week
        return UserDefaults.standard.bool(forKey: "\(DFRSArea.key)DataSourceEnabled") && (Date().timeIntervalSince1970 - (60 * 60 * 24 * 7)) > UserDefaults.standard.double(forKey: "\(DFRSArea.key)LastSyncTime")
    }
    
    static func postProcess() {
    }
}

class DFRSArea: NSManagedObject {
    static func newBatchInsertRequest(with propertyList: [DFRSAreaProperties]) -> NSBatchInsertRequest {
        var index = 0
        let total = propertyList.count
        
        // Provide one dictionary at a time when the closure is called.
        let batchInsertRequest = NSBatchInsertRequest(entity: DFRSArea.entity(), dictionaryHandler: { dictionary in
            guard index < total else { return true }
            dictionary.addEntries(from: propertyList[index].dictionaryValue.filter({
                return $0.value != nil
            }) as [AnyHashable : Any])
            index += 1
            return false
        })
        return batchInsertRequest
    }
    
    static func batchImport(from propertiesList: [DFRSAreaProperties], taskContext: NSManagedObjectContext) async throws -> Int {
        guard !propertiesList.isEmpty else { return 0 }
        
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importDFRSArea"
        
        /// - Tag: performAndWait
        return try await taskContext.perform {
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = DFRSArea.newBatchInsertRequest(with: propertiesList)
            batchInsertRequest.resultType = .count
            if let fetchResult = try? taskContext.execute(batchInsertRequest),
               let batchInsertResult = fetchResult as? NSBatchInsertResult,
               let success = batchInsertResult.result as? Int {
                try? taskContext.save()
                return success
            }
            throw MSIError.batchInsertError
        }
    }
}
