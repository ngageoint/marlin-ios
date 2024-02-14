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

    override func setUp() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults()
        
        UserDefaults.standard.initialDataLoaded = false
        UserDefaults.standard.clearLastSyncTimeSeconds(DataSources.asam)
        UserDefaults.standard.lastLoadDate = Date(timeIntervalSince1970: 0)
        
        UserDefaults.standard.setValue(Date(), forKey: "forceReloadDate")
    }
    
    override func tearDown() {
    }
    
    func testFetch() async {
        var asamModels: [AsamModel] = []

        let asamData: [[String: AnyHashable]] = [[
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
        ]]
        let jsonData = try! JSONSerialization.data(withJSONObject: asamData)
        let decoded: [AsamModel] = try! JSONDecoder().decode([AsamModel].self, from: jsonData)

        asamModels.append(contentsOf: decoded)

        let loadingExpectation = expectation(forNotification: .DataSourceLoading,
                                             object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.asam.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        let loadedExpectation = expectation(forNotification: .DataSourceLoaded,
                                            object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.asam.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let updatedExpectation = expectation(forNotification: .DataSourceUpdated,
                                            object: nil) { notification in
            if let notificationObject = notification.object as? DataSourceUpdatedNotification {
                XCTAssertEqual(notificationObject.key, DataSources.asam.key)
                XCTAssertEqual(notificationObject.inserts, 3)
            }
            return true
        }
        let localDataSource = AsamStaticLocalDataSource()
        let remoteDataSource = AsamStaticRemoteDataSource()
        remoteDataSource.asamList = asamModels
        let repository = AsamRepository(localDataSource: localDataSource, remoteDataSource: remoteDataSource)

        let asams = await repository.fetchAsams()
        XCTAssertEqual(3, asams.count)

        await fulfillment(of: [loadingExpectation, loadedExpectation, updatedExpectation])

        let repoAsam = repository.getAsam(reference: "2022-218")
        XCTAssertNotNil(repoAsam)
        XCTAssertEqual(repoAsam, localDataSource.getAsam(reference: "2022-218"))

        let repoAsams = await repository.getAsams(filters: nil)
        let localAsams = await localDataSource.getAsams(filters: nil)
        XCTAssertNotNil(repoAsams)
        XCTAssertEqual(repoAsams.count, localAsams.count)

        XCTAssertEqual(repository.getCount(filters: nil), localDataSource.getCount(filters: nil))
    }

    func testCreateOperation() {
        let localDataSource = AsamStaticLocalDataSource()
        let remoteDataSource = AsamStaticRemoteDataSource()
        var newest = AsamModel()
        newest.date = Date(timeIntervalSince1970: 0)
        localDataSource.list = [
            newest
        ]
        let repository = AsamRepository(localDataSource: localDataSource, remoteDataSource: remoteDataSource)
        let operation = repository.createOperation()
        XCTAssertNotNil(operation.dateString)
        XCTAssertEqual(operation.dateString, newest.dateString)
    }

}
