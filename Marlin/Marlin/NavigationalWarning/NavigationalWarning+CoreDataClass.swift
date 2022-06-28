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

enum NavigationalWarningNavArea: String, CaseIterable, CustomStringConvertible {
    case HYDROPAC = "P"
    case HYDROLANT = "A"
    case HYDROARC = "C"
    case NAVAREA_IV = "4"
    case NAVAREA_XII = "12"
    
    var description : String {
        switch self {
        case .HYDROPAC: return "HYDROPAC"
        case .HYDROLANT: return "HYDROLANT"
        case .HYDROARC: return "HYDROARC"
        case .NAVAREA_IV: return "NAVAREA IV"
        case .NAVAREA_XII: return "NAVAREA XII"
        }
    }
    
    static func fromDisplay(_ display: String) -> NavigationalWarningNavArea? {
        return self.allCases.first{ "\($0)" == display.replacingOccurrences(of: " ", with: "_") }
    }
}

class NavigationalWarning: NSManagedObject {
    
    var primaryKey: String {
        return "\(self.navArea ?? "") \(self.msgNumber)/\(self.msgYear)"
    }
    
    var color: UIColor {
        return UIColor(red: 0.00, green: 0.29, blue: 0.68, alpha: 1.00)
    }
    
    var dateString: String? {
        if let date = issueDate {
            return NavigationalWarningProperties.dateFormatter.string(from: date)
        }
        return nil
    }
    
    var navAreaName: String {
        guard let navArea = navArea else {
            return ""
        }
        
        if let navAreaEnum = NavigationalWarningNavArea(rawValue: navArea) {
            return navAreaEnum.description
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
        return batchInsertRequest
    }
    
    static func batchImport(from propertiesList: [NavigationalWarningProperties], taskContext: NSManagedObjectContext, viewContext: NSManagedObjectContext) async throws {
        guard !propertiesList.isEmpty else { return }
        
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importNavigationalWarnings"
        
        /// - Tag: performAndWait
        try await taskContext.perform {
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = NavigationalWarning.newBatchInsertRequest(with: propertiesList)
            if let fetchResult = try? taskContext.execute(batchInsertRequest),
               let batchInsertResult = fetchResult as? NSBatchInsertResult,
               let success = batchInsertResult.result as? Bool, success {
                return
            }
            //            self.logger.debug("Failed to execute batch insert request.")
            throw MSIError.batchInsertError
        }
        
        //        logger.debug("Successfully inserted data.")
    }
}

struct NavigationalWarningPropertyContainer: Decodable {
    let broadcastWarn: [NavigationalWarningProperties]
    
    private enum CodingKeys: String, CodingKey {
        case broadcastWarn = "broadcast-warn"
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
    let cancelDate: String?
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
        self.cancelDate = try? values.decode(String.self, forKey: .cancelDate)
        self.cancelMsgYear = try? values.decode(Int.self, forKey: .cancelMsgYear)
        self.cancelNavArea = try? values.decode(String.self, forKey: .cancelNavArea)
        self.status = try? values.decode(String.self, forKey: .status)
        self.subregion = try? values.decode(String.self, forKey: .subregion)
        self.text = try? values.decode(String.self, forKey: .text)
        
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

