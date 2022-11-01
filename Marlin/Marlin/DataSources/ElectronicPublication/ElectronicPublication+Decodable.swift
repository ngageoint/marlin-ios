//
//  ElectronicPublication+Decodable.swift
//  Marlin
//
//  Created by Daniel Barela on 10/25/22.
//

import Foundation

struct ElectronicPublicationPropertyContainer: Decodable {
    private enum CodingKeys: String, CodingKey {
        case publications
    }
    let publications: [ElectronicPublicationProperties]
    
    init(from decoder: Decoder) throws {        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        publications = try container.decode([Throwable<ElectronicPublicationProperties>].self, forKey: .publications).compactMap { try? $0.result.get()}
    }
}

struct ElectronicPublicationProperties: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case contentId
        case fileExtension
        case filenameBase
        case fileSize
        case fullFilename
        case fullPubFlag
        case internalPath
        case odsEntryId
        case pubDownloadDisplayName
        case pubDownloadId
        case pubDownloadOrder
        case pubsecId
        case pubsecLastModified
        case pubTypeId
        case s3Key
        case sectionDisplayName
        case sectionLastModified
        case sectionName
        case sectionOrder
        case uploadTime
    }
    
    let contentId: Int?
    let fileExtension: String?
    let filenameBase: String?
    let fileSize: Int?
    let fullFilename: String?
    let fullPubFlag: Bool?
    let internalPath: String?
    let odsEntryId: Int?
    let pubDownloadDisplayName: String?
    let pubDownloadId: Int?
    let pubDownloadOrder: Int?
    let pubsecId: Int?
    let pubsecLastModified: Date?
    let pubTypeId: Int?
    let s3Key: String?
    let sectionDisplayName: String?
    let sectionLastModified: Date?
    let sectionName: String?
    let sectionOrder: Int?
    let uploadTime: Date?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let rawS3Key = try? values.decode(String.self, forKey: .s3Key)
        
        guard let s3Key = rawS3Key else {
            throw MSIError.missingData
        }
        self.s3Key = s3Key
        
        self.contentId = try? values.decode(Int.self, forKey: .contentId)
        self.fileExtension = try? values.decode(String.self, forKey: .fileExtension)
        self.filenameBase = try? values.decode(String.self, forKey: .filenameBase)
        self.fileSize = try? values.decode(Int.self, forKey: .fileSize)
        self.fullFilename = try? values.decode(String.self, forKey: .fullFilename)
        self.fullPubFlag = try? values.decode(Bool.self, forKey: .fullPubFlag)
        self.internalPath = try? values.decode(String.self, forKey: .internalPath)
        self.odsEntryId = try? values.decode(Int.self, forKey: .odsEntryId)
        self.pubDownloadDisplayName = try? values.decode(String.self, forKey: .pubDownloadDisplayName)
        self.pubDownloadId = try? values.decode(Int.self, forKey: .pubDownloadId)
        self.pubDownloadOrder = try? values.decode(Int.self, forKey: .pubDownloadOrder)
        self.pubsecId = try? values.decode(Int.self, forKey: .pubsecId)
        self.pubTypeId = try? values.decode(Int.self, forKey: .pubTypeId)
        self.sectionDisplayName = try? values.decode(String.self, forKey: .sectionDisplayName)
        self.sectionName = try? values.decode(String.self, forKey: .sectionName)
        self.sectionOrder = try? values.decode(Int.self, forKey: .sectionOrder)
        
        var parsedPubsecLastModifiedDate: Date? = nil
        if let dateString = try? values.decode(String.self, forKey: .pubsecLastModified) {
            if let date = ElectronicPublication.dateFormatter.date(from: dateString) {
                parsedPubsecLastModifiedDate = date
            }
        }
        self.pubsecLastModified = parsedPubsecLastModifiedDate
        
        var parsedSectionLastModifiedDate: Date? = nil
        if let dateString = try? values.decode(String.self, forKey: .sectionLastModified) {
            if let date = ElectronicPublication.dateFormatter.date(from: dateString) {
                parsedSectionLastModifiedDate = date
            }
        }
        self.sectionLastModified = parsedSectionLastModifiedDate
        
        var parsedUploadTime: Date? = nil
        if let dateString = try? values.decode(String.self, forKey: .uploadTime) {
            if let date = ElectronicPublication.dateFormatter.date(from: dateString) {
                parsedUploadTime = date
            }
        }
        self.uploadTime = parsedUploadTime
    }
    
    // The keys must have the same name as the attributes of the Asam entity.
    var dictionaryValue: [String: Any?] {
        [
            "contentId": contentId,
            "fileExtension": fileExtension,
            "filenameBase": filenameBase,
            "fileSize": fileSize,
            "fullFilename": fullFilename,
            "fullPubFlag": fullPubFlag,
            "internalPath": internalPath,
            "odsEntryId": odsEntryId,
            "pubDownloadDisplayName": pubDownloadDisplayName,
            "pubDownloadId": pubDownloadId,
            "pubDownloadOrder": pubDownloadOrder,
            "pubsecId": pubsecId,
            "pubsecLastModified": pubsecLastModified,
            "pubTypeId": pubTypeId,
            "s3Key": s3Key,
            "sectionDisplayName": sectionDisplayName,
            "sectionLastModified": sectionLastModified,
            "sectionName": sectionName,
            "sectionOrder": sectionOrder,
            "uploadTime": uploadTime
        ]
    }
}
