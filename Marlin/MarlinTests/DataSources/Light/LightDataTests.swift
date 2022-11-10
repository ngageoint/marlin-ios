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
    var persistentStore: PersistentStore = PersistenceController.memory
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
                completion(nil)
            }
            .store(in: &cancellable)
        persistentStore = PersistenceController.memory
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
        
        MSI.shared.loadInitialData(type: Light.decodableRoot, dataType: Light.self)
        
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
}
