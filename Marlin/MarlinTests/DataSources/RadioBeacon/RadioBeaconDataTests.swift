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
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults()
        UserDefaults.standard.initialDataLoaded = false
        UserDefaults.standard.clearLastSyncTimeSeconds(DataSources.asam)
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

        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.radioBeacon.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.radioBeacon.key] {
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

        let bundle = MockBundle()
        bundle.mockPath = "radioBeaconMockData.json"

        var localDataSource = RadioBeaconCoreDataDataSource()
        let operation = RadioBeaconInitialDataLoadOperation(localDataSource: localDataSource, bundle: bundle)
        operation.start()

        waitForExpectations(timeout: 10, handler: nil)

        let rb = localDataSource.getNewestRadioBeacon()
        XCTAssertEqual(rb!.featureNumber, 10)
        XCTAssertEqual(String(format: "%.5f", rb!.latitude), "70.48666")
        XCTAssertEqual(String(format: "%.5f", rb!.longitude), "-21.97222")
    }
    
    func testRejectInvalidRadioBeaconNoFeatureNumber() throws {
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
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.radioBeacon.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.radioBeacon.key] {
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
        
        let bundle = MockBundle()
        bundle.tempFileContents = jsonObject

        let operation = RadioBeaconInitialDataLoadOperation(localDataSource: RadioBeaconCoreDataDataSource(), bundle: bundle)
        operation.start()

        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testRejectInvalidRadioBeaconNoVolumeNumber() throws {
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
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.radioBeacon.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.radioBeacon.key] {
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
        
        let bundle = MockBundle()
        bundle.tempFileContents = jsonObject

        let operation = RadioBeaconInitialDataLoadOperation(localDataSource: RadioBeaconCoreDataDataSource(), bundle: bundle)
        operation.start()

        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testRejectInvalidRadioBeaconNoPosition() throws {
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

        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.radioBeacon.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.radioBeacon.key] {
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
        let bundle = MockBundle()
        bundle.tempFileContents = jsonObject

        let operation = RadioBeaconInitialDataLoadOperation(localDataSource: RadioBeaconCoreDataDataSource(), bundle: bundle)
        operation.start()

        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testDataRequest() {
        let request = RadioBeaconService.getRadioBeacons(noticeYear: nil, noticeWeek: nil)
        XCTAssertEqual(request.method, .get)
        let parameters = request.parameters
        XCTAssertEqual(parameters?.count, 2)
        XCTAssertEqual(parameters?["includeRemovals"] as? Bool, false)
        XCTAssertEqual(parameters?["output"] as? String, "json")

        let request2 = RadioBeaconService.getRadioBeacons(noticeYear: "2022", noticeWeek: "05")
        XCTAssertEqual(request2.method, .get)
        let parameters2 = request2.parameters
        XCTAssertEqual(parameters2?.count, 4)
        XCTAssertEqual(parameters2?["includeRemovals"] as? Bool, false)
        XCTAssertEqual(parameters2?["output"] as? String, "json")
        XCTAssertEqual(parameters2?["minNoticeNumber"] as? String, "202205")
        let calendar = Calendar.current
        let week = calendar.component(.weekOfYear, from: Date())
        let year = calendar.component(.year, from: Date())
        XCTAssertEqual(parameters2?["maxNoticeNumber"] as? String, "\(year)\(String(format: "%02d", week + 1))")
    }

    func testShouldSync() {
        UserDefaults.standard.setValue(false, forKey: "\(DataSources.radioBeacon.key)DataSourceEnabled")
        XCTAssertFalse(DataSources.radioBeacon.shouldSync())
        UserDefaults.standard.setValue(true, forKey: "\(DataSources.radioBeacon.key)DataSourceEnabled")
        UserDefaults.standard.setValue(Date().timeIntervalSince1970 - (60 * 60 * 24 * 7) - 10, forKey: "\(DataSources.radioBeacon.key)LastSyncTime")
        XCTAssertTrue(DataSources.radioBeacon.shouldSync())
        UserDefaults.standard.setValue(Date().timeIntervalSince1970 - (60 * 60 * 24 * 7) + (60 * 10), forKey: "\(DataSources.radioBeacon.key)LastSyncTime")
        XCTAssertFalse(DataSources.radioBeacon.shouldSync())
    }
    
    func testDescription() {
        var newItem = RadioBeaconModel()
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
        newItem.latitude = 0.0
        newItem.longitude = 0.0

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
        var newItem = RadioBeaconModel()
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
        newItem.latitude = 0.0
        newItem.longitude = 0.0

        var circleSize: CGSize = .zero
        var imageSize: CGSize = .zero
        
        for i in 1...18 {
            let image = RadioBeaconImage(radioBeacon: newItem)
            let images = image.image(context: nil, zoom: i, tileBounds: MapBoundingBox(swCorner: (x:-10, y:-10), neCorner: (x: 10, y:10)), tileSize: 512.0)
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
