//
//  DifferentialGPSStationDataTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 11/9/22.
//

import XCTest
import Combine
import OHHTTPStubs
import CoreData

@testable import Marlin

final class DifferentialGPSStationDataTests: XCTestCase {

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
        
        for seedDataFile in DifferentialGPSStation.seedDataFiles ?? [] {
            stub(condition: isScheme("file") && pathEndsWith("\(seedDataFile).json")) { request in
                return HTTPStubsResponse(
                    fileAtPath: OHPathForFile("dgpsMockData.json", type(of: self))!,
                    statusCode: 200,
                    headers: ["Content-Type":"application/json"]
                )
            }
        }
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DifferentialGPSStation.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DifferentialGPSStation.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(DifferentialGPSStation.self)
            XCTAssertEqual(count, 2)
            return true
        }
        
        MSI.shared.loadInitialData(type: DifferentialGPSStation.decodableRoot, dataType: DifferentialGPSStation.self)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testRejectInvalidDifferentialGPSStationNoFeatureNumber() throws {
        for seedDataFile in DifferentialGPSStation.seedDataFiles ?? [] {
            stub(condition: isScheme("file") && pathEndsWith("\(seedDataFile).json")) { request in
                let jsonObject = [
                    "ngalol": [
                        [
                            "volumeNumber": "PUB 112",
                            "aidType": "Differential GPS Stations",
                            "geopoliticalHeading": "KOREA",
                            "regionHeading": nil,
                            "precedingNote": nil,
                            "featureNumber": nil,
                            "name": "Chojin Dan Lt",
                            "position": "38°33'09\"N \n128°23'53.99\"E",
                            "stationID": "T670\nR740\nR741\n",
                            "range": 100,
                            "frequency": 292,
                            "transferRate": 200,
                            "remarks": "Message types: 3, 5, 7, 9, 16.",
                            "postNote": nil,
                            "noticeNumber": 201134,
                            "removeFromList": "N",
                            "deleteFlag": "N",
                            "noticeWeek": "34",
                            "noticeYear": "2011"
                        ],
                        [
                            "volumeNumber": "PUB 112",
                            "aidType": "Differential GPS Stations",
                            "geopoliticalHeading": "KOREA",
                            "regionHeading": nil,
                            "precedingNote": nil,
                            "featureNumber": 7,
                            "name": "Chumunjin Dan",
                            "position": "37°53'52.21\"N \n128°50'01.79\"E",
                            "stationID": "T663\nR726\nR727\n",
                            "range": 100,
                            "frequency": 295,
                            "transferRate": 200,
                            "remarks": "Message types: 3, 5, 7, 9, 16.",
                            "postNote": nil,
                            "noticeNumber": 201134,
                            "removeFromList": "N",
                            "deleteFlag": "N",
                            "noticeWeek": "34",
                            "noticeYear": "2011"
                        ]
                    ]
                ]
                return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
            }
        }
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DifferentialGPSStation.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DifferentialGPSStation.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(DifferentialGPSStation.self)
            XCTAssertEqual(count, 1)
            return true
        }
        
        MSI.shared.loadInitialData(type: DifferentialGPSStation.decodableRoot, dataType: DifferentialGPSStation.self)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testRejectInvalidDifferentialGPSStationNoVolumeNumber() throws {
        for seedDataFile in DifferentialGPSStation.seedDataFiles ?? [] {
            stub(condition: isScheme("file") && pathEndsWith("\(seedDataFile).json")) { request in
                let jsonObject = [
                    "ngalol": [
                        [
                            "volumeNumber": nil,
                            "aidType": "Differential GPS Stations",
                            "geopoliticalHeading": "KOREA",
                            "regionHeading": nil,
                            "precedingNote": nil,
                            "featureNumber": 6,
                            "name": "Chojin Dan Lt",
                            "position": "38°33'09\"N \n128°23'53.99\"E",
                            "stationID": "T670\nR740\nR741\n",
                            "range": 100,
                            "frequency": 292,
                            "transferRate": 200,
                            "remarks": "Message types: 3, 5, 7, 9, 16.",
                            "postNote": nil,
                            "noticeNumber": 201134,
                            "removeFromList": "N",
                            "deleteFlag": "N",
                            "noticeWeek": "34",
                            "noticeYear": "2011"
                        ],
                        [
                            "volumeNumber": "PUB 112",
                            "aidType": "Differential GPS Stations",
                            "geopoliticalHeading": "KOREA",
                            "regionHeading": nil,
                            "precedingNote": nil,
                            "featureNumber": 7,
                            "name": "Chumunjin Dan",
                            "position": "37°53'52.21\"N \n128°50'01.79\"E",
                            "stationID": "T663\nR726\nR727\n",
                            "range": 100,
                            "frequency": 295,
                            "transferRate": 200,
                            "remarks": "Message types: 3, 5, 7, 9, 16.",
                            "postNote": nil,
                            "noticeNumber": 201134,
                            "removeFromList": "N",
                            "deleteFlag": "N",
                            "noticeWeek": "34",
                            "noticeYear": "2011"
                        ]
                    ]
                ]
                return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
            }
        }
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DifferentialGPSStation.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DifferentialGPSStation.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(DifferentialGPSStation.self)
            XCTAssertEqual(count, 1)
            return true
        }
        
        MSI.shared.loadInitialData(type: DifferentialGPSStation.decodableRoot, dataType: DifferentialGPSStation.self)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testRejectInvalidDifferentialGPSStationNoPosition() throws {
        for seedDataFile in DifferentialGPSStation.seedDataFiles ?? [] {
            stub(condition: isScheme("file") && pathEndsWith("\(seedDataFile).json")) { request in
                let jsonObject = [
                    "ngalol": [
                        [
                            "volumeNumber": "PUB 112",
                            "aidType": "Differential GPS Stations",
                            "geopoliticalHeading": "KOREA",
                            "regionHeading": nil,
                            "precedingNote": nil,
                            "featureNumber": 6,
                            "name": "Chojin Dan Lt",
                            "position": nil,
                            "stationID": "T670\nR740\nR741\n",
                            "range": 100,
                            "frequency": 292,
                            "transferRate": 200,
                            "remarks": "Message types: 3, 5, 7, 9, 16.",
                            "postNote": nil,
                            "noticeNumber": 201134,
                            "removeFromList": "N",
                            "deleteFlag": "N",
                            "noticeWeek": "34",
                            "noticeYear": "2011"
                        ],
                        [
                            "volumeNumber": "PUB 112",
                            "aidType": "Differential GPS Stations",
                            "geopoliticalHeading": "KOREA",
                            "regionHeading": nil,
                            "precedingNote": nil,
                            "featureNumber": 7,
                            "name": "Chumunjin Dan",
                            "position": "37°53'52.21\"N \n128°50'01.79\"E",
                            "stationID": "T663\nR726\nR727\n",
                            "range": 100,
                            "frequency": 295,
                            "transferRate": 200,
                            "remarks": "Message types: 3, 5, 7, 9, 16.",
                            "postNote": nil,
                            "noticeNumber": 201134,
                            "removeFromList": "N",
                            "deleteFlag": "N",
                            "noticeWeek": "34",
                            "noticeYear": "2011"
                        ]
                    ]
                ]
                return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
            }
        }
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DifferentialGPSStation.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DifferentialGPSStation.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(DifferentialGPSStation.self)
            XCTAssertEqual(count, 1)
            return true
        }
        
        MSI.shared.loadInitialData(type: DifferentialGPSStation.decodableRoot, dataType: DifferentialGPSStation.self)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testDataRequest() {
        
        let newItem = DifferentialGPSStation(context: persistentStore.viewContext)
        newItem.volumeNumber = "PUB 112"
        newItem.aidType = "Differential GPS Stations"
        newItem.geopoliticalHeading = "KOREA"
        newItem.regionHeading = nil
        newItem.precedingNote = nil
        newItem.featureNumber = 7
        newItem.name = "Chumunjin Dan"
        newItem.position = "37°53'52.21\"N \n128°50'01.79\"E"
        newItem.stationID = "T663\nR726\nR727\n"
        newItem.range = 100
        newItem.frequency = 295
        newItem.transferRate = 200
        newItem.remarks = "Message types: 3, 5, 7, 9, 16."
        newItem.postNote = nil
        newItem.noticeNumber = 201134
        newItem.removeFromList = "N"
        newItem.deleteFlag = "N"
        newItem.noticeWeek = "34"
        newItem.noticeYear = "2011"
        try? persistentStore.viewContext.save()
        
        let requests = DifferentialGPSStation.dataRequest()
        XCTAssertEqual(requests.count, 1)
        let request = requests[0]
        XCTAssertEqual(request.method, .get)
        let parameters = request.parameters
        XCTAssertEqual(parameters?.count, 4)
        XCTAssertEqual(parameters?["minNoticeNumber"] as? String, "201135")
        let calendar = Calendar.current
        let week = calendar.component(.weekOfYear, from: Date())
        let year = calendar.component(.year, from: Date())
        XCTAssertEqual(parameters?["maxNoticeNumber"] as? String, "\(year)\(String(format: "%02d", week + 1))")
        XCTAssertEqual(parameters?["output"] as? String, "json")
    }
    
    func testShouldSync() {
        UserDefaults.standard.setValue(false, forKey: "\(DifferentialGPSStation.key)DataSourceEnabled")
        XCTAssertFalse(DifferentialGPSStation.shouldSync())
        UserDefaults.standard.setValue(true, forKey: "\(DifferentialGPSStation.key)DataSourceEnabled")
        UserDefaults.standard.setValue(Date().timeIntervalSince1970 - (60 * 60 * 24 * 7) - 10, forKey: "\(DifferentialGPSStation.key)LastSyncTime")
        XCTAssertTrue(DifferentialGPSStation.shouldSync())
        UserDefaults.standard.setValue(Date().timeIntervalSince1970 - (60 * 60 * 24 * 7) + (60 * 10), forKey: "\(DifferentialGPSStation.key)LastSyncTime")
        XCTAssertFalse(DifferentialGPSStation.shouldSync())
    }
    
    func testDescription() {
        let newItem = DifferentialGPSStation(context: persistentStore.viewContext)
        newItem.volumeNumber = "PUB 112"
        newItem.aidType = "Differential GPS Stations"
        newItem.geopoliticalHeading = "KOREA"
        newItem.regionHeading = nil
        newItem.precedingNote = nil
        newItem.featureNumber = 7
        newItem.name = "Chumunjin Dan"
        newItem.position = "37°53'52.21\"N \n128°50'01.79\"E"
        newItem.stationID = "T663\nR726\nR727\n"
        newItem.range = 100
        newItem.frequency = 295
        newItem.transferRate = 200
        newItem.remarks = "Message types: 3, 5, 7, 9, 16."
        newItem.postNote = nil
        newItem.noticeNumber = 201134
        newItem.removeFromList = "N"
        newItem.deleteFlag = "N"
        newItem.noticeWeek = "34"
        newItem.noticeYear = "2011"
        
        let description = "Differential GPS Station\n\n" +
        "aidType Differential GPS Stations\n" +
        "deleteFlag N\n" +
        "featureNumber 7\n" +
        "frequency 295\n" +
        "geopoliticalHeading KOREA\n" +
        "latitude 0.0\n" +
        "longitude 0.0\n" +
        "name Chumunjin Dan\n" +
        "noticeNumber 201134\n" +
        "noticeWeek 34\n" +
        "noticeYear 2011\n" +
        "position 37°53'52.21\"N \n" +
        "128°50'01.79\"E\n" +
        "postNote \n" +
        "precedingNote \n" +
        "range 100\n" +
        "remarks Message types: 3, 5, 7, 9, 16.\n" +
        "regionHeading \n" +
        "removeFromList N\n" +
        "stationID T663\n" +
        "R726\n" +
        "R727\n\n" +
        
        "transferRate 200\n" +
        "volumeNumber PUB 112"
        
        print(newItem.description)
        
        XCTAssertEqual(description, newItem.description)
    }
    
    func testMapImage() {
        let newItem = DifferentialGPSStation(context: persistentStore.viewContext)
        newItem.volumeNumber = "PUB 112"
        newItem.aidType = "Differential GPS Stations"
        newItem.geopoliticalHeading = "KOREA"
        newItem.regionHeading = nil
        newItem.precedingNote = nil
        newItem.featureNumber = 7
        newItem.name = "Chumunjin Dan"
        newItem.position = "37°53'52.21\"N \n128°50'01.79\"E"
        newItem.stationID = "T663\nR726\nR727\n"
        newItem.range = 100
        newItem.frequency = 295
        newItem.transferRate = 200
        newItem.remarks = "Message types: 3, 5, 7, 9, 16."
        newItem.postNote = nil
        newItem.noticeNumber = 201134
        newItem.removeFromList = "N"
        newItem.deleteFlag = "N"
        newItem.noticeWeek = "34"
        newItem.noticeYear = "2011"
        
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
