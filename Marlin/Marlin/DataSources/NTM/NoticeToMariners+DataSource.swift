//
//  NoticeToMariners+DataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 11/13/22.
//

import Foundation
import UIKit
import CoreData
import Combine
import CoreLocation

// extension NoticeToMariners: DataSource {
//    static var definition: any DataSourceDefinition = DataSourceDefinitions.noticeToMariners.definition
//    static var properties: [DataSourceProperty] {
//        return []
//    }
//    
//    static var defaultSort: [DataSourceSortParameter] = [
//        DataSourceSortParameter(
//            property: DataSourceProperty(
//                name: "Notice Number", 
//                key: #keyPath(NoticeToMariners.noticeNumber),
//                type: .int),
//            ascending: false,
//            section: true),
//        DataSourceSortParameter(
//            property: DataSourceProperty(
//                name: "Full Publication",
//                key: #keyPath(NoticeToMariners.isFullPublication),
//                type: .int),
//            ascending: false,
//            section: false),
//        DataSourceSortParameter(
//            property: DataSourceProperty(
//                name: "Section Order",
//                key: #keyPath(NoticeToMariners.sectionOrder),
//                type: .int),
//            ascending: true,
//            section: false)]
//    static var defaultFilter: [DataSourceFilterParameter] = []
//    static var isMappable: Bool = false
//    static var dataSourceName: String = "NTM"
//    static var fullDataSourceName: String = "Notice To Mariners"
//    static var key: String = "ntm"
//    static var metricsKey: String = "ntms"
//    static var color: UIColor = UIColor.red
//    static var imageName: String?
//    static var systemImageName: String? = "speaker.badge.exclamationmark.fill"
//    
//    var color: UIColor {
//        NoticeToMariners.color
//    }
//    
//    static var imageScale: CGFloat = 1.0
//    
//    static var dateFormatter: DateFormatter {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
//        return dateFormatter
//    }
//    static func postProcess() {}
//    var coordinate: CLLocationCoordinate2D? {
//        return nil
//    }
// }
//
// extension NoticeToMariners: Bookmarkable {
//    var canBookmark: Bool {
//        return true
//    }
//    
//    var itemKey: String {
//        return "\(noticeNumber)"
//    }
//    
//    static func getItem(context: NSManagedObjectContext, itemKey: String?) -> Bookmarkable? {
//        if let itemKey = itemKey, let noticeNumber = Int64(itemKey) {
//            return getNoticeToMariner(context: context, noticeNumber: noticeNumber)
//        }
//        return nil
//    }
//    
//    static func getNoticeToMariner(context: NSManagedObjectContext, noticeNumber: Int64) -> NoticeToMariners? {
//        return context.fetchFirst(NoticeToMariners.self, key: "noticeNumber", value: noticeNumber)
//    }
// }
//
// extension NoticeToMariners: BatchImportable {
//    static var seedDataFiles: [String]? = ["ntm"]
//    static var decodableRoot: Decodable.Type = NoticeToMarinersPropertyContainer.self
//    
//    static func batchImport(value: Decodable?, initialLoad: Bool) async throws -> Int {
//        guard let value = value as? NoticeToMarinersPropertyContainer else {
//            return 0
//        }
//        let count = value.pubs.count
//        NSLog("Received \(count) \(Self.key) records.")
//        
//        return try await Self.importRecords(
//            from: value.pubs,
//            taskContext: PersistenceController.current.newTaskContext())
//    }
//    
//    static func dataRequest() -> [MSIRouter] {
//        let context = PersistenceController.current.newTaskContext()
//        var noticeNumber: Int64?
//        context.performAndWait {
//            let newestNotice = try? PersistenceController.current.fetchFirst(
//                NoticeToMariners.self,
//                sortBy: [
//                    NSSortDescriptor(keyPath: \NoticeToMariners.noticeNumber, ascending: false)
//                ],
//                predicate: nil,
//                context: context)
//            noticeNumber = newestNotice?.noticeNumber
//        }
//        return [MSIRouter.readNoticeToMariners(noticeNumber: noticeNumber)]
//    }
//    
//    static func shouldSync() -> Bool {
//        // sync once every day
//        return UserDefaults.standard.dataSourceEnabled(NoticeToMariners.definition)
//        && (Date().timeIntervalSince1970 - (60 * 60 * 24)) >
//        UserDefaults.standard.lastSyncTimeSeconds(NoticeToMariners.definition)
//    }
//    
//    static func newBatchInsertRequest(with propertyList: [NoticeToMarinersModel]) -> NSBatchInsertRequest {
//        var index = 0
//        let total = propertyList.count
//        
//        // Provide one dictionary at a time when the closure is called.
//        let batchInsertRequest = NSBatchInsertRequest(
//            entity: NoticeToMariners.entity(),
//            dictionaryHandler: { dictionary in
//            guard index < total else { return true }
//            let propertyDictionary = propertyList[index].dictionaryValue
//            dictionary.addEntries(from: propertyDictionary.mapValues({ value in
//                if let value = value {
//                    return value
//                }
//                return NSNull()
//            }) as [AnyHashable: Any])
//            index += 1
//            return false
//        })
//        return batchInsertRequest
//    }
//    
//    static func importRecords(
//        from propertiesList: [NoticeToMarinersModel],
//        taskContext: NSManagedObjectContext) async throws -> Int {
//        guard !propertiesList.isEmpty else { return 0 }
//        
//        // Add name and author to identify source of persistent history changes.
//        taskContext.name = "importContext"
//        taskContext.transactionAuthor = "importNoticeToMariners"
//        
//        /// - Tag: performAndWait
//        let count = try await taskContext.perform {
//            // Execute the batch insert.
//            /// - Tag: batchInsertRequest
//            let batchInsertRequest = NoticeToMariners.newBatchInsertRequest(with: propertiesList)
//            batchInsertRequest.resultType = .count
//            do {
//                 let fetchResult = try taskContext.execute(batchInsertRequest)
//                   if let batchInsertResult = fetchResult as? NSBatchInsertResult {
//                    do {
//                        try taskContext.save()
//                    } catch {
//                        NSLog("Error is \(error)")
//                    }
//                    if let count = batchInsertResult.result as? Int, count > 0 {
//                        NSLog("Inserted \(count) NoticeToMariners records")
//                        return count
//                    } else {
//                        NSLog("No new NoticeToMariners records")
//                    }
//                    return 0
//                }
//            } catch {
//                NSLog("error here is \(error)")
//            }
//            throw MSIError.batchInsertError
//        }
//        return count
//    }
// }
