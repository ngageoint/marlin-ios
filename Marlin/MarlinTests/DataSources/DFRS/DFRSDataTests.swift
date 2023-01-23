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
                    headers: ["Content-Type":"application/json"]
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
                            "stationNo":"1187.61\n2-1282",
                            "stationName":"Nos Galata Lt.",
                            "stationType":"RDF",
                            "rxPosition":" \n",
                            "txPosition":"1°00'00\"N \n2°00'00\"E",
                            "frequency":"297.5 kHz, A2A.",
                            "range":"5",
                            "procedureText":"On request to Hydrographic Service, Varna.",
                            "remarks":"Transmits !DG$.",
                            "notes":"",
                            "areaName":"BULGARIA"
                        ]
                    ]
                ]
                return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
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
        
        let dfrs: DFRS = try! XCTUnwrap(self.persistentStore.fetchFirst(DFRS.self, sortBy: [DFRS.defaultSort[0].toNSSortDescriptor()], predicate: NSPredicate(value: true)))
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
        XCTAssertEqual(dfrs.rxLatitude, 0.0)
        XCTAssertEqual(dfrs.rxLongitude, 0.0)
    }
    
}
