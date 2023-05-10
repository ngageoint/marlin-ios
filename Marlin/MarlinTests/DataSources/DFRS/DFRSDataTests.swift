//
//  DFRSDataTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/23/23.
//

import XCTest
import Combine
import OHHTTPStubs
import CoreData

@testable import Marlin

final class DFRSDataTests: XCTestCase {

    var cancellable = Set<AnyCancellable>()
    var persistentStore: PersistentStore = PersistenceController.shared
    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
        .receive(on: RunLoop.main)
    
    override func setUp(completion: @escaping (Error?) -> Void) {
        UserDefaults.standard.initialDataLoaded = false
        UserDefaults.standard.clearLastSyncTimeSeconds(DFRS.self as any BatchImportable.Type)
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
        
        for seedDataFile in DFRS.seedDataFiles ?? [] {
            stub(condition: isScheme("file") && pathEndsWith("\(seedDataFile).json")) { request in
                return HTTPStubsResponse(
                    fileAtPath: OHPathForFile("dfrsMockData.json", type(of: self))!,
                    statusCode: 200,
                    headers: ["Content-Type": "application/json"]
                )
            }
        }
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DFRS.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DFRS.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(DFRS.self)
            XCTAssertEqual(count, 2)
            return true
        }
        
        MSI.shared.loadInitialData(type: DFRS.decodableRoot, dataType: DFRS.self)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testParsing() throws {
        for seedDataFile in DFRS.seedDataFiles ?? [] {
            stub(condition: isScheme("file") && pathEndsWith("\(seedDataFile).json")) { request in
                let jsonObject = [
                    "radio-navaids": [
                        [
                            "stationNo": "1187.61\n2-1282",
                            "stationName": "Nos Galata Lt.",
                            "stationType": "RDF",
                            "rxPosition": " \n",
                            "txPosition": "1°00'00\"N \n2°00'00\"E",
                            "frequency": "297.5 kHz, A2A.",
                            "range": "5",
                            "procedureText": "On request to Hydrographic Service, Varna.\n",
                            "remarks": "Transmits !DG$.\n",
                            "notes": "",
                            "areaName": "BULGARIA"
                        ]
                    ]
                ]
                return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type": "application/json"])
            }
        }
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DFRS.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DFRS.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(DFRS.self)
            XCTAssertEqual(count, 1)
            return true
        }
        
        MSI.shared.loadInitialData(type: DFRS.decodableRoot, dataType: DFRS.self)
        
        waitForExpectations(timeout: 10, handler: nil)
        
