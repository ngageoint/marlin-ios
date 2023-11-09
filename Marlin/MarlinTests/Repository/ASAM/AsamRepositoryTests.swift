//
//  AsamRepositoryTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 11/7/23.
//

import XCTest
import Combine
import CoreData
import OHHTTPStubs

@testable import Marlin

final class AsamRepositoryTests: XCTestCase {

    var cancellable = Set<AnyCancellable>()
    var persistentStore: PersistentStore = PersistenceController.shared
    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
        .receive(on: RunLoop.main)
    
    override func setUp(completion: @escaping (Error?) -> Void) {
        Task.init {
            await TestHelpers.asyncGetKeyWindowVisible()
        }
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
    
    func testFetch() async {
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
        
        let loadingExpectation = expectation(forNotification: .DataSourceLoading,
                                             object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[Asam.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        let loadedExpectation = expectation(forNotification: .DataSourceLoaded,
                                            object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[Asam.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        let batchUpdateComplete = expectation(forNotification: .BatchUpdateComplete,
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
        
        let repository = AsamRepository(localDataSource: AsamCoreDataDataSource(context: persistentStore.viewContext), remoteDataSource: AsamRemoteDataSource())
        
        let asams = await repository.fetchAsams(refresh: true)
        XCTAssertEqual(3, asams.count)
        let asam = asams[0]
        
        let retrieved = repository.getAsams(filters: [DataSourceFilterParameter(property: DataSourceProperty(name: "reference", key: "reference", type: .string), comparison: DataSourceFilterComparison.equals, valueString: asam.reference)])
        XCTAssertEqual(1, retrieved.count)
        XCTAssertEqual(retrieved[0].reference, asam.reference)
        XCTAssertEqual(retrieved[0].victim, asam.victim)
        
        let retrievedNone = repository.getAsams(filters: [DataSourceFilterParameter(property: DataSourceProperty(name: "reference", key: "reference", type: .string), comparison: DataSourceFilterComparison.equals, valueString: "no")])
        XCTAssertEqual(0, retrievedNone.count)
        
        await fulfillment(of: [loadingExpectation, loadedExpectation, batchUpdateComplete])

    }

}
