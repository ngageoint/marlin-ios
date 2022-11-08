//
//  ASAMDataTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 11/1/22.
//

import XCTest
import Combine
import OHHTTPStubs
import CoreData

@testable import Marlin

final class ASAMDataTests: XCTestCase {
    var cancellable = Set<AnyCancellable>()
    var persistenceController: PersistenceController = PersistenceController.memory
    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
        .receive(on: RunLoop.main)
    
    override func setUp(completion: @escaping (Error?) -> Void) {
        for item in DataSourceList().allTabs {
            UserDefaults.standard.initialDataLoaded = false
            UserDefaults.standard.clearLastSyncTimeSeconds(item.dataSource)
        }
        UserDefaults.standard.lastLoadDate = Date(timeIntervalSince1970: 0)
        
        UserDefaults.standard.setValue(Date(), forKey: "forceReloadDate")
        persistentStoreLoadedPub
            .removeDuplicates()
            .sink { output in
                print("xxx persistent store loaded")
                completion(nil)
            }
            .store(in: &cancellable)
            
        persistenceController.reset()
    }
        
    override func tearDown() {
    }

    func testLoadInitialData() throws {

        for seedDataFile in Asam.seedDataFiles ?? [] {
            stub(condition: isScheme("file") && pathEndsWith("\(seedDataFile).json")) { request in
                return HTTPStubsResponse(
                    fileAtPath: OHPathForFile("asamMockData.json", type(of: self))!,
                    statusCode: 200,
                    headers: ["Content-Type":"application/json"]
                )
            }
        }
        
        expectation(forNotification: .DataSourceLoading,
                                                  object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[Asam.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                                                  object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[Asam.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistenceController.container.viewContext.countOfObjects(Asam.self)
            XCTAssertEqual(count, 2)
            return true
        }
            
        MSI.shared.loadInitialData(type: Asam.decodableRoot, dataType: Asam.self)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testRejectInvalidAsamNoReference() throws {
        for seedDataFile in Asam.seedDataFiles ?? [] {
            stub(condition: isScheme("file") && pathEndsWith("\(seedDataFile).json")) { request in
                let jsonObject = [
                    "asam": [
                        [
                            "reference": "2022-100",
                            "date": "2022-10-25",
                            "latitude": 2.0,
                            "longitude": 2.0,
                            "position": "1°00'00\"N \n1°00'00\"E",
                            "navArea": "XI",
                            "subreg": "71",
                            "hostility": "hostility",
                            "victim": "victim",
                            "description": "description"
                        ],
                        [
                            "reference": nil,
                            "date": "2022-10-24",
                            "latitude": 1.0,
                            "longitude": 1.0,
                            "position": "1°00'00\"N \n1°00'00\"E",
                            "navArea": "XI",
                            "subreg": "71",
                            "hostility": "hostility",
                            "victim": "victim",
                            "description": "description"
                        ]
                    ]
                ]
                return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
            }
        }

        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[Asam.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[Asam.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistenceController.container.viewContext.countOfObjects(Asam.self)
            XCTAssertEqual(count, 1)
            return true
        }

        MSI.shared.loadInitialData(type: Asam.decodableRoot, dataType: Asam.self)

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testRejectInvalidAsamNoLatitude() throws {
        for seedDataFile in Asam.seedDataFiles ?? [] {
            stub(condition: isScheme("file") && pathEndsWith("\(seedDataFile).json")) { request in
                let jsonObject = [
                    "asam": [
                        [
                            "reference": "2022-101",
                            "date": "2022-10-25",
                            "latitude": 2.0,
                            "longitude": 2.0,
                            "position": "1°00'00\"N \n1°00'00\"E",
                            "navArea": "XI",
                            "subreg": "71",
                            "hostility": "hostility",
                            "victim": "victim",
                            "description": "description"
                        ],
                        [
                            "reference": "2022-102",
                            "date": "2022-10-24",
                            "latitude": nil,
                            "longitude": 1.0,
                            "position": "1°00'00\"N \n1°00'00\"E",
                            "navArea": "XI",
                            "subreg": "71",
                            "hostility": "hostility",
                            "victim": "victim",
                            "description": "description"
                        ]
                    ]
                ]
                return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
            }
        }

        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[Asam.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[Asam.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistenceController.container.viewContext.countOfObjects(Asam.self)
            XCTAssertEqual(count, 1)
            return true
        }

        MSI.shared.loadInitialData(type: Asam.decodableRoot, dataType: Asam.self)

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testRejectInvalidAsamNoLongitude() throws {
        for seedDataFile in Asam.seedDataFiles ?? [] {
            stub(condition: isScheme("file") && pathEndsWith("\(seedDataFile).json")) { request in
                let jsonObject = [
                    "asam": [
                        [
                            "reference": "2022-103",
                            "date": "2022-10-25",
                            "latitude": 2.0,
                            "longitude": 2.0,
                            "position": "1°00'00\"N \n1°00'00\"E",
                            "navArea": "XI",
                            "subreg": "71",
                            "hostility": "hostility",
                            "victim": "victim",
                            "description": "description"
                        ],
                        [
                            "reference": "2022-104",
                            "date": "2022-10-24",
                            "latitude": 1.0,
                            "longitude": nil,
                            "position": "1°00'00\"N \n1°00'00\"E",
                            "navArea": "XI",
                            "subreg": "71",
                            "hostility": "hostility",
                            "victim": "victim",
                            "description": "description"
                        ]
                    ]
                ]
                return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
            }
        }

        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[Asam.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[Asam.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistenceController.container.viewContext.countOfObjects(Asam.self)
            XCTAssertEqual(count, 1)
            return true
        }

        MSI.shared.loadInitialData(type: Asam.decodableRoot, dataType: Asam.self)

        waitForExpectations(timeout: 10, handler: nil)
    }
}
