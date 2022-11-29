//
//  ModuDataTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 11/9/22.
//

import XCTest
import Combine
import OHHTTPStubs
import CoreData

@testable import Marlin

final class ModuDataTests: XCTestCase {
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
        
        for seedDataFile in Modu.seedDataFiles ?? [] {
            stub(condition: isScheme("file") && pathEndsWith("\(seedDataFile).json")) { request in
                return HTTPStubsResponse(
                    fileAtPath: OHPathForFile("moduMockData.json", type(of: self))!,
                    statusCode: 200,
                    headers: ["Content-Type":"application/json"]
                )
            }
        }
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[Modu.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[Modu.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(Modu.self)
            XCTAssertEqual(count, 2)
            return true
        }
        
        MSI.shared.loadInitialData(type: Modu.decodableRoot, dataType: Modu.self)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testRejectInvalidModuNoName() throws {
        for seedDataFile in Modu.seedDataFiles ?? [] {
            stub(condition: isScheme("file") && pathEndsWith("\(seedDataFile).json")) { request in
                let jsonObject = [
                    "modu": [
                        [
                            "name": nil,
                            "date": "2022-09-16",
                            "rigStatus": "Active",
                            "specialStatus": "Wide Berth Requested",
                            "distance": nil,
                            "latitude": 16.34183333300001,
                            "longitude": 81.92416666700001,
                            "position": "16°20'30.6\"N \n81°55'27\"E",
                            "navArea": "HYDROPAC",
                            "region": 6,
                            "subregion": 63
                        ],
                        [
                            "name": "ABAN III",
                            "date": "2022-10-28",
                            "rigStatus": "Inactive",
                            "specialStatus": "Wide Berth Requested",
                            "distance": nil,
                            "latitude": 18.67283333300003,
                            "longitude": 72.35783333299997,
                            "position": "18°40'22.2\"N \n72°21'28.2\"E",
                            "navArea": "HYDROPAC",
                            "region": 6,
                            "subregion": 63
                        ]
                    ]
                ]
                return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
            }
        }
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[Modu.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[Modu.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(Modu.self)
            XCTAssertEqual(count, 1)
            return true
        }
        
        MSI.shared.loadInitialData(type: Modu.decodableRoot, dataType: Modu.self)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testRejectInvalidModuNoLatitude() throws {
        for seedDataFile in Modu.seedDataFiles ?? [] {
            stub(condition: isScheme("file") && pathEndsWith("\(seedDataFile).json")) { request in
                let jsonObject = [
                    "modu": [
                        [
                            "name": "ABAN II",
                            "date": "2022-09-16",
                            "rigStatus": "Active",
                            "specialStatus": "Wide Berth Requested",
                            "distance": nil,
                            "latitude": nil,
                            "longitude": 81.92416666700001,
                            "position": "16°20'30.6\"N \n81°55'27\"E",
                            "navArea": "HYDROPAC",
                            "region": 6,
                            "subregion": 63
                        ],
                        [
                            "name": "ABAN III",
                            "date": "2022-10-28",
                            "rigStatus": "Inactive",
                            "specialStatus": "Wide Berth Requested",
                            "distance": nil,
                            "latitude": 18.67283333300003,
                            "longitude": 72.35783333299997,
                            "position": "18°40'22.2\"N \n72°21'28.2\"E",
                            "navArea": "HYDROPAC",
                            "region": 6,
                            "subregion": 63
                        ]
                    ]
                ]
                return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
            }
        }
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[Modu.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[Modu.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(Modu.self)
            XCTAssertEqual(count, 1)
            return true
        }
        
        MSI.shared.loadInitialData(type: Modu.decodableRoot, dataType: Modu.self)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testRejectInvalidModuNoLongitude() throws {
        for seedDataFile in Modu.seedDataFiles ?? [] {
            stub(condition: isScheme("file") && pathEndsWith("\(seedDataFile).json")) { request in
                let jsonObject = [
                    "modu": [
                        [
                            "name": "ABAN II",
                            "date": "2022-09-16",
                            "rigStatus": "Active",
                            "specialStatus": "Wide Berth Requested",
                            "distance": nil,
                            "latitude": 16.34183333300001,
                            "longitude": nil,
                            "position": "16°20'30.6\"N \n81°55'27\"E",
                            "navArea": "HYDROPAC",
                            "region": 6,
                            "subregion": 63
                        ],
                        [
                            "name": "ABAN III",
                            "date": "2022-10-28",
                            "rigStatus": "Inactive",
                            "specialStatus": "Wide Berth Requested",
                            "distance": nil,
                            "latitude": 18.67283333300003,
                            "longitude": 72.35783333299997,
                            "position": "18°40'22.2\"N \n72°21'28.2\"E",
                            "navArea": "HYDROPAC",
                            "region": 6,
                            "subregion": 63
                        ]
                    ]
                ]
                return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
            }
        }
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[Modu.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[Modu.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(Modu.self)
            XCTAssertEqual(count, 1)
            return true
        }
        
        MSI.shared.loadInitialData(type: Modu.decodableRoot, dataType: Modu.self)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testDataRequest() {

        let newItem = Modu(context: persistentStore.viewContext)
        newItem.name = "name"
        newItem.date = Date()
        newItem.rigStatus = "Inactive"
        newItem.specialStatus = "Wide Berth Requested"
        newItem.longitude = 1.0
        newItem.latitude = 1.0
        newItem.position = "1°00'00\"N \n1°00'00\"E"
        newItem.navArea = "HYDROPAC"
        newItem.region = 6
        newItem.subregion = 63
        try? persistentStore.viewContext.save()
        
        let requests = Modu.dataRequest()
        XCTAssertEqual(requests.count, 1)
        let request = requests[0]
        XCTAssertEqual(request.method, .get)
        let parameters = request.parameters
        XCTAssertEqual(parameters?.count, 3)
        let maxSourceDate = Modu.dateFormatter.string(from:Calendar.current.date(byAdding: .hour, value: 24, to: Date()) ?? Date())
        XCTAssertEqual(parameters?["maxSourceDate"] as? String, maxSourceDate)
        XCTAssertEqual(parameters?["output"] as? String, "json")
        let minSourceDate = Modu.dateFormatter.string(from:Date())
        XCTAssertEqual(parameters?["minSourceDate"] as? String, minSourceDate)
    }
    
    func testShouldSync() {
        UserDefaults.standard.setValue(false, forKey: "\(Modu.key)DataSourceEnabled")
        XCTAssertFalse(Modu.shouldSync())
        UserDefaults.standard.setValue(true, forKey: "\(Modu.key)DataSourceEnabled")
        UserDefaults.standard.setValue(Date().timeIntervalSince1970 - (60 * 60) - 10, forKey: "\(Modu.key)LastSyncTime")
        XCTAssertTrue(Modu.shouldSync())
        UserDefaults.standard.setValue(Date().timeIntervalSince1970 - (60 * 60) + (60 * 10), forKey: "\(Modu.key)LastSyncTime")
        XCTAssertFalse(Modu.shouldSync())
    }
}
