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
