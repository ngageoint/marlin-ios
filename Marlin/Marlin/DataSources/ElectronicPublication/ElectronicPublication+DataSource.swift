//
//  ElectronicPublication+DataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 10/25/22.
//

import Foundation
import UIKit
import CoreData

extension ElectronicPublication: DataSource {
    static let backgroundDownloadIdentifier: String = { "\(key)Download" }()
    
    var color: UIColor {
        ElectronicPublication.color
    }
    
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter
    }
    
    static var isMappable: Bool = false
    static var dataSourceName: String = NSLocalizedString("EPUB", comment: "Electronic Publication data source display name")
    static var fullDataSourceName: String = NSLocalizedString("Electronic Publications", comment: "Electronic Publication data source full display name")
    static var key: String = "epub"
    static var imageName: String? = nil
    static var systemImageName: String? = "doc.text.fill"
    
    static var color: UIColor = UIColor(argbValue: 0xFF30B0C7)
    static var imageScale = UserDefaults.standard.imageScale(key) ?? 1.0
    
    static var defaultSort: [DataSourceSortParameter] = [DataSourceSortParameter(property:DataSourceProperty(name: "Type", key: #keyPath(ElectronicPublication.pubTypeId), type: .int), ascending: true, section: true)]
    static var defaultFilter: [DataSourceFilterParameter] = []
    
    static var properties: [DataSourceProperty] = [
        DataSourceProperty(name: "Type", key: #keyPath(ElectronicPublication.pubTypeId), type: .enumeration, enumerationValues: PublicationTypeEnum.keyValueMap),
        DataSourceProperty(name: "Display Name", key: #keyPath(ElectronicPublication.pubDownloadDisplayName), type: .string)
    ]
}

extension ElectronicPublication: BatchImportable {
    static func batchImport(value: Decodable?, initialLoad: Bool) async throws -> Int {
        guard let value = value as? [ElectronicPublicationProperties] else {
            return 0
        }
        let count = value.count
        NSLog("Received \(count) Electronic Publication records.")
        return try await Self.importRecords(from: value, taskContext: PersistenceController.current.newTaskContext())
    }
    
    static func newBatchInsertRequest(with propertyList: [ElectronicPublicationProperties]) -> NSBatchInsertRequest {
        var index = 0
        let total = propertyList.count
        
        // Provide one dictionary at a time when the closure is called.
        let batchInsertRequest = NSBatchInsertRequest(entity: ElectronicPublication.entity(), dictionaryHandler: { dictionary in
            guard index < total else { return true }
            dictionary.addEntries(from: propertyList[index].dictionaryValue.filter({
                return $0.value != nil
            }) as [AnyHashable : Any])
            index += 1
            return false
        })
        return batchInsertRequest
    }
    
    static func importRecords(from propertiesList: [ElectronicPublicationProperties], taskContext: NSManagedObjectContext) async throws -> Int {
        guard !propertiesList.isEmpty else { return 0 }
        
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importEpubs"
        
        /// - Tag: performAndWait
        let count = try await taskContext.perform {
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = ElectronicPublication.newBatchInsertRequest(with: propertiesList)
            batchInsertRequest.resultType = .count
            if let fetchResult = try? taskContext.execute(batchInsertRequest),
               let batchInsertResult = fetchResult as? NSBatchInsertResult {
                try? taskContext.save()
                if let count = batchInsertResult.result as? Int, count > 0 {
                    NSLog("Inserted \(count) EPUB records")
                    return count
                } else {
                    NSLog("No new EPUB records")
                }
                return 0
            }
            throw MSIError.batchInsertError
        }
        return count
    }
    
    static func dataRequest() -> [MSIRouter] {
        return [MSIRouter.readElectronicPublications]
    }
    
    static var seedDataFiles: [String]? = nil
    
    static var decodableRoot: Decodable.Type = [ElectronicPublicationProperties].self
    
    static func shouldSync() -> Bool {
        // sync once every week
        return UserDefaults.standard.dataSourceEnabled(ElectronicPublication.self) && (Date().timeIntervalSince1970 - (60 * 60 * 24 * 7)) > UserDefaults.standard.lastSyncTimeSeconds(ElectronicPublication.self)
    }
    
    
}
