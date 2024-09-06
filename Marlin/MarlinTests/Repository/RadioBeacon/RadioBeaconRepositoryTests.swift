//
//  RadioBeaconRepositoryTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/14/24.
//

import Foundation
import Combine
import CoreData
import OHHTTPStubs

@testable import Marlin

final class RadioBeaconRepositoryTests: XCTestCase {

    override func setUp() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults()

        UserDefaults.standard.initialDataLoaded = false
        UserDefaults.standard.clearLastSyncTimeSeconds(DataSources.radioBeacon)
        UserDefaults.standard.lastLoadDate = Date(timeIntervalSince1970: 0)

        UserDefaults.standard.setValue(Date(), forKey: "forceReloadDate")
    }

    override func tearDown() {
    }

    func testFetch() async {
        var models: [RadioBeaconModel] = []

        let data: [[String: AnyHashable?]] = [
            [
                "volumeNumber": "PUB 110",
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

        let jsonData = try! JSONSerialization.data(withJSONObject: data)
        let decoded: [RadioBeaconModel] = try! JSONDecoder().decode([RadioBeaconModel].self, from: jsonData)

        models.append(contentsOf: decoded)

        let loadingExpectation = expectation(forNotification: .DataSourceLoading,
                                             object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.radioBeacon.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let loadedExpectation = expectation(forNotification: .DataSourceLoaded,
                                            object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.radioBeacon.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let updatedExpectation = expectation(forNotification: .DataSourceUpdated,
                                             object: nil) { notification in
            if let notificationObject = notification.object as? DataSourceUpdatedNotification {
                XCTAssertEqual(notificationObject.key, DataSources.radioBeacon.key)
                XCTAssertEqual(notificationObject.inserts, 2)
            }
            return true
        }
        let localDataSource = RadioBeaconStaticLocalDataSource()
        let remoteDataSource = RadioBeaconStaticRemoteDataSource()
        InjectedValues[\.radioBeaconLocalDataSource] = localDataSource
        InjectedValues[\.radioBeaconRemoteDataSource] = remoteDataSource
        remoteDataSource.list = models
        let repository = RadioBeaconRepository()

        let radioBeacons = await repository.fetchRadioBeacons()
        XCTAssertEqual(2, radioBeacons.count)

        await fulfillment(of: [loadingExpectation, loadedExpectation, updatedExpectation])

        let repoRadioBeacon = repository.getRadioBeacon(featureNumber: 20, volumeNumber: "PUB 110")
        XCTAssertNotNil(repoRadioBeacon)
        XCTAssertEqual(repoRadioBeacon, localDataSource.getRadioBeacon(featureNumber: 20, volumeNumber: "PUB 110"))

        let repoRadioBeacons = await repository.getRadioBeacons(filters: nil)
        let localRadioBeacons = await localDataSource.getRadioBeacons(filters: nil)
        XCTAssertNotNil(repoRadioBeacons)
        XCTAssertEqual(repoRadioBeacons.count, localRadioBeacons.count)

        XCTAssertEqual(repository.getCount(filters: nil), localDataSource.getCount(filters: nil))
    }

    func testCreateOperation() {
        let localDataSource = RadioBeaconStaticLocalDataSource()
        let remoteDataSource = RadioBeaconStaticRemoteDataSource()
        InjectedValues[\.radioBeaconLocalDataSource] = localDataSource
        InjectedValues[\.radioBeaconRemoteDataSource] = remoteDataSource
        var newest = RadioBeaconModel()
        newest.noticeWeek = "05"
        newest.noticeYear = "2022"
        localDataSource.list = [
            newest
        ]
        let repository = RadioBeaconRepository()
        let operation = repository.createOperation()
        XCTAssertNotNil(operation.noticeYear)
        XCTAssertEqual(operation.noticeYear, "2022")
        XCTAssertNotNil(operation.noticeWeek)
        XCTAssertEqual(operation.noticeWeek, "06")
    }

}
