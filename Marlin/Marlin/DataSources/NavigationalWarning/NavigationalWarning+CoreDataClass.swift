//
//  NavigationalWarning+CoreDataClass.swift
//  Marlin
//
//  Created by Daniel Barela on 6/21/22.
//

import Foundation
import CoreData
import OSLog
import MapKit
import SwiftUI

struct NavigationalWarningNavArea: Equatable {
    let name: String
    let display: String
    let color: UIColor
}

extension NavigationalWarningNavArea {
    static let HYDROPAC = NavigationalWarningNavArea(name: "P", display: "HYDROPAC", color: UIColor(argbValue: 0xFFF5F481))
    static let HYDROARC = NavigationalWarningNavArea(name: "C", display: "HYDROARC", color: UIColor(argbValue: 0xFF77DFFC))
    static let HYDROLANT = NavigationalWarningNavArea(name: "A", display: "HYDROLANT", color: UIColor(argbValue: 0xFF7C91F2))
    static let NAVAREA_IV = NavigationalWarningNavArea(name: "4", display: "NAVAREA IV", color: UIColor(argbValue: 0xFFFDBFBF))
    static let NAVAREA_XII = NavigationalWarningNavArea(name: "12", display: "NAVAREA XII", color: UIColor(argbValue: 0xFF8BCC6B))
    
    static func areas() -> [NavigationalWarningNavArea] {
        return [NavigationalWarningNavArea.HYDROPAC, NavigationalWarningNavArea.HYDROARC, NavigationalWarningNavArea.HYDROLANT, NavigationalWarningNavArea.NAVAREA_IV, NavigationalWarningNavArea.NAVAREA_XII]
    }
    
    static func fromId(id: String) -> NavigationalWarningNavArea? {
        for area in NavigationalWarningNavArea.areas() {
            if id == area.name {
                return area
            }
        }
        return nil
    }
}

extension NavigationalWarning: DataSource {
    static var isMappable: Bool = false
    static var dataSourceName: String = NSLocalizedString("Warnings", comment: "Warnings data source display name")
    static var fullDataSourceName: String = NSLocalizedString("Navigational Warnings", comment: "Warnings data source display name")
    static var key: String = "navWarning"
    static var color: UIColor = UIColor(argbValue: 0xFFD32F2F)
    static var imageName: String? = nil
    static var systemImageName: String? = "exclamationmark.triangle.fill"
    
    var color: UIColor {
        return NavigationalWarning.color
    }
}

extension NavigationalWarning: DataSourceViewBuilder {
    var detailView: AnyView {
        AnyView(NavigationalWarningDetailView(navigationalWarning: self))
    }
    
    func summaryView(showMoreDetails: Bool = false, showSectionHeader: Bool = false) -> AnyView {
        AnyView(NavigationalWarningSummaryView(navigationalWarning: self))
    }
}

class NavigationalWarning: NSManagedObject {
    
    var primaryKey: String {
        return "\(self.navArea ?? "") \(self.msgNumber)/\(self.msgYear)"
    }
    
    var dateString: String? {
        if let date = issueDate {
            return NavigationalWarningProperties.dateFormatter.string(from: date)
        }
        return nil
    }
    
    var cancelDateString: String? {
        if let date = cancelDate {
            return NavigationalWarningProperties.dateFormatter.string(from: date)
        }
        return nil
    }
    
    var navAreaName: String {
        guard let navArea = navArea else {
            return ""
        }
        
        if let navAreaEnum = NavigationalWarningNavArea.fromId(id: navArea) {
            return navAreaEnum.display
        }
        return ""
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
    
    static func batchImport(from propertiesList: [NavigationalWarningProperties], taskContext: NSManagedObjectContext) async throws {
        guard !propertiesList.isEmpty else { return }
        
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importNavigationalWarnings"
        
        /// - Tag: performAndWait
        try await taskContext.perform {
            _ = taskContext.truncateAll(NavigationalWarning.self)
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = NavigationalWarning.newBatchInsertRequest(with: propertiesList)
            if let fetchResult = try? taskContext.execute(batchInsertRequest),
               let batchInsertResult = fetchResult as? NSBatchInsertResult,
               let success = batchInsertResult.result as? Bool, success {
                return
            }
            throw MSIError.batchInsertError
        }
    }
    
    override var description: String {
        return "Navigational Warning\n\n" +
        "\(dateString ?? "")}\n\n" +
        "\(navAreaName) \(msgNumber)/\(msgYear) (\(subregion ?? ""))\n\n" +
        "\(text ?? "")\n\n" +
        "Status: \(status ?? "")\n" +
        "Authority: \(authority ?? "")\n" +
        "Cancel Date: \(cancelDateString ?? "")\n" +
        "Cancel Year: \(cancelMsgNumber)\n" +
        "Cancel Year: \(cancelMsgYear)\n"

    }
}

struct NavigationalWarningPropertyContainer: Decodable {
    private enum CodingKeys: String, CodingKey {
        case broadcastWarn = "broadcast-warn"
    }
    let broadcastWarn: [NavigationalWarningProperties]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        broadcastWarn = try container.decode([Throwable<NavigationalWarningProperties>].self, forKey: .broadcastWarn).compactMap { try? $0.result.get() }
    }
}

