//
//  PublicationDataTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 11/9/22.
//

import XCTest
import Combine
import OHHTTPStubs
import CoreData

@testable import Marlin

final class PublicationDataTests: XCTestCase {

    var cancellable = Set<AnyCancellable>()
    var persistentStore: PersistentStore = PersistenceController.shared
    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
        .receive(on: RunLoop.main)
    
    override func setUp(completion: @escaping (Error?) -> Void) {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults()

        UserDefaults.standard.initialDataLoaded = false
        UserDefaults.standard.clearLastSyncTimeSeconds(DataSources.epub)
        UserDefaults.standard.lastLoadDate = Date(timeIntervalSince1970: 0)
        UserDefaults.standard.setValue(Date(), forKey: "forceReloadDate")
        
        UserDefaults.standard.setFilter(DataSources.epub.key, filter: [])
        UserDefaults.standard.setSort(DataSources.epub.key, sort: DataSources.epub.filterable!.defaultSort)
        persistentStoreLoadedPub
            .removeDuplicates()
            .sink { output in
                completion(nil)
            }
            .store(in: &cancellable)
        persistentStore.reset()
        
    }
    override func tearDown() {
        HTTPStubs.removeAllStubs()
    }
    
    func testLoadData() throws {
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.epub.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.epub.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(ElectronicPublication.self)
            XCTAssertEqual(count, 2)
            return true
        }

        expectation(forNotification: .BatchUpdateComplete,
                    object: nil) { notification in
            guard let updatedNotification = notification.object as? BatchUpdateComplete else {
                XCTFail("Incorrect notification")
                return false
            }
            let updates = updatedNotification.dataSourceUpdates
            if updates.isEmpty {
                XCTFail("should be some updates")
                return false
            }
            XCTAssertFalse(updates.isEmpty)
            let update = updates[0]
            XCTAssertEqual(2, update.inserts)
            XCTAssertEqual(0, update.updates)
            return true
        }

        let bundle = MockBundle()
        bundle.mockPath = "epubMockData.json"
        InjectedValues[\.publicationLocalDataSource] = PublicationCoreDataDataSource()

        let operation = PublicationInitialDataLoadOperation(bundle: bundle)
        operation.start()

        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testLoadDataDeleteDataNoLongerPresented() async throws {
        var callCount = 0
        
        stub(condition: isScheme("https") && pathEndsWith("/publications/stored-pubs")) { request in
            if callCount == 0 {
                callCount = 1
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
            } else {
                let jsonObject = [
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
        }
        
        let loadingNotification = expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.epub.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        let loadedNotification = expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.epub.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        let didSaveNotification = expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(ElectronicPublication.self)
            XCTAssertEqual(count, 2)
            return true
        }

        let batchUpdateCompleteNotification = expectation(forNotification: .BatchUpdateComplete,
                                                          object: nil) { notification in
            guard let updatedNotification = notification.object as? BatchUpdateComplete else {
                XCTFail("Incorrect notification")
                return false
            }
            let updates = updatedNotification.dataSourceUpdates
            if updates.isEmpty {
                XCTFail("should be some updates")
            }
            XCTAssertFalse(updates.isEmpty)
            let update = updates[0]
            XCTAssertEqual(2, update.inserts)
            XCTAssertEqual(0, update.updates)
            return true
        }

        let localDataSource = PublicationCoreDataDataSource()
        let remoteDataSource = PublicationRemoteDataSource()
        InjectedValues[\.publicationLocalDataSource] = localDataSource
        InjectedValues[\.publicationRemoteDataSource] = remoteDataSource
        
        let repository = PublicationRepository()

        let fetched = await repository.fetch()

        await fulfillment(of: [loadingNotification, loadedNotification, didSaveNotification, batchUpdateCompleteNotification], timeout: 10)

        XCTAssertEqual(repository.getCount(filters: nil), 2)

        let loadingNotification2 = expectation(forNotification: .DataSourceLoading,
                                              object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.epub.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let loadedNotification2 = expectation(forNotification: .DataSourceLoaded,
                                             object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.epub.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let didSaveNotification2 = expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(ElectronicPublication.self)
            XCTAssertEqual(count, 1)
            return true
        }

        let batchUpdateCompleteNotification2 = expectation(forNotification: .BatchUpdateComplete,
                                                          object: nil) { notification in
            guard let updatedNotification = notification.object as? BatchUpdateComplete else {
                XCTFail("Incorrect notification")
                return false
            }
            let updates = updatedNotification.dataSourceUpdates
            if updates.isEmpty {
                XCTFail("should be some updates")
            }
            NSLog("updates \(updates)")
            XCTAssertFalse(updates.isEmpty)
            let update = updates[0]
            XCTAssertEqual(0, update.inserts)
            XCTAssertEqual(0, update.updates)
            XCTAssertEqual(1, update.deletes)
            return true
        }

        // force the sync
        UserDefaults.standard.clearLastSyncTimeSeconds(DataSources.epub)
        let fetched2 = await repository.fetch()

        await fulfillment(of: [loadingNotification2, loadedNotification2, didSaveNotification2, batchUpdateCompleteNotification2], timeout: 10)

        XCTAssertEqual(repository.getCount(filters: nil), 1)
    }
    
    func testRejectInvalidElectronicPublicationNoS3Key() throws {
        let jsonObject = [
            [
                "pubTypeId": 9,
                "pubDownloadId": 3,
                "fullPubFlag": false,
                "pubDownloadOrder": 1,
                "pubDownloadDisplayName": "Pub. 110 - Greenland, East Coasts of North and South America, and West Indies",
                "pubsecId": 129,
                "odsEntryId": 22266,
                "sectionOrder": 1,
                "sectionName": "UpdatedPub110bk",
                "sectionDisplayName": "Pub 110 - Updated to NTM 44/22",
                "sectionLastModified": "2022-10-24T17:06:57.757+0000",
                "contentId": 16694312,
                "internalPath": "NIMA_LOL/Pub110",
                "filenameBase": "UpdatedPub110bk",
                "fileExtension": "pdf",
                "s3Key": nil,
                "fileSize": 2389496,
                "uploadTime": "2022-10-24T17:06:57.757+0000",
                "fullFilename": "UpdatedPub110bk.pdf",
                "pubsecLastModified": "2022-10-24T17:06:57.757Z"
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

        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.epub.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.epub.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(ElectronicPublication.self)
            XCTAssertEqual(count, 1)
            return true
        }

        let bundle = MockBundle()
        bundle.tempFileContentArray = jsonObject

        let operation = PublicationInitialDataLoadOperation(bundle: bundle)
        operation.start()

        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testDataRequest() {
        let request = PublicationService.getPublications
        XCTAssertEqual(request.method, .get)
        let parameters = request.parameters
        XCTAssertEqual(parameters?.count, 0)
    }
    
    func testShouldSync() {
        UserDefaults.standard.setValue(false, forKey: "\(DataSources.epub.key)DataSourceEnabled")
        XCTAssertFalse(DataSources.epub.shouldSync())
        UserDefaults.standard.setValue(true, forKey: "\(DataSources.epub.key)DataSourceEnabled")
        UserDefaults.standard.setValue(Date().timeIntervalSince1970 - (60 * 60 * 24 * 1) - 10, forKey: "\(DataSources.epub.key)LastSyncTime")
        XCTAssertTrue(DataSources.epub.shouldSync())
        UserDefaults.standard.setValue(Date().timeIntervalSince1970 - (60 * 60 * 24 * 1) + (60 * 10), forKey: "\(DataSources.epub.key)LastSyncTime")
        XCTAssertFalse(DataSources.epub.shouldSync())
    }
}
