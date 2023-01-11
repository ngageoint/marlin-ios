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
    
    func testDescription() {
        let newItem = Modu(context: persistentStore.viewContext)
        newItem.name = "name"
        newItem.date = Date(timeIntervalSince1970: 0)
        newItem.rigStatus = "Inactive"
        newItem.specialStatus = "Wide Berth Requested"
        newItem.longitude = 1.0
        newItem.latitude = 1.0
        newItem.position = "1°00'00\"N \n1°00'00\"E"
        newItem.navArea = "HYDROPAC"
        newItem.region = 6
        newItem.subregion = 63
        
        let description = "MODU\n\n" +
        "Name: name\n" +
        "Date: 1969-12-31\n" +
        "Latitude: 1.0\n" +
        "Longitude: 1.0\n" +
        "Position: 1°00'00\"N \n" +
        "1°00'00\"E\n" +
        "Rig Status: Inactive\n" +
        "Special Status: Wide Berth Requested\n" +
        "distance: 0.0\n" +
        "Navigation Area: HYDROPAC\n" +
        "Region: 6\n" +
        "Sub Region: 63\n"
        
        XCTAssertEqual(description, newItem.description)
    }
    
    func testMapImage() {
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
        
        var circleSize: CGSize = .zero
        var imageSize: CGSize = .zero
        
        for i in 1...18 {
            let images = newItem.mapImage(marker: false, zoomLevel: i, tileBounds3857: MapBoundingBox(swCorner: (x:-10, y:-10), neCorner: (x: 10, y:10)), context: nil)
            XCTAssertNotNil(images)
            XCTAssertEqual(images.count, 2)
            XCTAssertGreaterThan(images[0].size.height, circleSize.height)
            XCTAssertGreaterThan(images[0].size.width, circleSize.width)
            circleSize = images[0].size
            XCTAssertGreaterThan(images[0].size.height, imageSize.height)
            XCTAssertGreaterThan(images[0].size.width, imageSize.width)
            imageSize = images[0].size
        }
    }
}
