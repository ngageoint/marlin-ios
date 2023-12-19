//
//  NoticeToMariners+Decodable.swift
//  Marlin
//
//  Created by Daniel Barela on 11/14/22.
//

import Foundation
import CoreLocation
import OSLog

struct NoticeToMarinersPropertyContainer: Decodable {
    private enum CodingKeys: String, CodingKey {
        case pubs
    }
    let pubs: [NoticeToMarinersProperties]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        pubs = try container.decode([Throwable<NoticeToMarinersProperties>].self, forKey: .pubs).compactMap { try? $0.result.get() }
    }
}

struct NoticeToMarinersProperties: Decodable {
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case publicationIdentifier
        case noticeNumber
        case title
        case odsKey
        case sectionOrder
        case limitedDist
        case odsEntryId
        case odsContentId
        case internalPath
        case filenameBase
        case fileExtension
        case fileSize
        case isFullPublication
        case uploadTime
        case lastModified
    }
    
    let publicationIdentifier: Int?
    let noticeNumber: Int?
    let title: String?
    let odsKey: String?
    let sectionOrder: Int?
    let limitedDist: Bool?
    let odsEntryId: Int?
    let odsContentId: Int?
    let internalPath: String?
    let filenameBase: String?
    let fileExtension: String?
    let fileSize: Int?
    let isFullPublication: Bool?
    let uploadTime: Date?
    let lastModified: Date?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let rawOdsEntryId = try? values.decode(Int.self, forKey: .odsEntryId)
        let rawOdsKey = try? values.decode(String.self, forKey: .odsKey)
        
        guard let odsEntryId = rawOdsEntryId,
              let odsKey = rawOdsKey
        else {
            let values = "odsEntryId = \(rawOdsEntryId?.description ?? "nil"), "
            + "odsKey = \(rawOdsKey?.description ?? "nil")"
            
            let logger = Logger(subsystem: "mil.nga.msi.Marlin", category: "parsing")
            logger.info("Ignored: \(values)")
            
            throw MSIError.missingData
        }
        self.odsKey = odsKey
        self.odsEntryId = odsEntryId
        self.publicationIdentifier = try? values.decode(Int.self, forKey: .publicationIdentifier)
        self.noticeNumber = try? values.decode(Int.self, forKey: .noticeNumber)
        self.title = try? values.decode(String.self, forKey: .title)
        self.sectionOrder = try? values.decode(Int.self, forKey: .sectionOrder)
        self.limitedDist = try? values.decode(Bool.self, forKey: .limitedDist)
        self.odsContentId = try? values.decode(Int.self, forKey: .odsContentId)
        self.internalPath = try? values.decode(String.self, forKey: .internalPath)
        self.filenameBase = try? values.decode(String.self, forKey: .filenameBase)
        self.fileExtension = try? values.decode(String.self, forKey: .fileExtension)
        self.fileSize = try? values.decode(Int.self, forKey: .fileSize)
        self.isFullPublication = try? values.decode(Bool.self, forKey: .isFullPublication)
        
        var parsedUploadTime: Date?
        if let dateString = try? values.decode(String.self, forKey: .uploadTime) {
            if let date = NoticeToMariners.dateFormatter.date(from: dateString) {
                parsedUploadTime = date
            }
        }
        self.uploadTime = parsedUploadTime
        
        var parsedLastModified: Date?
        if let dateString = try? values.decode(String.self, forKey: .lastModified) {
            if let date = NoticeToMariners.dateFormatter.date(from: dateString) {
                parsedLastModified = date
            }
        }
        self.lastModified = parsedLastModified
    }
    
    // The keys must have the same name as the attributes of the NoticeToMariners entity.
    var dictionaryValue: [String: Any?] {
        [
            "publicationIdentifier": publicationIdentifier,
            "noticeNumber": noticeNumber,
            "title": title,
            "odsKey": odsKey,
            "sectionOrder": sectionOrder,
            "limitedDist": limitedDist,
            "odsEntryId": odsEntryId,
            "odsContentId": odsContentId,
            "internalPath": internalPath,
            "filenameBase": filenameBase,
            "fileExtension": fileExtension,
            "fileSize": fileSize,
            "isFullPublication": isFullPublication,
            "uploadTime": uploadTime,
            "lastModified": lastModified
        ]
    }
}
