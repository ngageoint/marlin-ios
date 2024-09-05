//
//  PublicationRemoteDataSourceTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/15/24.
//

import Foundation
import XCTest
import OHHTTPStubs
import Combine

@testable import Marlin

final class PublicationRemoteDataSourceTests: XCTestCase {

    override class func setUp() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults()
    }

    func testFetchAsamsWithoutTask() async {
        let dataSource = PublicationRemoteDataSource()

        stub(condition: isScheme("https") && pathEndsWith("/publications/stored-pubs")) { request in
            let jsonObject = [
                [
                    "pubTypeId":30,
                    "pubDownloadId":14,
                    "fullPubFlag":false,
                    "pubDownloadOrder":4,
                    "pubDownloadDisplayName":"Pub. 108 - Atlas of Pilot Charts North Pacific Ocean, 3rd Ed. 1994",
                    "pubsecId":68,
                    "odsEntryId":22205,
                    "sectionOrder":14,
                    "sectionName":"108dec",
                    "sectionDisplayName":"Pub. 108: December",
                    "sectionLastModified":"2019-09-20T14:02:18.929+0000",
                    "contentId":16693989,
                    "internalPath":"",
                    "filenameBase":"108dec",
                    "fileExtension":"pdf",
                    "s3Key":"16693989/SFH00000/108dec.pdf",
                    "fileSize":8573556,
                    "uploadTime":"2019-09-20T14:02:18.929+0000",
                    "fullFilename":"108dec.pdf",
                    "pubsecLastModified":"2019-09-20T14:02:18.929685Z"
                ],
                [
                    "pubTypeId": 9,
                    "pubDownloadId": 3,
                    "fullPubFlag": false,
                    "pubDownloadOrder": 1,
                    "pubDownloadDisplayName": "Pub. 110 - Greenland, East Coasts of North and South America, and West Indies",
                    "pubsecId": 130,
                    "odsEntryId": 22626,
                    "sectionOrder": 2,
                    "sectionName": "Pub110bk",
                    "sectionDisplayName": "Pub 110",
                    "sectionLastModified": "2022-09-20T15:38:12.825+0000",
                    "contentId": 16694312,
                    "internalPath": "NIMA_LOL/Pub110",
                    "filenameBase": "Pub110bk",
                    "fileExtension": "pdf",
                    "s3Key": "16694312/SFH00000/NIMA_LOL/Pub110/Pub110bk.pdf",
                    "fileSize": 2389497,
                    "uploadTime": "2022-09-20T15:38:12.825+0000",
                    "fullFilename": "Pub110bk.pdf",
                    "pubsecLastModified": "2022-09-20T15:38:12.825Z"
                ]
            ]
            return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
        }

        let epubs = await dataSource.fetch()

        XCTAssertEqual(epubs.count, 2)
        let newEpub = epubs[0]

        XCTAssertEqual(newEpub.pubTypeId, 30)
    }
}
