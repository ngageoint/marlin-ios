//
//  PublicationRepositoryTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/15/24.
//

import Foundation
import Combine
import CoreData
import OHHTTPStubs

@testable import Marlin

final class PublicationRepositoryTests: XCTestCase {

    override func setUp() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults()

        UserDefaults.standard.initialDataLoaded = false
        UserDefaults.standard.clearLastSyncTimeSeconds(DataSources.epub)
        UserDefaults.standard.lastLoadDate = Date(timeIntervalSince1970: 0)

        UserDefaults.standard.setValue(Date(), forKey: "forceReloadDate")
    }

    override func tearDown() {
    }

    func testFetch() async {
        var models: [PublicationModel] = []

        let data: [[String: AnyHashable?]] = [
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
        let jsonData = try! JSONSerialization.data(withJSONObject: data)
        let decoded: [PublicationModel] = try! JSONDecoder().decode([PublicationModel].self, from: jsonData)

        models.append(contentsOf: decoded)

        let loadingExpectation = expectation(forNotification: .DataSourceLoading,
                                             object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.epub.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let loadedExpectation = expectation(forNotification: .DataSourceLoaded,
                                            object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.epub.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let updatedExpectation = expectation(forNotification: .DataSourceUpdated,
                                             object: nil) { notification in
            if let notificationObject = notification.object as? DataSourceUpdatedNotification {
                XCTAssertEqual(notificationObject.key, DataSources.epub.key)
                XCTAssertEqual(notificationObject.inserts, 2)
            }
            return true
        }
        let localDataSource = PublicationStaticLocalDataSource()
        let remoteDataSource = PublicationStaticRemoteDataSource()
        remoteDataSource.list = models
        let repository = PublicationRepository(localDataSource: localDataSource, remoteDataSource: remoteDataSource)

        let modus = await repository.fetch()
        XCTAssertEqual(2, modus.count)

        await fulfillment(of: [loadingExpectation, loadedExpectation, updatedExpectation])

        let repoEpub = repository.getPublication(s3Key: "16693989/SFH00000/108dec.pdf")
        XCTAssertNotNil(repoEpub)
        XCTAssertEqual(repoEpub, localDataSource.getPublication(s3Key: "16693989/SFH00000/108dec.pdf"))

        XCTAssertEqual(repository.getCount(filters: nil), localDataSource.getCount(filters: nil))
    }

    func testCreateOperation() {
        let localDataSource = PublicationStaticLocalDataSource()
        let remoteDataSource = PublicationStaticRemoteDataSource()

        let repository = PublicationRepository(localDataSource: localDataSource, remoteDataSource: remoteDataSource)
        let operation = repository.createOperation()
        XCTAssertNotNil(operation)
    }
}
