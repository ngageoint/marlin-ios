//
//  ElectronicPublicationDataTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 11/9/22.
//

import XCTest
import Combine
import OHHTTPStubs
import CoreData

@testable import Marlin

final class ElectronicPublicationDataTests: XCTestCase {

    var cancellable = Set<AnyCancellable>()
    var persistentStore: PersistentStore = PersistenceController.shared
    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
        .receive(on: RunLoop.main)
    
    override func setUp(completion: @escaping (Error?) -> Void) {
        for item in DataSourceList().allTabs {
            UserDefaults.standard.initialDataLoaded = false
            UserDefaults.standard.clearLastSyncTimeSeconds(item.dataSource as! any BatchImportable.Type)
        }
        UserDefaults.standard.lastLoadDate = Date(timeIntervalSince1970: 0)
        
        UserDefaults.standard.setValue(Date(), forKey: "forceReloadDate")
        persistentStoreLoadedPub
            .removeDuplicates()
            .sink { output in
                completion(nil)
            }
            .store(in: &cancellable)
        persistentStore.reset()
    }
    
    override func tearDown() {
    }
    
    func testLoadData() throws {
        
        stub(condition: isScheme("https") && pathEndsWith("/publications/stored-pubs")) { request in
            return HTTPStubsResponse(
                fileAtPath: OHPathForFile("epubMockData.json", type(of: self))!,
                statusCode: 200,
                headers: ["Content-Type":"application/json"]
            )
        }
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[ElectronicPublication.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[ElectronicPublication.key] {
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
        
        MSI.shared.loadData(type: ElectronicPublication.decodableRoot, dataType: ElectronicPublication.self)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testLoadDataDeleteDataNoLongerPresented() throws {
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
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[ElectronicPublication.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[ElectronicPublication.key] {
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
        
        MSI.shared.loadData(type: ElectronicPublication.decodableRoot, dataType: ElectronicPublication.self)
        
        waitForExpectations(timeout: 10, handler: nil)
        
        tester().wait(forTimeInterval: 1)
        let epubs: [ElectronicPublication] = self.persistentStore.viewContext.fetchAll(ElectronicPublication.self)!
        XCTAssertEqual(2, epubs.count)
                
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[ElectronicPublication.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[ElectronicPublication.key] {
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
        
        MSI.shared.loadData(type: ElectronicPublication.decodableRoot, dataType: ElectronicPublication.self)
        
        waitForExpectations(timeout: 10, handler: nil)
        
        let epubs2: [ElectronicPublication] = self.persistentStore.viewContext.fetchAll(ElectronicPublication.self)!
        XCTAssertEqual(1, epubs2.count)
    }
    
    func testRejectInvalidElectronicPublicationNoS3Key() throws {
        stub(condition: isScheme("https") && pathEndsWith("/publications/stored-pubs")) { request in
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
            return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
        }
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[ElectronicPublication.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[ElectronicPublication.key] {
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
        
        MSI.shared.loadData(type: ElectronicPublication.decodableRoot, dataType: ElectronicPublication.self)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testDataRequest() {
        let requests = ElectronicPublication.dataRequest()
        XCTAssertEqual(requests.count, 1)
        let request = requests[0]
        XCTAssertEqual(request.method, .get)
        let parameters = request.parameters
        XCTAssertEqual(parameters?.count, 0)
    }
    
    func testShouldSync() {
        UserDefaults.standard.setValue(false, forKey: "\(ElectronicPublication.key)DataSourceEnabled")
        XCTAssertFalse(ElectronicPublication.shouldSync())
        UserDefaults.standard.setValue(true, forKey: "\(ElectronicPublication.key)DataSourceEnabled")
        UserDefaults.standard.setValue(Date().timeIntervalSince1970 - (60 * 60 * 24 * 1) - 10, forKey: "\(ElectronicPublication.key)LastSyncTime")
        XCTAssertTrue(ElectronicPublication.shouldSync())
        UserDefaults.standard.setValue(Date().timeIntervalSince1970 - (60 * 60 * 24 * 1) + (60 * 10), forKey: "\(ElectronicPublication.key)LastSyncTime")
        XCTAssertFalse(ElectronicPublication.shouldSync())
    }
}
