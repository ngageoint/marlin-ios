//
//  NoticeToMarinersModel.swift
//  Marlin
//
//  Created by Daniel Barela on 2/1/24.
//

import Foundation
import CoreLocation
import GeoJSON
import UIKit
import OSLog

struct NoticeToMarinersListModel: Hashable, Identifiable {
    var dateString: String? {
        if let date = lastModified {
            return DataSources.noticeToMariners.dateFormatter.string(from: date)
        }
        return nil
    }

    var itemTitle: String {
        return "\(self.title ?? "") \(self.isFullPublication ?? false ? (self.fileExtension ?? "") : "")"
    }

    static var definition: any DataSourceDefinition {
        DataSources.asam
    }

    var id: String {
        "\(noticeNumber ?? -1)"
    }

    var itemKey: String {
        return "\(noticeNumber ?? -1)"
    }

    var key: String {
        DataSources.noticeToMariners.key
    }

    var publicationIdentifier: Int?
    var noticeNumber: Int?
    var title: String?
    var odsKey: String?
    var sectionOrder: Int?
    var limitedDist: Bool?
    var odsEntryId: Int?
    var odsContentId: Int?
    var internalPath: String?
    var filenameBase: String?
    var fileExtension: String?
    var fileSize: Int?
    var isFullPublication: Bool?
    var uploadTime: Date?
    var lastModified: Date?
    var canBookmark: Bool = false

    init(noticeToMariners: NoticeToMariners) {
        self.canBookmark = true
        publicationIdentifier = Int(noticeToMariners.publicationIdentifier)
        noticeNumber = Int(noticeToMariners.noticeNumber)
        title = noticeToMariners.title
        odsKey = noticeToMariners.odsKey
        sectionOrder = Int(noticeToMariners.sectionOrder)
        limitedDist = noticeToMariners.limitedDist
        odsEntryId = Int(noticeToMariners.odsEntryId)
        odsContentId = Int(noticeToMariners.odsContentId)
        internalPath = noticeToMariners.internalPath
        filenameBase = noticeToMariners.filenameBase
        fileExtension = noticeToMariners.fileExtension
        fileSize = Int(noticeToMariners.fileSize)
        isFullPublication = noticeToMariners.isFullPublication
        uploadTime = noticeToMariners.uploadTime
        lastModified = noticeToMariners.lastModified
    }
}

extension NoticeToMarinersListModel {
    init(noticeToMarinersModel: NoticeToMarinersModel) {
        publicationIdentifier = noticeToMarinersModel.publicationIdentifier
        noticeNumber = noticeToMarinersModel.noticeNumber
        title = noticeToMarinersModel.title
        odsKey = noticeToMarinersModel.odsKey
        sectionOrder = noticeToMarinersModel.sectionOrder
        limitedDist = noticeToMarinersModel.limitedDist
        odsEntryId = noticeToMarinersModel.odsEntryId
        odsContentId = noticeToMarinersModel.odsContentId
        internalPath = noticeToMarinersModel.internalPath
        filenameBase = noticeToMarinersModel.filenameBase
        fileExtension = noticeToMarinersModel.fileExtension
        fileSize = noticeToMarinersModel.fileSize
        isFullPublication = noticeToMarinersModel.isFullPublication
        uploadTime = noticeToMarinersModel.uploadTime
        lastModified = noticeToMarinersModel.lastModified
        canBookmark = noticeToMarinersModel.canBookmark
    }
}

struct NoticeToMarinersModel: Bookmarkable, Codable, Hashable, Identifiable {

    var id: String {
        "\(noticeNumber ?? -1)"
    }

    var itemKey: String {
        return "\(noticeNumber ?? -1)"
    }

    var canBookmark: Bool = false

    static var definition: any DataSourceDefinition = DataSourceDefinitions.noticeToMariners.definition

    var itemTitle: String {
        return "\(self.title ?? "") \(self.isFullPublication ?? false ? (self.fileExtension ?? "") : "")"
    }

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

    var publicationIdentifier: Int?
    var noticeNumber: Int?
    var title: String?
    var odsKey: String?
    var sectionOrder: Int?
    var limitedDist: Bool?
    var odsEntryId: Int?
    var odsContentId: Int?
    var internalPath: String?
    var filenameBase: String?
    var fileExtension: String?
    var fileSize: Int?
    var isFullPublication: Bool?
    var uploadTime: Date?
    var lastModified: Date?

    init() {

    }

    init(noticeToMariners: NoticeToMariners) {
        self.publicationIdentifier = Int(noticeToMariners.publicationIdentifier)
        self.noticeNumber = Int(noticeToMariners.noticeNumber)
        self.title = noticeToMariners.title
        self.odsKey = noticeToMariners.odsKey
        self.sectionOrder = Int(noticeToMariners.sectionOrder)
        self.limitedDist = noticeToMariners.limitedDist
        self.odsEntryId = Int(noticeToMariners.odsEntryId)
        self.odsContentId = Int(noticeToMariners.odsContentId)
        self.internalPath = noticeToMariners.internalPath
        self.filenameBase = noticeToMariners.filenameBase
        self.fileExtension = noticeToMariners.fileExtension
        self.fileSize = Int(noticeToMariners.fileSize)
        self.isFullPublication = noticeToMariners.isFullPublication
        self.uploadTime = noticeToMariners.uploadTime
        self.lastModified = noticeToMariners.lastModified
    }

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

extension NoticeToMarinersModel: DataSource {
    static var properties: [DataSourceProperty] {
        return []
    }

    static var defaultSort: [DataSourceSortParameter] = [
        DataSourceSortParameter(
            property: DataSourceProperty(
                name: "Notice Number",
                key: #keyPath(NoticeToMariners.noticeNumber),
                type: .int),
            ascending: false,
            section: true),
        DataSourceSortParameter(
            property: DataSourceProperty(
                name: "Full Publication",
                key: #keyPath(NoticeToMariners.isFullPublication),
                type: .int),
            ascending: false,
            section: false),
        DataSourceSortParameter(
            property: DataSourceProperty(
                name: "Section Order",
                key: #keyPath(NoticeToMariners.sectionOrder),
                type: .int),
            ascending: true,
            section: false)]
    static var defaultFilter: [DataSourceFilterParameter] = []
    static var isMappable: Bool = false
    static var dataSourceName: String = "NTM"
    static var fullDataSourceName: String = "Notice To Mariners"
    static var key: String = "ntm"
    static var metricsKey: String = "ntms"
    static var color: UIColor = UIColor.red
    static var imageName: String?
    static var systemImageName: String? = "speaker.badge.exclamationmark.fill"

    var color: UIColor {
        NoticeToMariners.color
    }

    static var imageScale: CGFloat = 1.0

    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter
    }
}
