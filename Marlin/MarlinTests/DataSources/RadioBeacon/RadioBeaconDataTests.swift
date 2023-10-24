//
//  RadioBeaconDataTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 11/10/22.
//

import XCTest
import Combine
import OHHTTPStubs
import CoreData

@testable import Marlin

final class RadioBeaconDataTests: XCTestCase {

    var cancellable = Set<AnyCancellable>()
    var persistentStore: PersistentStore = PersistenceController.shared
    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
        .receive(on: RunLoop.main)
    
    override func setUp(completion: @escaping (Error?) -> Void) {
        for item in DataSourceList().allTabs {
            UserDefaults.standard.initialDataLoaded = false
            UserDefaults.standard.clearLastSyncTimeSeconds(item.dataSource.definition)
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
        
        for seedDataFile in RadioBeacon.seedDataFiles ?? [] {
            stub(condition: isScheme("file") && pathEndsWith("\(seedDataFile).json")) { request in
                return HTTPStubsResponse(
                    fileAtPath: OHPathForFile("radioBeaconMockData.json", type(of: self))!,
                    statusCode: 200,
                    headers: ["Content-Type":"application/json"]
                )
            }
        }
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[RadioBeacon.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[RadioBeacon.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(RadioBeacon.self)
            XCTAssertEqual(count, 2)
            return true
        }
        
        MSI.shared.loadInitialData(type: RadioBeacon.decodableRoot, dataType: RadioBeacon.self)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testRejectInvalidRadioBeaconNoFeatureNumber() throws {
        for seedDataFile in RadioBeacon.seedDataFiles ?? [] {
            stub(condition: isScheme("file") && pathEndsWith("\(seedDataFile).json")) { request in
                let jsonObject = [
                    "ngalol": [
                        [
                            "volumeNumber": "PUB 110",
                            "aidType": "Radiobeacons",
                            "geopoliticalHeading": "GREENLAND",
                            "regionHeading": nil,
                            "precedingNote": nil,
                            "featureNumber": nil,
                            "name": "Ittoqqortoormit, Scoresbysund",
                            "position": "70°29'11.99\"N \n21°58'20\"W",
                            "characteristic": "SC\n(• • •  - • - • ).\n",
                            "range": "200",
                            "sequenceText": nil,
                            "frequency": "343\nNON, A2A.",
                            "stationRemark": "Aeromarine.",
                            "postNote": nil,
                            "noticeNumber": 199706,
                            "removeFromList": "N",
                            "deleteFlag": "N",
                            "noticeWeek": "06",
                            "noticeYear": "1997"
                        ],
                        [
                            "volumeNumber": "PUB 110",
                            "aidType": "Radiobeacons",
                            "geopoliticalHeading": "GREENLAND",
                            "regionHeading": nil,
                            "precedingNote": nil,
                            "featureNumber": 20,
                            "name": "Kulusuk",
                            "position": "65°31'59.99\"N \n37°10'00\"W",
                            "characteristic": "KK\n(- • -   - • - ).\n",
                            "range": "50",
                            "sequenceText": nil,
                            "frequency": "283\nNON, A2A.",
                            "stationRemark": "Aeromarine.",
                            "postNote": nil,
                            "noticeNumber": 199706,
                            "removeFromList": "N",
                            "deleteFlag": "N",
                            "noticeWeek": "06",
                            "noticeYear": "1997"
                        ]
                    ]
                ]

                return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
            }
        }
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[RadioBeacon.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[RadioBeacon.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(RadioBeacon.self)
            XCTAssertEqual(count, 1)
            return true
        }
        
        MSI.shared.loadInitialData(type: RadioBeacon.decodableRoot, dataType: RadioBeacon.self)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testRejectInvalidRadioBeaconNoVolumeNumber() throws {
        for seedDataFile in RadioBeacon.seedDataFiles ?? [] {
            stub(condition: isScheme("file") && pathEndsWith("\(seedDataFile).json")) { request in
                let jsonObject = [
                    "ngalol": [
                        [
                            "volumeNumber": nil,
                            "aidType": "Radiobeacons",
                            "geopoliticalHeading": "GREENLAND",
                            "regionHeading": nil,
                            "precedingNote": nil,
                            "featureNumber": 10,
                            "name": "Ittoqqortoormit, Scoresbysund",
                            "position": "70°29'11.99\"N \n21°58'20\"W",
                            "characteristic": "SC\n(• • •  - • - • ).\n",
                            "range": "200",
                            "sequenceText": nil,
                            "frequency": "343\nNON, A2A.",
                            "stationRemark": "Aeromarine.",
                            "postNote": nil,
                            "noticeNumber": 199706,
                            "removeFromList": "N",
                            "deleteFlag": "N",
                            "noticeWeek": "06",
                            "noticeYear": "1997"
                        ],
                        [
                            "volumeNumber": "PUB 110",
                            "aidType": "Radiobeacons",
                            "geopoliticalHeading": "GREENLAND",
                            "regionHeading": nil,
                            "precedingNote": nil,
                            "featureNumber": 20,
                            "name": "Kulusuk",
                            "position": "65°31'59.99\"N \n37°10'00\"W",
                            "characteristic": "KK\n(- • -   - • - ).\n",
                            "range": "50",
                            "sequenceText": nil,
                            "frequency": "283\nNON, A2A.",
                            "stationRemark": "Aeromarine.",
                            "postNote": nil,
                            "noticeNumber": 199706,
                            "removeFromList": "N",
                            "deleteFlag": "N",
                            "noticeWeek": "06",
                            "noticeYear": "1997"
                        ]
                    ]
                ]
                return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
            }
        }
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[RadioBeacon.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[RadioBeacon.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(RadioBeacon.self)
            XCTAssertEqual(count, 1)
            return true
        }
        
        MSI.shared.loadInitialData(type: RadioBeacon.decodableRoot, dataType: RadioBeacon.self)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testRejectInvalidRadioBeaconNoPosition() throws {
        for seedDataFile in RadioBeacon.seedDataFiles ?? [] {
            stub(condition: isScheme("file") && pathEndsWith("\(seedDataFile).json")) { request in
                let jsonObject = [
                    "ngalol": [
                        [
                            "volumeNumber": "PUB 110",
                            "aidType": "Radiobeacons",
                            "geopoliticalHeading": "GREENLAND",
                            "regionHeading": nil,
                            "precedingNote": nil,
                            "featureNumber": 10,
                            "name": "Ittoqqortoormit, Scoresbysund",
                            "position": nil,
                            "characteristic": "SC\n(• • •  - • - • ).\n",
                            "range": "200",
                            "sequenceText": nil,
                            "frequency": "343\nNON, A2A.",
                            "stationRemark": "Aeromarine.",
                            "postNote": nil,
                            "noticeNumber": 199706,
                            "removeFromList": "N",
                            "deleteFlag": "N",
                            "noticeWeek": "06",
                            "noticeYear": "1997"
                        ],
                        [
                            "volumeNumber": "PUB 110",
                            "aidType": "Radiobeacons",
                            "geopoliticalHeading": "GREENLAND",
                            "regionHeading": nil,
                            "precedingNote": nil,
                            "featureNumber": 20,
                            "name": "Kulusuk",
                            "position": "65°31'59.99\"N \n37°10'00\"W",
                            "characteristic": "KK\n(- • -   - • - ).\n",
                            "range": "50",
                            "sequenceText": nil,
                            "frequency": "283\nNON, A2A.",
                            "stationRemark": "Aeromarine.",
                            "postNote": nil,
                            "noticeNumber": 199706,
                            "removeFromList": "N",
                            "deleteFlag": "N",
                            "noticeWeek": "06",
                            "noticeYear": "1997"
                        ]
                    ]
                ]
                return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
            }
        }
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[RadioBeacon.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[RadioBeacon.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(RadioBeacon.self)
            XCTAssertEqual(count, 1)
            return true
        }
        
        MSI.shared.loadInitialData(type: RadioBeacon.decodableRoot, dataType: RadioBeacon.self)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testDataRequest() {
        
        let newItem = RadioBeacon(context: persistentStore.viewContext)
        newItem.volumeNumber = "PUB 110"
        newItem.aidType = "Radiobeacons"
        newItem.geopoliticalHeading = "GREENLAND"
        newItem.regionHeading = nil
        newItem.precedingNote = nil
        newItem.featureNumber = 20
        newItem.name = "Kulusuk"
        newItem.position = "65°31'59.99\"N \n37°10'00\"W"
        newItem.characteristic = "KK\n(- • -   - • - ).\n"
        newItem.range = 50
        newItem.sequenceText = nil
        newItem.frequency = "283\nNON, A2A."
        newItem.stationRemark = "Aeromarine."
        newItem.postNote = nil
        newItem.noticeNumber = 199706
        newItem.removeFromList = "N"
        newItem.deleteFlag = "N"
        newItem.noticeWeek = "06"
        newItem.noticeYear = "1997"
        
        try? persistentStore.viewContext.save()
        
        let requests = RadioBeacon.dataRequest()
        XCTAssertEqual(requests.count, 1)
        let request = requests[0]
        XCTAssertEqual(request.method, .get)
        let parameters = request.parameters
        XCTAssertEqual(parameters?.count, 4)
        XCTAssertEqual(parameters?["output"] as? String, "json")
        XCTAssertFalse(try! XCTUnwrap(parameters?["includeRemovals"] as? Bool))
        
        let calendar = Calendar.current
        let week = calendar.component(.weekOfYear, from: Date())
        let year = calendar.component(.year, from: Date())
        
        XCTAssertEqual(parameters?["minNoticeNumber"] as? String, "199707")
        XCTAssertEqual(parameters?["maxNoticeNumber"] as? String, "\(year)\(String(format: "%02d", week + 1))")
    }
    
    func testDataRequestWithoutRadioBeacons() {
        
        let requests = RadioBeacon.dataRequest()
        XCTAssertEqual(requests.count, 1)
        let request = requests[0]
        XCTAssertEqual(request.method, .get)
        let parameters = request.parameters
        XCTAssertEqual(parameters?.count, 2)
        XCTAssertEqual(parameters?["output"] as? String, "json")
        XCTAssertFalse(try! XCTUnwrap(parameters?["includeRemovals"] as? Bool))
    }
    
    func testShouldSync() {
        UserDefaults.standard.setValue(false, forKey: "\(RadioBeacon.key)DataSourceEnabled")
        XCTAssertFalse(RadioBeacon.shouldSync())
        UserDefaults.standard.setValue(true, forKey: "\(RadioBeacon.key)DataSourceEnabled")
        UserDefaults.standard.setValue(Date().timeIntervalSince1970 - (60 * 60 * 24 * 7) - 10, forKey: "\(RadioBeacon.key)LastSyncTime")
        XCTAssertTrue(RadioBeacon.shouldSync())
        UserDefaults.standard.setValue(Date().timeIntervalSince1970 - (60 * 60 * 24 * 7) + (60 * 10), forKey: "\(RadioBeacon.key)LastSyncTime")
        XCTAssertFalse(RadioBeacon.shouldSync())
    }
    
    func testDescription() {
        let newItem = RadioBeacon(context: persistentStore.viewContext)
        newItem.volumeNumber = "PUB 110"
        newItem.aidType = "Radiobeacons"
        newItem.geopoliticalHeading = "GREENLAND"
        newItem.regionHeading = nil
        newItem.precedingNote = nil
        newItem.featureNumber = 20
        newItem.name = "Kulusuk"
        newItem.position = "65°31'59.99\"N \n37°10'00\"W"
        newItem.characteristic = "KK\n(- • -   - • - ).\n"
        newItem.range = 50
        newItem.sequenceText = nil
        newItem.frequency = "283\nNON, A2A."
        newItem.stationRemark = "Aeromarine."
        newItem.postNote = nil
        newItem.noticeNumber = 199706
        newItem.removeFromList = "N"
        newItem.deleteFlag = "N"
        newItem.noticeWeek = "06"
        newItem.noticeYear = "1997"
        
        let description = "RADIO BEACON\n\n" +
        "aidType Radiobeacons\n" +
        "characteristic KK\n" +
        "(- • -   - • - ).\n\n" +
        "deleteFlag N\n" +
        "featureNumber 20\n" +
        "geopoliticalHeading GREENLAND\n" +
        "latitude 0.0\n" +
        "longitude 0.0\n" +
        "name Kulusuk\n" +
        "noticeNumber 199706\n" +
        "noticeWeek 06\n" +
        "noticeYear 1997\n" +
        "position 65°31'59.99\"N \n" +
        "37°10'00\"W\n" +
        "postNote \n" +
        "precedingNote \n" +
        "range 50\n" +
        "regionHeading \n" +
        "removeFromList N\n" +
        "sequenceText \n" +
        "stationRemark Aeromarine.\n" +
        "volumeNumber PUB 110"
        
        XCTAssertEqual(description, newItem.description)
    }
    
    func testMapImage() {
        let newItem = RadioBeacon(context: persistentStore.viewContext)
        newItem.volumeNumber = "PUB 110"
        newItem.aidType = "Radiobeacons"
        newItem.geopoliticalHeading = "GREENLAND"
        newItem.regionHeading = nil
        newItem.precedingNote = nil
        newItem.featureNumber = 20
        newItem.name = "Kulusuk"
        newItem.position = "65°31'59.99\"N \n37°10'00\"W"
        newItem.characteristic = "KK\n(- • -   - • - ).\n"
        newItem.range = 50
        newItem.sequenceText = nil
        newItem.frequency = "283\nNON, A2A."
        newItem.stationRemark = "Aeromarine."
        newItem.postNote = nil
        newItem.noticeNumber = 199706
        newItem.removeFromList = "N"
        newItem.deleteFlag = "N"
        newItem.noticeWeek = "06"
        newItem.noticeYear = "1997"
        
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
