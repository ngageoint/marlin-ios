//
//  ElectronicPublication+DataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 10/25/22.
//

import Foundation
import UIKit
import CoreData

// extension ElectronicPublication: Bookmarkable {
//    var canBookmark: Bool {
//        return true
//    }
//    
//    var itemKey: String {
//        return s3Key ?? ""
//    }
//    
//    static func getItem(context: NSManagedObjectContext, itemKey: String?) -> Bookmarkable? {
//        return getElectronicPublication(context: context, s3Key: itemKey)
//    }
//    
//    static func getElectronicPublication(context: NSManagedObjectContext, s3Key: String?) -> ElectronicPublication? {
//        if let s3Key = s3Key {
//            return context.fetchFirst(ElectronicPublication.self, key: "s3Key", value: s3Key)
//        }
//        return nil
//    }
// }

// extension ElectronicPublication: DataSource {
//    static var definition: any DataSourceDefinition = DataSourceDefinitions.epub.definition
//    static let backgroundDownloadIdentifier: String = { "\(key)Download" }()
//    
//    var color: UIColor {
//        ElectronicPublication.color
//    }
//    
//    static var dateFormatter: DateFormatter {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
//        return dateFormatter
//    }
//    
//    static var isMappable: Bool = false
//    static var dataSourceName: String = 
//    NSLocalizedString("EPUB",
//                      comment: "Electronic Publication data source display name")
//    static var fullDataSourceName: String = 
//    NSLocalizedString("Electronic Publications",
//                      comment: "Electronic Publication data source full display name")
//    static var key: String = "epub"
//    static var metricsKey: String = "epubs"
//    static var imageName: String?
//    static var systemImageName: String? = "doc.text.fill"
//    
//    static var color: UIColor = UIColor(argbValue: 0xFF30B0C7)
//    static var imageScale = UserDefaults.standard.imageScale(key) ?? 1.0
//    
//    static var defaultSort: [DataSourceSortParameter] = [
//        DataSourceSortParameter(
//            property: DataSourceProperty(
//                name: "Type",
//                key: #keyPath(ElectronicPublication.pubTypeId),
//                type: .int),
//            ascending: true,
//            section: true)
//    ]
//    static var defaultFilter: [DataSourceFilterParameter] = []
//    
//    static var properties: [DataSourceProperty] = [
//        DataSourceProperty(
//            name: "Type",
//            key: #keyPath(ElectronicPublication.pubTypeId),
//            type: .enumeration,
//            enumerationValues: PublicationTypeEnum.keyValueMap),
//        DataSourceProperty(
//            name: "Display Name",
//            key: #keyPath(ElectronicPublication.pubDownloadDisplayName),
//            type: .string)
//    ]
//    
//    static func postProcess() {}
// }
//
// extension ElectronicPublication: BatchImportable {
//    static func batchImport(value: Decodable?, initialLoad: Bool) async throws -> Int {
//        guard let value = value as? ElectronicPublicationPropertyContainer else {
//            return 0
//        }
//        let count = value.publications.count
//        NSLog("Received \(count) Electronic Publication records.")
//        return try await Self.importRecords(
//            from: value.publications,
//            taskContext: PersistenceController.current.newTaskContext())
//    }
//    
//    static func newBatchInsertRequest(with propertyList: [ElectronicPublicationModel]) -> NSBatchInsertRequest {
//        var index = 0
//        let total = propertyList.count
//        // Provide one dictionary at a time when the closure is called.
//        let batchInsertRequest = 
//        NSBatchInsertRequest(
//            entity: ElectronicPublication.entity(),
//            dictionaryHandler: { dictionary in
//            guard index < total else { return true }
//            let propertyDictionary = propertyList[index].dictionaryValue
//            dictionary.addEntries(from: propertyDictionary.mapValues({ value in
//                if let value = value {
//                    return value
//                }
//                return NSNull()
//            }) as [AnyHashable: Any])
//            
//            index += 1
//            return false
//        })
//        return batchInsertRequest
//    }
//    
//    static func importRecords(
//        from propertiesList: [ElectronicPublicationModel],
//        taskContext: NSManagedObjectContext) async throws -> Int {
//        guard !propertiesList.isEmpty else { return 0 }
//        
//        // Add name and author to identify source of persistent history changes.
//        taskContext.name = "importContext"
//        taskContext.transactionAuthor = "importEpubs"
//        
//        /// - Tag: performAndWait
//        let count = try await taskContext.perform {
//            // Execute the batch insert.
//            /// - Tag: batchInsertRequest
//            let batchInsertRequest = ElectronicPublication.newBatchInsertRequest(with: propertiesList)
//            batchInsertRequest.resultType = .objectIDs
//            if let fetchResult = try? taskContext.execute(batchInsertRequest),
//               let batchInsertResult = fetchResult as? NSBatchInsertResult {
//                if let objectIds = batchInsertResult.result as? [NSManagedObjectID] {
//                    if objectIds.count > 0 {
//                        NSLog("Inserted \(objectIds.count) EPUB records")
//                        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ElectronicPublication")
//                        fetch.predicate = NSPredicate(format: "NOT (self IN %@)", objectIds)
//                        let request = NSBatchDeleteRequest(fetchRequest: fetch)
//                        request.resultType = .resultTypeCount
//                        if let deleteResult = try? taskContext.execute(request),
//                           let batchDeleteResult = deleteResult as? NSBatchDeleteResult {
//                            if let count = batchDeleteResult.result as? Int {
//                                NSLog("Deleted \(count) old records")
//                            }
//                        }
//                        try? taskContext.save()
//                        return objectIds.count
//                    } else {
//                        NSLog("No new EPUB records")
//                    }
//                }
//                try? taskContext.save()
//                return 0
//            }
//            throw MSIError.batchInsertError
//        }
//        return count
//    }
//    
//    static func dataRequest() -> [MSIRouter] {
//        return [MSIRouter.readElectronicPublications]
//    }
//    
//    static var seedDataFiles: [String]? = ["epub"]
//    
//    static var decodableRoot: Decodable.Type = ElectronicPublicationPropertyContainer.self
//    
//    static func shouldSync() -> Bool {
//        // sync once every day
//        return UserDefaults.standard
//            .dataSourceEnabled(ElectronicPublication.definition)
//        && (Date().timeIntervalSince1970 - (60 * 60 * 24 * 1)) >
//        UserDefaults.standard.lastSyncTimeSeconds(ElectronicPublication.definition)
//    }
// }
