//
//  NavigationalWarning+Decodable.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import CoreLocation
import OSLog

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

struct NavigationalWarningProperties: Decodable {
    
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
