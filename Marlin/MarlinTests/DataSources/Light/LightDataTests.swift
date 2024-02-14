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
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults()
        UserDefaults.standard.initialDataLoaded = false
        UserDefaults.standard.clearLastSyncTimeSeconds(DataSources.light)
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
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.light.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.light.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(Light.self)
            XCTAssertEqual(count, 3)
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
            XCTAssertEqual(3, update.inserts)
            XCTAssertEqual(0, update.updates)
            return true
        }

        let bundle = MockBundle()
        bundle.mockPath = "lightMockData.json"
        let localDataSource = LightCoreDataDataSource()
        let operation = LightInitialDataLoadOperation(localDataSource: localDataSource, bundle: bundle)
        operation.start()

        expectation(forNotification: .DataSourceProcessed,
                                    object: nil) { notification in
            XCTAssertEqual((notification.object as? DataSourceUpdatedNotification)?.key, DataSources.light.key)
            return true
        }

        waitForExpectations(timeout: 10, handler: nil)

        let lights = localDataSource.getLight(featureNumber: "8", volumeNumber: "PUB 110")!
        XCTAssertEqual(lights.count, 1)
        let light = lights[0]
        XCTAssertNotNil(light)
        let ranges = light.lightRange
        XCTAssertNotNil(ranges)
        XCTAssertEqual(ranges?.count, 3)
        let red = ranges?.first(where: { model in
            model.color == "R"
        })
        XCTAssertNotNil(red)
        XCTAssertEqual(red?.range, 9.0)
        let green = ranges?.first(where: { model in
            model.color == "G"
        })
        XCTAssertNotNil(green)
        XCTAssertEqual(green?.range, 9.0)
        let white = ranges?.first(where: { model in
            model.color == "W"
        })
        XCTAssertNotNil(white)
        XCTAssertEqual(white?.range, 12.0)
    }
    
    func testLoadInitialDataAndUpdate() async throws {

        let loadingNotification = expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.light.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        let loadedNotification = expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.light.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        let didSaveNotification = expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(Light.self)
            XCTAssertEqual(count, 3)
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
            XCTAssertEqual(3, update.inserts)
            XCTAssertEqual(0, update.updates)
            return true
        }

        let bundle = MockBundle()
        bundle.mockPath = "lightMockData.json"

        let repository = LightRepository(localDataSource: LightCoreDataDataSource(), remoteDataSource: LightRemoteDataSource())

        let operation = LightInitialDataLoadOperation(localDataSource: repository.localDataSource, bundle: bundle)
        operation.start()

        let processed = expectation(forNotification: .DataSourceProcessed,
                                    object: nil) { notification in
            XCTAssertEqual((notification.object as? DataSourceUpdatedNotification)?.key, DataSources.light.key)
            return true
        }

        await fulfillment(of: [loadingNotification, loadedNotification, didSaveNotification, batchUpdateCompleteNotification, processed], timeout: 10)

        // this is all the other volumes
        stub(condition: isScheme("https") && pathEndsWith("/publications/ngalol/lights-buoys") && !containsQueryParams(["volume": "110"])) { request in
            let jsonObject = [
                "ngalol": [
                ]
            ]
            return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
        }

        var initialQueryCalled = false

        // this to catch the initial query
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
            initialQueryCalled = true
            return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
        }

        var requeryCalled = false
        // this catches the requery
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
            requeryCalled = true
            return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
        }
        
        let loadingNotification2 = expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.light.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        let loadedNotification2 = expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.light.key] {
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
            XCTAssertEqual(1, update.updates)
            return true
        }

        await repository.fetchLights()

        await fulfillment(of: [loadingNotification2, loadedNotification2, batchUpdateCompleteNotification2], timeout: 10)

        await self.persistentStore.viewContext.perform {
            let count = try? self.persistentStore.countOfObjects(Light.self)
            XCTAssertEqual(4, count)
            let newLight = try! XCTUnwrap(self.persistentStore.fetchFirst(Light.self, sortBy: [DataSources.light.filterable!.defaultSort[0].toNSSortDescriptor()], predicate: NSPredicate(format: "featureNumber = %@", "9"), context: nil))
        }

        XCTAssertTrue(initialQueryCalled)
        XCTAssertTrue(requeryCalled)
    }
    
    func testRejectInvalidLightNoFeatureNumber() throws {
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

        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.light.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.light.key] {
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
        let bundle = MockBundle()
        bundle.tempFileContents = jsonObject

        let operation = LightInitialDataLoadOperation(localDataSource: LightCoreDataDataSource(), bundle: bundle)
        operation.start()

        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testRejectInvalidLightNoVolumeNumber() throws {
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
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.light.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.light.key] {
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
        
        let bundle = MockBundle()
        bundle.tempFileContents = jsonObject

        let operation = LightInitialDataLoadOperation(localDataSource: LightCoreDataDataSource(), bundle: bundle)
        operation.start()

        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testRejectInvalidLightNoPosition() throws {
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
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.light.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.light.key] {
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
        
        let bundle = MockBundle()
        bundle.tempFileContents = jsonObject

        let operation = LightInitialDataLoadOperation(localDataSource: LightCoreDataDataSource(), bundle: bundle)
        operation.start()

        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testPostProcess() throws {
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
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.light.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.light.key] {
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

        let bundle = MockBundle()
        bundle.tempFileContents = jsonObject

        let operation = LightInitialDataLoadOperation(localDataSource: LightCoreDataDataSource(), bundle: bundle)
        operation.start()

        expectation(forNotification: .DataSourceProcessed,
                    object: nil) { notification in
            XCTAssertEqual((notification.object as? DataSourceUpdatedNotification)?.key, DataSources.light.key)
            return true
        }
        
        waitForExpectations(timeout: 10, handler: nil)
        
        let light = try? self.persistentStore.fetchFirst(Light.self, sortBy: [DataSources.light.defaultSort[0].toNSSortDescriptor()], predicate: NSPredicate(value: true), context: nil)
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

        let request = LightService.getLights(volume: "110", noticeYear: nil, noticeWeek: nil)
        XCTAssertEqual(request.method, .get)
        let parameters = request.parameters
        XCTAssertEqual(parameters?.count, 3)
        XCTAssertEqual(parameters?["output"] as? String, "json")
        XCTAssertEqual(parameters?["includeRemovals"] as? Bool, false)
        XCTAssertEqual(parameters?["volume"] as? String, "110")

        let request2 = LightService.getLights(volume: "110", noticeYear: "2015", noticeWeek: "08")
        XCTAssertEqual(request2.method, .get)
        let parameters2 = request2.parameters
        XCTAssertEqual(parameters2?.count, 5)
        XCTAssertEqual(parameters2?["output"] as? String, "json")
        XCTAssertEqual(parameters2?["includeRemovals"] as? Bool, false)
        XCTAssertEqual(parameters2?["volume"] as? String, "110")
        XCTAssertEqual(parameters2?["minNoticeNumber"] as? String, "201508")
        let calendar = Calendar.current
        let week = calendar.component(.weekOfYear, from: Date())
        let year = calendar.component(.year, from: Date())
        XCTAssertEqual(parameters2?["maxNoticeNumber"] as? String, "\(year)\(String(format: "%02d", week + 1))")
    }

    func testShouldSync() {
        UserDefaults.standard.setValue(false, forKey: "\(DataSources.light.key)DataSourceEnabled")
        XCTAssertFalse(DataSources.light.shouldSync())
        UserDefaults.standard.setValue(true, forKey: "\(DataSources.light.key)DataSourceEnabled")
        UserDefaults.standard.setValue(Date().timeIntervalSince1970 - (60 * 60 * 24 * 7) - 10, forKey: "\(DataSources.light.key)LastSyncTime")
        XCTAssertTrue(DataSources.light.shouldSync())
        UserDefaults.standard.setValue(Date().timeIntervalSince1970 - (60 * 60 * 24 * 7) + (60 * 10), forKey: "\(DataSources.light.key)LastSyncTime")
        XCTAssertFalse(DataSources.light.shouldSync())
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
        var newItem = LightModel()
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
            let image = LightImage(light: newItem)
            let images = image.image(context: nil, zoom: i, tileBounds: MapBoundingBox(swCorner: (x:-10, y:-10), neCorner: (x: 10, y:10)), tileSize: 512.0)

//            let images = newItem.mapImage(marker: false, zoomLevel: i, tileBounds3857: MapBoundingBox(swCorner: (x:-10, y:-10), neCorner: (x: 10, y:10)), context: nil)
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
