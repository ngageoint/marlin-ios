//
//  LightDataTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 11/9/22.
//

import XCTest
import Combine
import OHHTTPStubs
import CoreData

@testable import Marlin

final class LightDataTests: XCTestCase {

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
        
        for seedDataFile in Light.seedDataFiles ?? [] {
            stub(condition: isScheme("file") && pathEndsWith("\(seedDataFile).json")) { request in
                return HTTPStubsResponse(
                    fileAtPath: OHPathForFile("lightMockData.json", type(of: self))!,
                    statusCode: 200,
                    headers: ["Content-Type":"application/json"]
                )
            }
        }
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[Light.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[Light.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(Light.self)
            XCTAssertEqual(count, 2)
            return true
        }
        
        MSI.shared.loadInitialData(type: Light.decodableRoot, dataType: Light.self)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testLoadInitialDataAndUpdate() throws {
        
        for seedDataFile in Light.seedDataFiles ?? [] {
            stub(condition: isScheme("file") && pathEndsWith("\(seedDataFile).json")) { request in
                return HTTPStubsResponse(
                    fileAtPath: OHPathForFile("lightMockData.json", type(of: self))!,
                    statusCode: 200,
                    headers: ["Content-Type":"application/json"]
                )
            }
        }
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[Light.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[Light.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(Light.self)
            XCTAssertEqual(count, 2)
            return true
        }
        
        MSI.shared.loadInitialData(type: Light.decodableRoot, dataType: Light.self)
        
        waitForExpectations(timeout: 10, handler: nil)
        
        stub(condition: isScheme("https") && pathEndsWith("/publications/ngalol/lights-buoys") && !containsQueryParams(["volume": "110"])) { request in
            let jsonObject = [
                "ngalol": [
                ]
            ]
            return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
        }
        
        stub(condition: isScheme("https") && pathEndsWith("/publications/ngalol/lights-buoys") && containsQueryParams(["volume": "110", "minNoticeNumber":"201508"])) { request in
            let jsonObject = [
                "ngalol": [
                    [
                        "volumeNumber": "PUB 110",
                        "aidType": "Lighted Aids",
                        "geopoliticalHeading": "GREENLAND",
                        "regionHeading": "ANGMAGSSALIK:",
                        "subregionHeading": nil,
                        "localHeading": nil,
                        "precedingNote": nil,
                        "featureNumber": "9",
                        "name": "-Outer2.",
                        "position": "65°35'32.1\"N \n37°34'08.9\"W",
                        "charNo": 1,
                        "characteristic": "Fl.W.\nperiod 5s \nfl. 1.0s, ec. 4.0s \n",
                        "heightFeetMeters": "36\n11",
                        "range": "7",
                        "structure": "Yellow pedestal, red band; 7.\n",
                        "remarks": nil,
                        "postNote": nil,
                        "noticeNumber": 201507,
                        "removeFromList": "N",
                        "deleteFlag": "Y",
                        "noticeWeek": "07",
                        "noticeYear": "2022"
                    ],
                    [
                        "volumeNumber": "PUB 110",
                        "aidType": "Lighted Aids",
                        "geopoliticalHeading": "GREENLAND",
                        "regionHeading": nil,
                        "subregionHeading": nil,
                        "localHeading": nil,
                        "precedingNote": nil,
                        "featureNumber": "6",
                        "name": "Kulusuk, NW Coast, RACON.",
                        "position": "65°33'53.89\"N \n37°12'25.7\"W",
                        "charNo": 1,
                        "characteristic": "T(- )\nperiod 60s \n",
                        "heightFeetMeters": nil,
                        "range": nil,
                        "structure": nil,
                        "remarks": "(3 & 10cm).\n",
                        "postNote": nil,
                        "noticeNumber": 201507,
                        "removeFromList": "N",
                        "deleteFlag": "Y",
                        "noticeWeek": "07",
                        "noticeYear": "2015"
                    ]
                ]
            ]
            return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
        }
        
        stub(condition: isScheme("https") && pathEndsWith("/publications/ngalol/lights-buoys") && containsQueryParams(["volume": "110"]) && !containsQueryParams(["minNoticeNumber":"201508"])) { request in
            let jsonObject = [
                "ngalol": [
                    [
                        "volumeNumber": "PUB 110",
                        "aidType": "Lighted Aids",
                        "geopoliticalHeading": "GREENLAND",
                        "regionHeading": "ANGMAGSSALIK:",
                        "subregionHeading": nil,
                        "localHeading": nil,
                        "precedingNote": nil,
                        "featureNumber": "9",
                        "name": "-Outer2.",
                        "position": "65°35'32.1\"N \n37°34'08.9\"W",
                        "charNo": 1,
                        "characteristic": "Fl.W.\nperiod 5s \nfl. 1.0s, ec. 4.0s \n",
                        "heightFeetMeters": "36\n11",
                        "range": "7",
                        "structure": "Yellow pedestal, red band; 7.\n",
                        "remarks": nil,
                        "postNote": nil,
                        "noticeNumber": 201507,
                        "removeFromList": "N",
                        "deleteFlag": "Y",
                        "noticeWeek": "07",
                        "noticeYear": "2022"
                    ],
                    [
                        "volumeNumber": "PUB 110",
                        "aidType": "Lighted Aids",
                        "geopoliticalHeading": "GREENLAND",
                        "regionHeading": nil,
                        "subregionHeading": nil,
                        "localHeading": nil,
                        "precedingNote": nil,
                        "featureNumber": "6",
                        "name": "Kulusuk, NW Coast, RACON.",
                        "position": "65°33'53.89\"N \n37°12'25.7\"W",
                        "charNo": 1,
                        "characteristic": "T(- )\nperiod 60s \n",
                        "heightFeetMeters": nil,
                        "range": nil,
                        "structure": nil,
                        "remarks": "(3 & 10cm).\n",
                        "postNote": nil,
                        "noticeNumber": 201507,
                        "removeFromList": "N",
                        "deleteFlag": "Y",
                        "noticeWeek": "07",
                        "noticeYear": "2015"
                    ]
                ]
            ]
            return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
        }
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[Light.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[Light.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        let e5 = XCTNSPredicateExpectation(predicate: NSPredicate(block: { observedObject, change in
            if let count = try? self.persistentStore.countOfObjects(Light.self) {
                return count == 3
            }
            return false
        }), object: self.persistentStore.viewContext)
        
        
        MSI.shared.loadData(type: Light.decodableRoot, dataType: Light.self)
        wait(for: [e5], timeout: 10)

        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testRejectInvalidLightNoFeatureNumber() throws {
        for seedDataFile in Light.seedDataFiles ?? [] {
            stub(condition: isScheme("file") && pathEndsWith("\(seedDataFile).json")) { request in
                let jsonObject = [
                    "ngalol": [
                        [
                            "volumeNumber": "PUB 110",
                            "aidType": "Lighted Aids",
                            "geopoliticalHeading": "GREENLAND",
                            "regionHeading": "ANGMAGSSALIK:",
                            "subregionHeading": nil,
                            "localHeading": nil,
                            "precedingNote": nil,
                            "featureNumber": nil,
                            "name": "-Outer.",
                            "position": "65°35'32.1\"N \n37°34'08.9\"W",
                            "charNo": 1,
                            "characteristic": "Fl.W.\nperiod 5s \nfl. 1.0s, ec. 4.0s \n",
                            "heightFeetMeters": "36\n11",
                            "range": "7",
                            "structure": "Yellow pedestal, red band; 7.\n",
                            "remarks": nil,
                            "postNote": nil,
                            "noticeNumber": 201507,
                            "removeFromList": "N",
                            "deleteFlag": "Y",
                            "noticeWeek": "07",
                            "noticeYear": "2015"
                        ],
                        [
                            "volumeNumber": "PUB 110",
                            "aidType": "Lighted Aids",
                            "geopoliticalHeading": "GREENLAND",
                            "regionHeading": nil,
                            "subregionHeading": nil,
                            "localHeading": nil,
                            "precedingNote": nil,
                            "featureNumber": "6",
                            "name": "Kulusuk, NW Coast, RACON.",
                            "position": "65°33'53.89\"N \n37°12'25.7\"W",
                            "charNo": 1,
                            "characteristic": "T(- )\nperiod 60s \n",
                            "heightFeetMeters": nil,
                            "range": nil,
                            "structure": nil,
                            "remarks": "(3 & 10cm).\n",
                            "postNote": nil,
                            "noticeNumber": 201507,
                            "removeFromList": "N",
                            "deleteFlag": "Y",
                            "noticeWeek": "07",
                            "noticeYear": "2015"
                        ]
                    ]
                ]
                return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
            }
        }
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[Light.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[Light.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(Light.self)
            XCTAssertEqual(count, 1)
            return true
        }
        let queue = DispatchQueue(label: "mil.nga.msi.Marlin.api", qos: .background)
        queue.async( execute:{
            MSI.shared.loadInitialData(type: Light.decodableRoot, dataType: Light.self)
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testRejectInvalidLightNoVolumeNumber() throws {
        for seedDataFile in Light.seedDataFiles ?? [] {
            stub(condition: isScheme("file") && pathEndsWith("\(seedDataFile).json")) { request in
                let jsonObject = [
                    "ngalol": [
                        [
                            "volumeNumber": nil,
                            "aidType": "Lighted Aids",
                            "geopoliticalHeading": "GREENLAND",
                            "regionHeading": "ANGMAGSSALIK:",
                            "subregionHeading": nil,
                            "localHeading": nil,
                            "precedingNote": nil,
                            "featureNumber": "4\nL5000",
                            "name": "-Outer.",
                            "position": "65°35'32.1\"N \n37°34'08.9\"W",
                            "charNo": 1,
                            "characteristic": "Fl.W.\nperiod 5s \nfl. 1.0s, ec. 4.0s \n",
                            "heightFeetMeters": "36\n11",
                            "range": "7",
                            "structure": "Yellow pedestal, red band; 7.\n",
                            "remarks": nil,
                            "postNote": nil,
                            "noticeNumber": 201507,
                            "removeFromList": "N",
                            "deleteFlag": "Y",
                            "noticeWeek": "07",
                            "noticeYear": "2015"
                        ],
                        [
                            "volumeNumber": "PUB 110",
                            "aidType": "Lighted Aids",
                            "geopoliticalHeading": "GREENLAND",
                            "regionHeading": nil,
                            "subregionHeading": nil,
                            "localHeading": nil,
                            "precedingNote": nil,
                            "featureNumber": "6",
                            "name": "Kulusuk, NW Coast, RACON.",
                            "position": "65°33'53.89\"N \n37°12'25.7\"W",
                            "charNo": 1,
                            "characteristic": "T(- )\nperiod 60s \n",
                            "heightFeetMeters": nil,
                            "range": nil,
                            "structure": nil,
                            "remarks": "(3 & 10cm).\n",
                            "postNote": nil,
                            "noticeNumber": 201507,
                            "removeFromList": "N",
                            "deleteFlag": "Y",
                            "noticeWeek": "07",
                            "noticeYear": "2015"
                        ]
                    ]
                ]
                return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
            }
        }
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[Light.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[Light.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(Light.self)
            XCTAssertEqual(count, 1)
            return true
        }
        
        MSI.shared.loadInitialData(type: Light.decodableRoot, dataType: Light.self)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testRejectInvalidLightNoPosition() throws {
        for seedDataFile in Light.seedDataFiles ?? [] {
            stub(condition: isScheme("file") && pathEndsWith("\(seedDataFile).json")) { request in
                let jsonObject = [
                    "ngalol": [
                        [
                            "volumeNumber": "PUB 110",
                            "aidType": "Lighted Aids",
                            "geopoliticalHeading": "GREENLAND",
                            "regionHeading": "ANGMAGSSALIK:",
                            "subregionHeading": nil,
                            "localHeading": nil,
                            "precedingNote": nil,
                            "featureNumber": "4\nL5000",
                            "name": "-Outer.",
                            "position": nil,
                            "charNo": 1,
                            "characteristic": "Fl.W.\nperiod 5s \nfl. 1.0s, ec. 4.0s \n",
                            "heightFeetMeters": "36\n11",
                            "range": "7",
                            "structure": "Yellow pedestal, red band; 7.\n",
                            "remarks": nil,
                            "postNote": nil,
                            "noticeNumber": 201507,
                            "removeFromList": "N",
                            "deleteFlag": "Y",
                            "noticeWeek": "07",
                            "noticeYear": "2015"
                        ],
                        [
                            "volumeNumber": "PUB 110",
                            "aidType": "Lighted Aids",
                            "geopoliticalHeading": "GREENLAND",
                            "regionHeading": nil,
                            "subregionHeading": nil,
                            "localHeading": nil,
                            "precedingNote": nil,
                            "featureNumber": "6",
                            "name": "Kulusuk, NW Coast, RACON.",
                            "position": "65°33'53.89\"N \n37°12'25.7\"W",
                            "charNo": 1,
                            "characteristic": "T(- )\nperiod 60s \n",
                            "heightFeetMeters": nil,
                            "range": nil,
                            "structure": nil,
                            "remarks": "(3 & 10cm).\n",
                            "postNote": nil,
                            "noticeNumber": 201507,
                            "removeFromList": "N",
                            "deleteFlag": "Y",
                            "noticeWeek": "07",
                            "noticeYear": "2015"
                        ]
                    ]
                ]
                return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
            }
        }
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[Light.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[Light.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(Light.self)
            XCTAssertEqual(count, 1)
            return true
        }
        
        MSI.shared.loadInitialData(type: Light.decodableRoot, dataType: Light.self)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testPostProcess() throws {
        for seedDataFile in Light.seedDataFiles ?? [] {
            stub(condition: isScheme("file") && pathEndsWith("\(seedDataFile).json")) { request in
                let jsonObject = [
                    "ngalol": [
                        [
                            "volumeNumber": "PUB 110",
                            "aidType": "Lighted Aids",
                            "geopoliticalHeading": "GREENLAND",
                            "regionHeading": "ANGMAGSSALIK:",
                            "subregionHeading": nil,
                            "localHeading": nil,
                            "precedingNote": nil,
                            "featureNumber": "1",
                            "name": "-Outer.",
                            "position": "65°35'32.1\"N \n37°34'08.9\"W",
                            "charNo": 1,
                            "characteristic": "Fl.W.\nperiod 5s \nfl. 1.0s, ec. 4.0s \n",
                            "heightFeetMeters": "36\n11",
                            "range": "W. 14 ; R. 11 ; G. 11",
                            "structure": "Yellow pedestal, red band; 7.\n",
                            "remarks": nil,
                            "postNote": nil,
                            "noticeNumber": 201507,
                            "removeFromList": "N",
                            "deleteFlag": "Y",
                            "noticeWeek": "07",
                            "noticeYear": "2015"
                        ]
                    ]
                ]
                return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
            }
        }
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[Light.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[Light.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(Light.self)
            XCTAssertEqual(count, 1)
            return true
        }
        let queue = DispatchQueue(label: "mil.nga.msi.Marlin.api", qos: .background)
        queue.async( execute:{
            MSI.shared.loadInitialData(type: Light.decodableRoot, dataType: Light.self)
        })
        
        waitForExpectations(timeout: 10, handler: nil)
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(Light.self)
            if count == 1 {
                XCTAssertEqual(count, 1)
                return true
            } else {
                return false
            }
        }
        waitForExpectations(timeout: 10, handler: nil)
        let light = try? self.persistentStore.fetchFirst(Light.self, sortBy: [Light.defaultSort[0].toNSSortDescriptor()], predicate: NSPredicate(value: true))
        let lightRanges = try XCTUnwrap(try XCTUnwrap(light?.lightRange).allObjects as? [LightRange])
        XCTAssertEqual(lightRanges.count, 3)
        for range in lightRanges {
            XCTAssertTrue(range.color == "W" || range.color == "R" || range.color == "G")
            if range.color == "W" {
                XCTAssertEqual(range.range, 14)
            } else if range.color == "R" {
                XCTAssertEqual(range.range, 11)
            } else if range.color == "G" {
                XCTAssertEqual(range.range, 11)
            }
            
        }
    }
    
    func testDataRequest() {

        let newItem = Light(context: persistentStore.viewContext)
        newItem.volumeNumber = "PUB 110"
        newItem.aidType = "Lighted Aids"
        newItem.geopoliticalHeading = "GREENLAND"
        newItem.regionHeading = nil
        newItem.subregionHeading = nil
        newItem.localHeading = nil
        newItem.precedingNote = nil
        newItem.featureNumber = "6"
        newItem.name = "Kulusuk, NW Coast, RACON."
        newItem.position = "65°33'53.89\"N \n37°12'25.7\"W"
        newItem.characteristicNumber = 1
        newItem.characteristic = "T(- )\nperiod 60s \n"
        newItem.range = nil
        newItem.structure = nil
        newItem.remarks = "(3 & 10cm).\n"
        newItem.postNote = nil
        newItem.noticeNumber = 201507
        newItem.removeFromList = "N"
        newItem.deleteFlag = "Y"
        newItem.noticeWeek = "07"
        newItem.noticeYear = "2015"
        
        try? persistentStore.viewContext.save()

        let requests = Light.dataRequest()
        XCTAssertEqual(requests.count, Light.lightVolumes.count)
        for request in requests {
            XCTAssertEqual(request.method, .get)
            let parameters = request.parameters
            XCTAssertGreaterThanOrEqual(try! XCTUnwrap(parameters?.count), 3)
            XCTAssertEqual(parameters?["output"] as? String, "json")
            XCTAssertFalse(try! XCTUnwrap(parameters?["includeRemovals"] as? Bool))
            
            let volumeNumber = try! XCTUnwrap(parameters?["volume"] as? String)
            if volumeNumber == "110" {
                XCTAssertEqual(parameters?.count, 5)
                let calendar = Calendar.current
                let week = calendar.component(.weekOfYear, from: Date())
                let year = calendar.component(.year, from: Date())
                
                XCTAssertEqual(parameters?["minNoticeNumber"] as? String, "201508")
                XCTAssertEqual(parameters?["maxNoticeNumber"] as? String, "\(year)\(String(format: "%02d", week + 1))")
            } else {
                XCTAssertEqual(parameters?.count, 3)
            }
        }
    }

    func testShouldSync() {
        UserDefaults.standard.setValue(false, forKey: "\(Light.key)DataSourceEnabled")
        XCTAssertFalse(Light.shouldSync())
        UserDefaults.standard.setValue(true, forKey: "\(Light.key)DataSourceEnabled")
        UserDefaults.standard.setValue(Date().timeIntervalSince1970 - (60 * 60 * 24 * 7) - 10, forKey: "\(Light.key)LastSyncTime")
        XCTAssertTrue(Light.shouldSync())
        UserDefaults.standard.setValue(Date().timeIntervalSince1970 - (60 * 60 * 24 * 7) + (60 * 10), forKey: "\(Light.key)LastSyncTime")
        XCTAssertFalse(Light.shouldSync())
    }
    
    func testDescription() {
        let newItem = Light(context: persistentStore.viewContext)
        newItem.volumeNumber = "PUB 110"
        newItem.aidType = "Lighted Aids"
        newItem.geopoliticalHeading = "GREENLAND"
        newItem.regionHeading = nil
        newItem.subregionHeading = nil
        newItem.localHeading = nil
        newItem.precedingNote = nil
        newItem.featureNumber = "6"
        newItem.name = "Kulusuk, NW Coast, RACON."
        newItem.position = "65°33'53.89\"N \n37°12'25.7\"W"
        newItem.characteristicNumber = 1
        newItem.characteristic = "T(- )\nperiod 60s \n"
        newItem.range = nil
        newItem.structure = nil
        newItem.remarks = "(3 & 10cm).\n"
        newItem.postNote = nil
        newItem.noticeNumber = 201507
        newItem.removeFromList = "N"
        newItem.deleteFlag = "Y"
        newItem.noticeWeek = "07"
        newItem.noticeYear = "2015"
        
        let description = "LIGHT\n\n" +
        "aidType Lighted Aids\n" +
        "characteristic T(- )\n" +
        "period 60s \n\n" +
        "characteristicNumber 1\n" +
        "deleteFlag Y\n" +
        "featureNumber 6\n" +
        "geopoliticalHeading GREENLAND\n" +
        "heightFeet 0.0\n" +
        "heightMeters 0.0\n" +
        "internationalFeature \n" +
        "localHeading \n" +
        "name Kulusuk, NW Coast, RACON.\n" +
        "noticeNumber 201507\n" +
        "noticeWeek 07\n" +
        "noticeYear 2015\n" +
        "position 65°33'53.89\"N \n" +
        "37°12'25.7\"W\n" +
        "postNote \n" +
        "precedingNote \n" +
        "range \n" +
        "regionHeading \n" +
        "remarks (3 & 10cm).\n\n" +
        "removeFromList N\n" +
        "structure \n" +
        "subregionHeading \n" +
        "volumeNumber PUB 110"
        
        XCTAssertEqual(description, newItem.description)
    }
    
    func testMapImage() {
        let newItem = Light(context: persistentStore.viewContext)
        newItem.volumeNumber = "PUB 110"
        newItem.aidType = "Lighted Aids"
        newItem.geopoliticalHeading = "GREENLAND"
        newItem.regionHeading = nil
        newItem.subregionHeading = nil
        newItem.localHeading = nil
        newItem.precedingNote = nil
        newItem.featureNumber = "6"
        newItem.name = "Kulusuk, NW Coast, RACON."
        newItem.position = "65°33'53.89\"N \n37°12'25.7\"W"
        newItem.characteristicNumber = 1
        newItem.characteristic = "T(- )\nperiod 60s \n"
        newItem.range = nil
        newItem.structure = nil
        newItem.remarks = "(3 & 10cm).\n"
        newItem.postNote = nil
        newItem.noticeNumber = 201507
        newItem.removeFromList = "N"
        newItem.deleteFlag = "Y"
        newItem.noticeWeek = "07"
        newItem.noticeYear = "2015"
        
        var circleSize: CGSize = .zero
        var imageSize: CGSize = .zero
        
        for i in 1...18 {
            let images = newItem.mapImage(marker: false, zoomLevel: i, tileBounds3857: MapBoundingBox(swCorner: (x:-10, y:-10), neCorner: (x: 10, y:10)), context: nil)
            XCTAssertNotNil(images)
            XCTAssertEqual(images.count, 1)
            XCTAssertGreaterThan(images[0].size.height, circleSize.height)
            XCTAssertGreaterThan(images[0].size.width, circleSize.width)
            circleSize = images[0].size
            XCTAssertGreaterThan(images[0].size.height, imageSize.height)
            XCTAssertGreaterThan(images[0].size.width, imageSize.width)
            imageSize = images[0].size
        }
    }
}
