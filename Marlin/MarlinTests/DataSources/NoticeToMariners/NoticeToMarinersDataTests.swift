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
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults()

        UserDefaults.standard.initialDataLoaded = false
        UserDefaults.standard.clearLastSyncTimeSeconds(DataSources.noticeToMariners)
        UserDefaults.standard.lastLoadDate = Date(timeIntervalSince1970: 0)
        UserDefaults.standard.setValue(Date(), forKey: "forceReloadDate")

        UserDefaults.standard.setFilter(DataSources.noticeToMariners.key, filter: [])
        UserDefaults.standard.setSort(DataSources.noticeToMariners.key, sort: DataSources.noticeToMariners.filterable!.defaultSort)
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
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.noticeToMariners.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.noticeToMariners.key] {
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
            XCTAssertEqual(22, update.inserts)
            XCTAssertEqual(0, update.updates)
            return true
        }

        let bundle = MockBundle()
        bundle.mockPath = "ntmMockData.json"

        let localDataSource = NoticeToMarinersCoreDataDataSource()
        let remoteDataSource = NoticeToMarinersRemoteDataSource()
        InjectedValues[\.ntmLocalDataSource] = localDataSource
        InjectedValues[\.ntmRemoteDataSource] = remoteDataSource
        
        let operation = NoticeToMarinersInitialDataLoadOperation(bundle: bundle)
        operation.start()

        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testLoadInitialDataAndUpdateWithNewData() async throws {

        let loadingExpectation = expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.noticeToMariners.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let loadedExpectation = expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.noticeToMariners.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let didSaveExpectation = expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(NoticeToMariners.self)
            XCTAssertEqual(count, 22)
            return true
        }

        let batchUpdateCompleteExpectation = expectation(forNotification: .BatchUpdateComplete,
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
            XCTAssertEqual(22, update.inserts)
            XCTAssertEqual(0, update.updates)
            return true
        }

        let bundle = MockBundle()
        bundle.mockPath = "ntmMockData.json"
        let localDataSource = NoticeToMarinersCoreDataDataSource()
        let remoteDataSource = NoticeToMarinersRemoteDataSource()
        InjectedValues[\.ntmLocalDataSource] = localDataSource
        InjectedValues[\.ntmRemoteDataSource] = remoteDataSource
        
        let operation = NoticeToMarinersInitialDataLoadOperation(bundle: bundle)
        operation.start()

        await fulfillment(of: [loadingExpectation, loadedExpectation, didSaveExpectation, batchUpdateCompleteExpectation], timeout: 10)

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

        let repository = NoticeToMarinersRepository()
        XCTAssertEqual(repository.getCount(filters: nil), 22)
        let loadingNotification2 = expectation(forNotification: .DataSourceLoading,
                                               object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.noticeToMariners.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let loadedNotification2 = expectation(forNotification: .DataSourceLoaded,
                                              object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.noticeToMariners.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let didSaveNotification2 = expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(NoticeToMariners.self)
            XCTAssertEqual(count, 23)
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
            XCTAssertEqual(1, update.inserts)
            XCTAssertEqual(0, update.updates)
            XCTAssertEqual(0, update.deletes)
            return true
        }

        let fetched = await repository.fetchNoticeToMariners()

        await fulfillment(of: [loadingNotification2, loadedNotification2, didSaveNotification2, batchUpdateCompleteNotification2], timeout: 10)

        XCTAssertEqual(repository.getCount(filters: nil), 23)

        let newNtm = repository.getNoticeToMariners(odsEntryId: 29432)

        XCTAssertEqual(newNtm?.noticeNumber, 202248)
    }
    
    func testRejectInvalidNoticeToMarinersNoOdsEntryId() async throws {
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
        
        let loadingNotification2 = expectation(forNotification: .DataSourceLoading,
                                               object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.noticeToMariners.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let loadedNotification2 = expectation(forNotification: .DataSourceLoaded,
                                              object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.noticeToMariners.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let didSaveNotification2 = expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(NoticeToMariners.self)
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
            XCTAssertEqual(1, update.inserts)
            XCTAssertEqual(0, update.updates)
            XCTAssertEqual(0, update.deletes)
            return true
        }

        let bundle = MockBundle()
        bundle.tempFileContents = jsonObject
        
        let localDataSource = NoticeToMarinersCoreDataDataSource()
        let remoteDataSource = NoticeToMarinersRemoteDataSource()
        InjectedValues[\.ntmLocalDataSource] = localDataSource
        InjectedValues[\.ntmRemoteDataSource] = remoteDataSource

        let operation = NoticeToMarinersInitialDataLoadOperation(bundle: bundle)
        operation.start()

        await fulfillment(of: [loadingNotification2, loadedNotification2, didSaveNotification2, batchUpdateCompleteNotification2], timeout: 10)
    }
    
    func testRejectInvalidNoticeToMarinersNoOdsKey() async throws {
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
        let loadingNotification2 = expectation(forNotification: .DataSourceLoading,
                                               object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.noticeToMariners.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let loadedNotification2 = expectation(forNotification: .DataSourceLoaded,
                                              object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.noticeToMariners.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let didSaveNotification2 = expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(NoticeToMariners.self)
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
            XCTAssertEqual(1, update.inserts)
            XCTAssertEqual(0, update.updates)
            XCTAssertEqual(0, update.deletes)
            return true
        }

        let bundle = MockBundle()
        bundle.tempFileContents = jsonObject

        let localDataSource = NoticeToMarinersCoreDataDataSource()
        let remoteDataSource = NoticeToMarinersRemoteDataSource()
        InjectedValues[\.ntmLocalDataSource] = localDataSource
        InjectedValues[\.ntmRemoteDataSource] = remoteDataSource
        let operation = NoticeToMarinersInitialDataLoadOperation(bundle: bundle)
        operation.start()

        await fulfillment(of: [loadingNotification2, loadedNotification2, didSaveNotification2, batchUpdateCompleteNotification2], timeout: 10)
    }
    
    func testShouldSync() {
        UserDefaults.standard.setValue(false, forKey: "\(DataSources.noticeToMariners.key)DataSourceEnabled")
        XCTAssertFalse(DataSources.noticeToMariners.shouldSync())
        UserDefaults.standard.setValue(true, forKey: "\(DataSources.noticeToMariners.key)DataSourceEnabled")
        UserDefaults.standard.setValue(Date().timeIntervalSince1970 - (60 * 60 * 24) - 10, forKey: "\(DataSources.noticeToMariners.key)LastSyncTime")
        XCTAssertTrue(DataSources.noticeToMariners.shouldSync())
        UserDefaults.standard.setValue(Date().timeIntervalSince1970 - (60 * 60 * 24) + (60 * 10), forKey: "\(DataSources.noticeToMariners.key)LastSyncTime")
        XCTAssertFalse(DataSources.noticeToMariners.shouldSync())
    }
}
