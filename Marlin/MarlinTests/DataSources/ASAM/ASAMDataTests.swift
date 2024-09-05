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
    var persistentStore: PersistentStore = PersistenceController.shared
    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
        .receive(on: RunLoop.main)
    
    override func setUp(completion: @escaping (Error?) -> Void) {
        let skip = XCTSkip("ASAMs are disabled.")
        completion(skip)
        
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
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.asam.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.asam.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(Asam.self)
            XCTAssertEqual(count, 2)
            return true
        }
        
        expectation(forNotification: .BatchUpdateComplete,
                    object: nil) { notification in
            guard let updatedNotification = notification.object as? BatchUpdateComplete else {
                XCTFail("Incorrect notification")
                return false
            }
            let updates = updatedNotification.dataSourceUpdates
            if updates.isEmpty {
                XCTFail("should be some updates")
                return false
            }
            XCTAssertFalse(updates.isEmpty)
            let update = updates[0]
            XCTAssertEqual(2, update.inserts)
            XCTAssertEqual(0, update.updates)
            return true
        }
        
        let bundle = MockBundle()
        bundle.mockPath = "asamMockData.json"
        
        let operation = AsamInitialDataLoadOperation(localDataSource: AsamCoreDataDataSource(), bundle: bundle)
        operation.start()

        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testLoadInitialDataAndUpdate() async throws {

        let loadingNotification = expectation(forNotification: .DataSourceLoading,
                                              object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.asam.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let loadedNotification = expectation(forNotification: .DataSourceLoaded,
                                             object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.asam.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let didSaveNotification = expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(Asam.self)
            XCTAssertEqual(count, 2)
            return true
        }

        let batchUpdateCompleteNotification = expectation(forNotification: .BatchUpdateComplete,
                                                          object: nil) { notification in
            guard let updatedNotification = notification.object as? BatchUpdateComplete else {
                XCTFail("Incorrect notification")
                return false
            }
            let updates = updatedNotification.dataSourceUpdates
            if updates.isEmpty {
                XCTFail("should be some updates")
            }
            XCTAssertFalse(updates.isEmpty)
            let update = updates[0]
            XCTAssertEqual(2, update.inserts)
            XCTAssertEqual(0, update.updates)
            return true
        }

        let bundle = MockBundle()
        bundle.mockPath = "asamMockData.json"

        let repository = AsamRepository(localDataSource: AsamCoreDataDataSource(), remoteDataSource: AsamRemoteDataSource())

        let operation = AsamInitialDataLoadOperation(localDataSource: repository.localDataSource, bundle: bundle)
        operation.start()

        await fulfillment(of: [loadingNotification, loadedNotification, didSaveNotification, batchUpdateCompleteNotification], timeout: 10)

        stub(condition: isScheme("https") && pathEndsWith("/publications/asam")) { request in
            let jsonObject = [
                "asam": [
                    [
                        "reference": "2022-218",
                        "date": "2022-10-24",
                        "latitude": 1.1499999999778083,
                        "longitude": 103.43333333315655,
                        "position": "1°09'00\"N \n103°26'00\"E",
                        "navArea": "XI",
                        "subreg": "71",
                        "hostility": "Boarding",
                        "victim": "Marshall Islands bulk carrier GENCO ENDEAVOUR",
                        "description": "THIS ONE IS NEW"
                    ],
                    [
                        "reference": "2022-216",
                        "date": "2022-10-21",
                        "latitude": 14.649999999964734,
                        "longitude": 49.49999999969782,
                        "position": "14°39'00\"N \n49°30'00\"E",
                        "navArea": "IX",
                        "subreg": "62",
                        "hostility": "Two drone explosions",
                        "victim": "Marshall Islands-flagged oil tanker NISSOS KEA",
                        "description": "UPDATED"
                    ],
                    // this one is the same
                    [
                        "reference": "2022-217",
                        "date": "2022-10-24",
                        "latitude": 1.1499999999778083,
                        "longitude": 103.43333333315655,
                        "position": "1°09'00\"N \n103°26'00\"E",
                        "navArea": "XI",
                        "subreg": "71",
                        "hostility": "Boarding",
                        "victim": "Marshall Islands bulk carrier GENCO ENDEAVOUR",
                        "description": "INDONESIA: On 23 October at 2359 local time, five robbers boarded the underway Marshall Islands-flagged bulk carrier GENCO ENDEAVOUR close to Little Karimum Island in the eastbound lane of the Singapore Strait Traffic Separation Scheme (TSS), near position 01-09N 103-26E. The crew sighted the unauthorized personnel near the steering gear room and activated the ship’s general alarm. Upon realizing they had been discovered, the robbers escaped empty-handed. The ship reported the incident to the Singapore Vessel Traffic System. The Singapore police coast guard later boarded the vessel for an investigation. Information was shared with Indonesian authorities."
                    ]
                ]
            ]
            return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
        }

        let loadingNotification2 = expectation(forNotification: .DataSourceLoading,
                                               object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.asam.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let loadedNotification2 = expectation(forNotification: .DataSourceLoaded,
                                              object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.asam.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let batchUpdateCompleteNotification2 = expectation(forNotification: .BatchUpdateComplete,
                                                           object: nil) { notification in
            guard let updatedNotification = notification.object as? BatchUpdateComplete else {
                XCTFail("Incorrect notification")
                return false
            }
            let updates = updatedNotification.dataSourceUpdates
            if updates.isEmpty {
                XCTFail("should be some updates")
            }
            XCTAssertFalse(updates.isEmpty)
            let update = updates[0]
            XCTAssertEqual(1, update.inserts)
            XCTAssertEqual(2, update.updates)
            return true
        }
        
        await repository.fetchAsams()

        await fulfillment(of: [loadingNotification2, loadedNotification2, batchUpdateCompleteNotification2], timeout: 10)

        await self.persistentStore.viewContext.perform {
            let count = try? self.persistentStore.countOfObjects(Asam.self)
            XCTAssertEqual(3, count)
            let updatedAsam = try! XCTUnwrap(self.persistentStore.fetchFirst(Asam.self, sortBy: [DataSources.asam.filterable!.defaultSort[0].toNSSortDescriptor()], predicate: NSPredicate(format: "reference = %@", "2022-216"), context: nil))

            XCTAssertEqual(updatedAsam.reference, "2022-216")
            XCTAssertEqual(updatedAsam.asamDescription, "UPDATED")

            let newAsam = try! XCTUnwrap(self.persistentStore.fetchFirst(Asam.self, sortBy: [DataSources.asam.filterable!.defaultSort[0].toNSSortDescriptor()], predicate: NSPredicate(format: "reference = %@", "2022-218"), context: nil))

            XCTAssertEqual(newAsam.reference, "2022-218")
            XCTAssertEqual(newAsam.asamDescription, "THIS ONE IS NEW")
        }
    }
    
    func testRejectInvalidAsamNoReference() throws {
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
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.asam.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.asam.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(Asam.self)
            XCTAssertEqual(count, 1)
            return true
        }

        let bundle = MockBundle()
        bundle.tempFileContents = jsonObject

        let operation = AsamInitialDataLoadOperation(localDataSource: AsamCoreDataDataSource(), bundle: bundle)
        operation.start()

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testRejectInvalidAsamNoLatitude() throws {
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

        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.asam.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.asam.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(Asam.self)
            XCTAssertEqual(count, 1)
            return true
        }
        
        let bundle = MockBundle()
        bundle.tempFileContents = jsonObject
        
        let operation = AsamInitialDataLoadOperation(localDataSource: AsamCoreDataDataSource(), bundle: bundle)
        operation.start()

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testRejectInvalidAsamNoLongitude() throws {
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

        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.asam.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.asam.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(Asam.self)
            XCTAssertEqual(count, 1)
            return true
        }
        
        let bundle = MockBundle()
        bundle.tempFileContents = jsonObject
        
        let operation = AsamInitialDataLoadOperation(localDataSource: AsamCoreDataDataSource(), bundle: bundle)
        operation.start()

        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testDataRequest() {
        let request = AsamService.getAsams(date: nil)
        XCTAssertEqual(request.method, .get)
        let parameters = request.parameters
        XCTAssertEqual(parameters?.count, 2)
        XCTAssertEqual(parameters?["sort"] as? String, "date")
        XCTAssertEqual(parameters?["output"] as? String, "json")
    }
    
    func testShouldSync() {
        UserDefaults.standard.setValue(false, forKey: "\(DataSources.asam.key)DataSourceEnabled")
        XCTAssertFalse(DataSources.asam.shouldSync())
        UserDefaults.standard.setValue(true, forKey: "\(DataSources.asam.key)DataSourceEnabled")
        UserDefaults.standard.setValue(Date().timeIntervalSince1970 - (60 * 60) - 10, forKey: "\(DataSources.asam.key)LastSyncTime")
        XCTAssertTrue(DataSources.asam.shouldSync())
        UserDefaults.standard.setValue(Date().timeIntervalSince1970 - (60 * 60) + (60 * 10), forKey: "\(DataSources.asam.key)LastSyncTime")
        XCTAssertFalse(DataSources.asam.shouldSync())
    }
    
    func testDescription() {
        var newItem = AsamModel()
        newItem.asamDescription = "description"
        newItem.longitude = 1.0
        newItem.latitude = 1.0
        newItem.date = Date(timeIntervalSince1970: 0)
        newItem.navArea = "XI"
        newItem.reference = "2022-100"
        newItem.subreg = "71"
        newItem.position = "1°00'00\"N \n1°00'00\"E"
        newItem.hostility = "Boarding"
        newItem.victim = "Boat"
        
        let description = "ASAM\n\n" +
        "Reference: 2022-100\n" +
        "Date: 1969-12-31\n" +
        "Latitude: 1.0\n" +
        "Longitude: 1.0\n" +
        "Navigation Area: XI\n" +
        "Subregion: 71\n" +
        "Description: description\n" +
        "Hostility: Boarding\n" +
        "Victim: Boat\n"

        XCTAssertEqual(description, newItem.description)
    }
    
    func testMapImage() {
        var newItem = AsamModel()
        newItem.asamDescription = "description"
        newItem.longitude = 1.0
        newItem.latitude = 1.0
        newItem.date = Date()
        newItem.navArea = "XI"
        newItem.reference = "2022-100"
        newItem.subreg = "71"
        newItem.position = "1°00'00\"N \n1°00'00\"E"
        newItem.hostility = "Boarding"
        newItem.victim = "Boat"
        
        var circleSize: CGSize = .zero
        var imageSize: CGSize = .zero
        
        for i in 1...18 {
            let image = AsamImage(asam: newItem)
            let images = image.image(context: nil, zoom: i, tileBounds: MapBoundingBox(swCorner: (x:-10, y:-10), neCorner: (x: 10, y:10)), tileSize: 512.0)
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