/// A struct encapsulating the properties of a Quake.
struct NavigationalWarningProperties: Decodable {
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter
    }()
    
    static let apiToDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddHHmm'Z' MMM yyyy"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter
    }()
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case cancelMsgNumber
        case authority
        case cancelDate
        case cancelMsgYear
        case cancelNavArea
        case issueDate
        case msgNumber
        case msgYear
        case navArea
        case status
        case subregion
        case text
    }
    
    let cancelMsgNumber: Int?
    let authority: String?
    let cancelDate: Date?
    let cancelMsgYear: Int?
    let cancelNavArea: String?
    let issueDate: Date?
    let msgNumber: Int?
    let msgYear: Int?
    let navArea: String
    let status: String?
    let subregion: String?
    let text: String?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let rawMsgYear = try? values.decode(Int.self, forKey: .msgYear)
        let rawMsgNumber = try? values.decode(Int.self, forKey: .msgNumber)
        let rawNavArea = try? values.decode(String.self, forKey: .navArea)
        
        // Ignore earthquakes with missing data.
        guard let msgYear = rawMsgYear,
              let msgNumber = rawMsgNumber,
              let navArea = rawNavArea
        else {
            let values = "msgYear = \(rawMsgYear?.description ?? "nil"), "
            + "msgNumber = \(rawMsgNumber?.description ?? "nil"), "
            + "navArea = \(rawNavArea?.description ?? "nil")"
            
            let logger = Logger(subsystem: "mil.nga.msi.Marlin", category: "parsing")
            logger.debug("Ignored: \(values)")
            
            throw MSIError.missingData
        }
        
        self.msgYear = msgYear
        self.msgNumber = msgNumber
        self.navArea = navArea
        self.cancelMsgNumber = try? values.decode(Int.self, forKey: .cancelMsgNumber)
        self.authority = try? values.decode(String.self, forKey: .authority)
        self.cancelMsgYear = try? values.decode(Int.self, forKey: .cancelMsgYear)
        self.cancelNavArea = try? values.decode(String.self, forKey: .cancelNavArea)
        self.status = try? values.decode(String.self, forKey: .status)
        self.subregion = try? values.decode(String.self, forKey: .subregion)
        self.text = try? values.decode(String.self, forKey: .text)

        var parsedCancelDate: Date? = nil
        if let cancelDateString = try? values.decode(String.self, forKey: .cancelDate) {
            if let date = NavigationalWarningProperties.apiToDateFormatter.date(from: cancelDateString) {
                parsedCancelDate = date
            }
        }
        self.cancelDate = parsedCancelDate
        
        var parsedDate: Date? = nil
        if let dateString = try? values.decode(String.self, forKey: .issueDate) {
            if let date = NavigationalWarningProperties.apiToDateFormatter.date(from: dateString) {
                parsedDate = date
            }
        }
        self.issueDate = parsedDate
    }
    
    // The keys must have the same name as the attributes of the NavigationalWarning entity.
    var dictionaryValue: [String: Any?] {
        [
            "cancelMsgNumber": cancelMsgNumber,
            "authority": authority,
            "cancelDate": cancelDate,
            "cancelMsgYear": cancelMsgYear,
            "cancelNavArea": cancelNavArea,
            "issueDate": issueDate,
            "msgNumber": msgNumber,
            "msgYear": msgYear,
            "navArea": navArea,
            "status": status,
            "subregion": subregion,
            "text": text
        ]
    }
}

