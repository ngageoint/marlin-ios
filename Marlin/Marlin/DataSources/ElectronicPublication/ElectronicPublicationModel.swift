//
//  ElectronicPublicationModel.swift
//  Marlin
//
//  Created by Daniel Barela on 2/1/24.
//

import Foundation

struct ElectronicPublicationListModel: Hashable, Identifiable, Bookmarkable {
    var id: String {
        s3Key ?? ""
    }

    var itemKey: String {
        return s3Key ?? ""
    }

    var itemTitle: String {
        return "\(self.sectionDisplayName ?? "")"
    }
    static var definition: any DataSourceDefinition = DataSourceDefinitions.epub.definition

    let sectionDisplayName: String?
    let fileSize: Int?
    let uploadTime: Date?
    let s3Key: String?

    var canBookmark: Bool = false

    init(epub: ElectronicPublication) {
        self.canBookmark = true
        self.sectionDisplayName = epub.sectionDisplayName
        self.fileSize = Int(epub.fileSize)
        self.uploadTime = epub.uploadTime
        self.s3Key = epub.s3Key
    }
}

struct ElectronicPublicationModel: Bookmarkable, Codable, Hashable, Identifiable {

    static var definition: any DataSourceDefinition = DataSourceDefinitions.epub.definition

    var canBookmark: Bool = false

    var id: String {
        s3Key ?? ""
    }

    var itemKey: String {
        return s3Key ?? ""
    }

    var itemTitle: String {
        return "\(self.sectionDisplayName ?? "")"
    }

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

        var parsedPubsecLastModifiedDate: Date?
        if let dateString = try? values.decode(String.self, forKey: .pubsecLastModified) {
            if let date = ElectronicPublication.dateFormatter.date(from: dateString) {
                parsedPubsecLastModifiedDate = date
            }
        }
        self.pubsecLastModified = parsedPubsecLastModifiedDate

        var parsedSectionLastModifiedDate: Date?
        if let dateString = try? values.decode(String.self, forKey: .sectionLastModified) {
            if let date = ElectronicPublication.dateFormatter.date(from: dateString) {
                parsedSectionLastModifiedDate = date
            }
        }
        self.sectionLastModified = parsedSectionLastModifiedDate

        var parsedUploadTime: Date?
        if let dateString = try? values.decode(String.self, forKey: .uploadTime) {
            if let date = ElectronicPublication.dateFormatter.date(from: dateString) {
                parsedUploadTime = date
            }
        }
        self.uploadTime = parsedUploadTime
    }

    init(epub: ElectronicPublication) {
        self.canBookmark = true
        self.contentId = Int(epub.contentId)
        self.fileExtension = epub.fileExtension
        self.filenameBase = epub.filenameBase
        self.fileSize = Int(epub.fileSize)
        self.fullFilename = epub.fullFilename
        self.fullPubFlag = epub.fullPubFlag
        self.internalPath = epub.internalPath
        self.odsEntryId = Int(epub.odsEntryId)
        self.pubDownloadDisplayName = epub.pubDownloadDisplayName
        self.pubDownloadId = Int(epub.pubDownloadId)
        self.pubDownloadOrder = Int(epub.pubDownloadOrder)
        self.pubsecId = Int(epub.pubsecId)
        self.pubsecLastModified = epub.pubsecLastModified
        self.pubTypeId = Int(epub.pubTypeId)
        self.s3Key = epub.s3Key
        self.sectionDisplayName = epub.sectionDisplayName
        self.sectionLastModified = epub.sectionLastModified
        self.sectionName = epub.sectionName
        self.sectionOrder = Int(epub.sectionOrder)
        self.uploadTime = epub.uploadTime
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
