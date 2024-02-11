//
//  NoticeToMarinersDataTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 11/14/22.
//

import XCTest
import Combine
import OHHTTPStubs
import CoreData

@testable import Marlin
final class NoticeToMarinersDataTests: XCTestCase {
    var cancellable = Set<AnyCancellable>()
    var persistentStore: PersistentStore = PersistenceController.shared
    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
        .receive(on: RunLoop.main)
    
    override func setUp(completion: @escaping (Error?) -> Void) {
        for dataSource in DataSourceDefinitions.allCases {
            UserDefaults.standard.initialDataLoaded = false
            UserDefaults.standard.clearLastSyncTimeSeconds(dataSource.definition)
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
    
    func testLoadInitialData() throws {
        
        for seedDataFile in NoticeToMariners.seedDataFiles ?? [] {
            stub(condition: isScheme("file") && pathEndsWith("\(seedDataFile).json")) { request in
                return HTTPStubsResponse(
                    fileAtPath: OHPathForFile("ntmMockData.json", type(of: self))!,
                    statusCode: 200,
                    headers: ["Content-Type":"application/json"]
                )
            }
        }
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[NoticeToMariners.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[NoticeToMariners.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let context = self.persistentStore.newTaskContext()
            context.performAndWait {
                let count = try? context.countOfObjects(NoticeToMariners.self)
                XCTAssertEqual(count, 22)
                let first = try? context.fetchFirst(NoticeToMariners.self, sortBy: [NoticeToMariners.defaultSort[0].toNSSortDescriptor()], predicate: NSPredicate(format: "odsEntryId == %i", argumentArray: [29431]))
                XCTAssertEqual(first?.odsEntryId, 29431)
                //            "2022-11-08T12:28:33.961+0000"
                var dateComponents = DateComponents()
                dateComponents.year = 2022
                dateComponents.month = 11
                dateComponents.day = 8
                dateComponents.hour = 12
                dateComponents.minute = 28
                dateComponents.second = 33
                dateComponents.nanosecond = 961 * 1000000
                dateComponents.timeZone = TimeZone(secondsFromGMT: 0)
                
                let calendar = Calendar.current
                let date = calendar.date(from: dateComponents)!
                XCTAssertEqual(first?.uploadTime, date)
                
                //            2022-11-08T12:28:33.961Z
                XCTAssertEqual(first?.lastModified, date)
            }
            return true
        }
        
        MSI.shared.loadInitialData(type: NoticeToMariners.decodableRoot, dataType: NoticeToMariners.self)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testLoadInitialDataAndUpdateWithNewData() throws {
        
        for seedDataFile in NoticeToMariners.seedDataFiles ?? [] {
            stub(condition: isScheme("file") && pathEndsWith("\(seedDataFile).json")) { request in
                return HTTPStubsResponse(
                    fileAtPath: OHPathForFile("ntmMockData.json", type(of: self))!,
                    statusCode: 200,
                    headers: ["Content-Type":"application/json"]
                )
            }
        }
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[NoticeToMariners.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[NoticeToMariners.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(NoticeToMariners.self)
            XCTAssertEqual(count, 22)
            return true
        }
        
        MSI.shared.loadInitialData(type: NoticeToMariners.decodableRoot, dataType: NoticeToMariners.self)
        
        waitForExpectations(timeout: 10, handler: nil)
        
        stub(condition: isScheme("https") && pathEndsWith("/publications/ntm/pubs") && containsQueryParams(["minNoticeNumber": "202247"])) { request in
            let jsonObject = [
                "pubs": [
                    [
                        "publicationIdentifier":41791,
                        "noticeNumber":202248,
                        "title":"Front Cover",
                        "odsKey":"16694429/SFH00000/UNTM/202248/Front_Cover.pdf",
                        "sectionOrder":20,
                        "limitedDist":false,
                        "odsEntryId":29432,
                        "odsContentId":16694429,
                        "internalPath":"UNTM/202247",
                        "filenameBase":"Front_Cover",
                        "fileExtension":"pdf",
                        "fileSize":63491,
                        "isFullPublication":false,
                        "uploadTime":"2022-11-08T12:28:33.961+0000",
                        "lastModified":"2022-11-08T12:28:33.961Z"
                    ]
                ]
            ]
            return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
        }
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[NoticeToMariners.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[NoticeToMariners.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        let e = XCTNSPredicateExpectation(predicate: NSPredicate(block: { observedObject, change in
            if let count = try? self.persistentStore.countOfObjects(NoticeToMariners.self) {
                print("count is \(count)")
                return count == 23
            }
            return false
        }), object: self.persistentStore.viewContext)
        
        
        MSI.shared.loadData(type: NoticeToMariners.decodableRoot, dataType: NoticeToMariners.self)
        
        waitForExpectations(timeout: 10, handler: nil)
        wait(for: [e], timeout: 10)
        
        let newNtm = try! XCTUnwrap(self.persistentStore.fetchFirst(NoticeToMariners.self, sortBy: [NoticeToMariners.defaultSort[0].toNSSortDescriptor()], predicate: NSPredicate(format: "noticeNumber = %d", 202248), context: nil))
        
        XCTAssertEqual(newNtm.noticeNumber, 202248)
    }
    
    func testRejectInvalidNoticeToMarinersNoOdsEntryId() throws {
        for seedDataFile in NoticeToMariners.seedDataFiles ?? [] {
            stub(condition: isScheme("file") && pathEndsWith("\(seedDataFile).json")) { request in
                let jsonObject = [
                    "pubs": [
                        [
                            "publicationIdentifier":41791,
                            "noticeNumber":202248,
                            "title":"Front Cover",
                            "odsKey":"16694429/SFH00000/UNTM/202248/Front_Cover.pdf",
                            "sectionOrder":20,
                            "limitedDist":false,
                            "odsEntryId":nil,
                            "odsContentId":16694429,
                            "internalPath":"UNTM/202247",
                            "filenameBase":"Front_Cover",
                            "fileExtension":"pdf",
                            "fileSize":63491,
                            "isFullPublication":false,
                            "uploadTime":"2022-11-08T12:28:33.961+0000",
                            "lastModified":"2022-11-08T12:28:33.961Z"
                        ],[
                            "publicationIdentifier":41792,
                            "noticeNumber":202248,
                            "title":"Front Cover 2",
                            "odsKey":"16694429/SFH00000/UNTM/202248/Front_Cover2.pdf",
                            "sectionOrder":20,
                            "limitedDist":false,
                            "odsEntryId":29431,
                            "odsContentId":16694429,
                            "internalPath":"UNTM/202247",
                            "filenameBase":"Front_Cover",
                            "fileExtension":"pdf",
                            "fileSize":63491,
                            "isFullPublication":false,
                            "uploadTime":"2022-11-08T12:28:33.961+0000",
                            "lastModified":"2022-11-08T12:28:33.961Z"
                        ]
                    ]
                ]
                return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
            }
        }
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[NoticeToMariners.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[NoticeToMariners.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(NoticeToMariners.self)
            XCTAssertEqual(count, 1)
            return true
        }
        
        MSI.shared.loadInitialData(type: NoticeToMariners.decodableRoot, dataType: NoticeToMariners.self)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testRejectInvalidNoticeToMarinersNoOdsKey() throws {
        for seedDataFile in NoticeToMariners.seedDataFiles ?? [] {
            stub(condition: isScheme("file") && pathEndsWith("\(seedDataFile).json")) { request in
                let jsonObject = [
                    "pubs": [
                        [
                            "publicationIdentifier":41791,
                            "noticeNumber":202248,
                            "title":"Front Cover",
                            "odsKey":nil,
                            "sectionOrder":20,
                            "limitedDist":false,
                            "odsEntryId":29432,
                            "odsContentId":16694429,
                            "internalPath":"UNTM/202247",
                            "filenameBase":"Front_Cover",
                            "fileExtension":"pdf",
                            "fileSize":63491,
                            "isFullPublication":false,
                            "uploadTime":"2022-11-08T12:28:33.961+0000",
                            "lastModified":"2022-11-08T12:28:33.961Z"
                        ],[
                            "publicationIdentifier":41792,
                            "noticeNumber":202248,
                            "title":"Front Cover 2",
                            "odsKey":"16694429/SFH00000/UNTM/202248/Front_Cover2.pdf",
                            "sectionOrder":20,
                            "limitedDist":false,
                            "odsEntryId":29431,
                            "odsContentId":16694429,
                            "internalPath":"UNTM/202247",
                            "filenameBase":"Front_Cover",
                            "fileExtension":"pdf",
                            "fileSize":63491,
                            "isFullPublication":false,
                            "uploadTime":"2022-11-08T12:28:33.961+0000",
                            "lastModified":"2022-11-08T12:28:33.961Z"
                        ]
                    ]
                ]
                return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
            }
        }
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[NoticeToMariners.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[NoticeToMariners.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(NoticeToMariners.self)
            XCTAssertEqual(count, 1)
            return true
        }
        
        MSI.shared.loadInitialData(type: NoticeToMariners.decodableRoot, dataType: NoticeToMariners.self)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testShouldSync() {
        UserDefaults.standard.setValue(false, forKey: "\(NoticeToMariners.key)DataSourceEnabled")
        XCTAssertFalse(NoticeToMariners.shouldSync())
        UserDefaults.standard.setValue(true, forKey: "\(NoticeToMariners.key)DataSourceEnabled")
        UserDefaults.standard.setValue(Date().timeIntervalSince1970 - (60 * 60 * 24) - 10, forKey: "\(NoticeToMariners.key)LastSyncTime")
        XCTAssertTrue(NoticeToMariners.shouldSync())
        UserDefaults.standard.setValue(Date().timeIntervalSince1970 - (60 * 60 * 24) + (60 * 10), forKey: "\(NoticeToMariners.key)LastSyncTime")
        XCTAssertFalse(NoticeToMariners.shouldSync())
    }
}
