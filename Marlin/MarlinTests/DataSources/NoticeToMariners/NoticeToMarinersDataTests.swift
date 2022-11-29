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
    var persistentStore: PersistentStore = PersistenceController.memory
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
        persistentStore = PersistenceController.memory
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
            let count = try? self.persistentStore.countOfObjects(NoticeToMariners.self)
            XCTAssertEqual(count, 22)
            let first = try? self.persistentStore.fetchFirst(NoticeToMariners.self, sortBy: [NoticeToMariners.defaultSort[0].toNSSortDescriptor()], predicate: NSPredicate(format: "odsEntryId == %i", argumentArray: [29431]))
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
            return true
        }
        
        MSI.shared.loadInitialData(type: NoticeToMariners.decodableRoot, dataType: NoticeToMariners.self)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
}