        let dfrs: DFRS = try! XCTUnwrap(self.persistentStore.fetchFirst(DFRS.self, sortBy: [DFRS.defaultSort[0].toNSSortDescriptor()], predicate: NSPredicate(value: true), context: nil))
        XCTAssertEqual(dfrs.areaName, "BULGARIA")
        XCTAssertEqual(dfrs.stationNumber, "1187.61\n2-1282")
        XCTAssertEqual(dfrs.stationName, "Nos Galata Lt.")
        XCTAssertEqual(dfrs.stationType, "RDF")
        XCTAssertEqual(dfrs.frequency, "297.5 kHz, A2A.")
        XCTAssertEqual(dfrs.range, 5)
        XCTAssertEqual(dfrs.procedureText, "On request to Hydrographic Service, Varna.")
        XCTAssertEqual(dfrs.remarks, "Transmits !DG$.")
        XCTAssertEqual(dfrs.notes, "")
        XCTAssertEqual(dfrs.txPosition, "1°00'00\"N \n2°00'00\"E")
        XCTAssertEqual(dfrs.txLatitude, 1.0)
        XCTAssertEqual(dfrs.txLongitude, 2.0)
        XCTAssertNil(dfrs.rxPosition)
        XCTAssertEqual(dfrs.rxLatitude, -190.0)
        XCTAssertEqual(dfrs.rxLongitude, -190.0)
    }
    
    func testRejectInvalidNoStationNumber() throws {
        for seedDataFile in DFRS.seedDataFiles ?? [] {
            stub(condition: isScheme("file") && pathEndsWith("\(seedDataFile).json")) { request in
                let jsonObject = [
                    "radio-navaids": [
                        [
                            "stationNo": nil,
                            "stationName": "Nos Galata Lt.",
                            "stationType": "RDF",
                            "rxPosition": " \n",
                            "txPosition": "1°00'00\"N \n2°00'00\"E",
                            "frequency": "297.5 kHz, A2A.",
                            "range": "5",
                            "procedureText": "On request to Hydrographic Service, Varna.",
                            "remarks": "Transmits !DG$.",
                            "notes": "",
                            "areaName": "BULGARIA"
                        ],
                        [
                            "stationNo": "1187.61\n2-1282",
                            "stationName": "Nos Galata Lt.",
                            "stationType": "RDF",
                            "rxPosition": " \n",
                            "txPosition": "1°00'00\"N \n2°00'00\"E",
                            "frequency": "297.5 kHz, A2A.",
                            "range": "5",
                            "procedureText": "On request to Hydrographic Service, Varna.",
                            "remarks": "Transmits !DG$.",
                            "notes": "",
                            "areaName": "BULGARIA"
                        ]
                    ]
                ]
                return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type": "application/json"])
            }
        }
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DFRS.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DFRS.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(DFRS.self)
            XCTAssertEqual(count, 1)
            return true
        }
        
        MSI.shared.loadInitialData(type: DFRS.decodableRoot, dataType: DFRS.self)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testRejectInvalidNoAreaName() throws {
        for seedDataFile in DFRS.seedDataFiles ?? [] {
            stub(condition: isScheme("file") && pathEndsWith("\(seedDataFile).json")) { request in
                let jsonObject = [
                    "radio-navaids": [
                        [
                            "stationNo": "1188.61\n2-1282",
                            "stationName": "Nos Galata Lt.",
                            "stationType": "RDF",
                            "rxPosition": " \n",
                            "txPosition": "1°00'00\"N \n2°00'00\"E",
                            "frequency": "297.5 kHz, A2A.",
                            "range": "5",
                            "procedureText": "On request to Hydrographic Service, Varna.",
                            "remarks": "Transmits !DG$.",
                            "notes": "",
                            "areaName": "BULGARIA"
                        ],
                        [
                            "stationNo": "1187.61\n2-1282",
                            "stationName": "Nos Galata Lt.",
                            "stationType": "RDF",
                            "rxPosition": " \n",
                            "txPosition": "1°00'00\"N \n2°00'00\"E",
                            "frequency": "297.5 kHz, A2A.",
                            "range": "5",
                            "procedureText": "On request to Hydrographic Service, Varna.",
                            "remarks": "Transmits !DG$.",
                            "notes": "",
                            "areaName": nil
                        ]
                    ]
                ]
                return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type": "application/json"])
            }
        }
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DFRS.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DFRS.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(DFRS.self)
            XCTAssertEqual(count, 1)
            return true
        }
        
        MSI.shared.loadInitialData(type: DFRS.decodableRoot, dataType: DFRS.self)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testDataRequest() {
        
        let newItem = DFRS(context: persistentStore.viewContext)
        newItem.stationNumber = "1188.61\n2-1282"
        newItem.stationName = "Nos Galata Lt."
        newItem.stationType = "RDF"
        newItem.rxPosition = " \n"
        newItem.txPosition = "1°00'00\"N \n2°00'00\"E"
        newItem.frequency = "297.5 kHz, A2A."
        newItem.range = 5
        newItem.procedureText = "On request to Hydrographic Service, Varna."
        newItem.remarks = "Transmits !DG$."
        newItem.notes = ""
        newItem.areaName = "BULGARIA"
        try? persistentStore.viewContext.save()
        
        let requests = DFRS.dataRequest()
        XCTAssertEqual(requests.count, 1)
        let request = requests[0]
        XCTAssertEqual(request.method, .get)
        let parameters = request.parameters
        XCTAssertEqual(parameters?.count, 1)
        XCTAssertEqual(parameters?["output"] as? String, "json")
    }
    
    func testShouldSync() {
        UserDefaults.standard.setValue(false, forKey: "\(DFRS.key)DataSourceEnabled")
        XCTAssertFalse(DFRS.shouldSync())
        UserDefaults.standard.setValue(true, forKey: "\(DFRS.key)DataSourceEnabled")
        UserDefaults.standard.setValue(Date().timeIntervalSince1970 - (60 * 60 * 24 * 7) - 10, forKey: "\(DFRS.key)LastSyncTime")
        XCTAssertTrue(DFRS.shouldSync())
        UserDefaults.standard.setValue(Date().timeIntervalSince1970 - (60 * 60 * 24 * 7) + (60 * 10), forKey: "\(DFRS.key)LastSyncTime")
        XCTAssertFalse(DFRS.shouldSync())
        UserDefaults.standard.setValue(false, forKey: "\(DFRS.key)DataSourceEnabled")
    }
    
    func testDescription() {
        let newItem = DFRS(context: persistentStore.viewContext)
        newItem.stationNumber = "1188.61\n2-1282"
        newItem.stationName = "Nos Galata Lt."
        newItem.stationType = "RDF"
        newItem.rxPosition = " \n"
        newItem.txPosition = "1°00'00\"N \n2°00'00\"E"
        newItem.frequency = "297.5 kHz, A2A."
        newItem.range = 5
        newItem.procedureText = "On request to Hydrographic Service, Varna."
        newItem.remarks = "Transmits !DG$."
        newItem.notes = ""
        newItem.areaName = "BULGARIA"
        
        let description = "DFRS\n\n" +
        "Area Name: BULGARIA\n" +
        "frequency: 297.5 kHz, A2A.\n" +
        "notes: \n" +
        "procedure text: On request to Hydrographic Service, Varna.\n" +
        "range: 5.0\n" +
        "remarks: Transmits !DG$.\n" +
        "rx position:  \n" +
        "\n" +
        "station name: Nos Galata Lt.\n" +
        "station number: 1188.61\n" +
        "2-1282\n" +
        "station type: RDF\n" +
        "tx position: 1°00'00\"N \n" +
        "2°00'00\"E\n"
        XCTAssertEqual(description, newItem.description)
    }
    
    func testMapImage() {
        let newItem = DFRS(context: persistentStore.viewContext)
        newItem.stationNumber = "1188.61\n2-1282"
        newItem.stationName = "Nos Galata Lt."
        newItem.stationType = "RDF"
        newItem.rxPosition = " \n"
        newItem.txPosition = "1°00'00\"N \n2°00'00\"E"
        newItem.frequency = "297.5 kHz, A2A."
        newItem.range = 5
        newItem.procedureText = "On request to Hydrographic Service, Varna."
        newItem.remarks = "Transmits !DG$."
        newItem.notes = ""
        newItem.areaName = "BULGARIA"
        
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
