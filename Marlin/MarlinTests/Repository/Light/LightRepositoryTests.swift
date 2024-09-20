//
//  LightRepositoryTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/13/24.
//

import Foundation
import Combine
import CoreData
import OHHTTPStubs

@testable import Marlin

final class LightRepositoryTests: XCTestCase {

    override func setUp() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults()

        UserDefaults.standard.initialDataLoaded = false
        UserDefaults.standard.clearLastSyncTimeSeconds(DataSources.light)

        UserDefaults.standard.lastLoadDate = Date(timeIntervalSince1970: 0)

        UserDefaults.standard.setValue(Date(), forKey: "forceReloadDate")
    }

    override func tearDown() {
    }

    func testFetch() async {
        var models: [LightModel] = []

        let data: [[String: AnyHashable?]] = [[
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
          ]]
        let jsonData = try! JSONSerialization.data(withJSONObject: data)
        let decoded: [LightModel] = try! JSONDecoder().decode([LightModel].self, from: jsonData)

        models.append(contentsOf: decoded)

        let loadingExpectation = expectation(forNotification: .DataSourceLoading,
                                             object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.light.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let loadedExpectation = expectation(forNotification: .DataSourceLoaded,
                                            object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.light.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let updatedExpectation = expectation(forNotification: .DataSourceUpdated,
                                             object: nil) { notification in
            if let notificationObject = notification.object as? DataSourceUpdatedNotification {
                XCTAssertEqual(notificationObject.key, DataSources.light.key)
                XCTAssertEqual(notificationObject.inserts, 2)
            }
            return true
        }
        let localDataSource = LightStaticLocalDataSource()
        let remoteDataSource = LightStaticRemoteDataSource()
        InjectedValues[\.lightLocalDataSource] = localDataSource
        InjectedValues[\.lightRemoteDataSource] = remoteDataSource
        await remoteDataSource.setList(["110": models])
        let repository = LightRepository()

        let lights = await repository.fetchLights()
        XCTAssertEqual(2, lights.count)

        await fulfillment(of: [loadingExpectation, loadedExpectation, updatedExpectation], timeout: 5)

        let repoLight = await repository.getLight(featureNumber: "6", volumeNumber: "PUB 110")
        XCTAssertNotNil(repoLight)
        XCTAssertEqual(repoLight, localDataSource.getLight(featureNumber: "6", volumeNumber: "PUB 110"))

        let repoLCharacteristic = await repository.getCharacteristic(featureNumber: "6", volumeNumber: "PUB 110", characteristicNumber: 1)
        XCTAssertNotNil(repoLCharacteristic)
        XCTAssertEqual(repoLCharacteristic, localDataSource.getCharacteristic(featureNumber: "6", volumeNumber: "PUB 110", characteristicNumber: 1))
        let repoLCharacteristic2 = await repository.getCharacteristic(featureNumber: "6", volumeNumber: "PUB 110", characteristicNumber: 2)
        XCTAssertNil(repoLCharacteristic2)
        XCTAssertEqual(repoLCharacteristic2, localDataSource.getCharacteristic(featureNumber: "6", volumeNumber: "PUB 110", characteristicNumber: 2))

        let repoLights = await repository.getLights(filters: nil)
        let localLights = await localDataSource.getLights(filters: nil)
        XCTAssertNotNil(repoLights)
        XCTAssertEqual(repoLights.count, localLights.count)
        let repoCount = await repository.getCount(filters: nil)
        XCTAssertEqual(repoCount, localDataSource.getCount(filters: nil))
    }

    func testCreateOperation() async {
        let localDataSource = LightStaticLocalDataSource()
        let remoteDataSource = LightStaticRemoteDataSource()
        InjectedValues[\.lightLocalDataSource] = localDataSource
        InjectedValues[\.lightRemoteDataSource] = remoteDataSource
        var newest = LightModel()
        newest.volumeNumber = "PUB 110"
        newest.noticeNumber = 202205
        newest.noticeYear = "2022"
        newest.noticeWeek = "05"
        var newest2 = LightModel()
        newest2.volumeNumber = "PUB 111"
        newest2.noticeNumber = 202105
        newest2.noticeYear = "2021"
        newest2.noticeWeek = "04"
        localDataSource.list = [
            newest,
            newest2
        ]
        let repository = LightRepository()
        let operations = await repository.createOperations()
        XCTAssertEqual(Light.lightVolumes.count, operations.count)
        let op0 = operations[0]
        XCTAssertEqual(op0.volume, "110")
        XCTAssertEqual(op0.noticeYear, "2022")
        XCTAssertEqual(op0.noticeWeek, "06")
        let op1 = operations[1]
        XCTAssertEqual(op1.volume, "111")
        XCTAssertEqual(op1.noticeYear, "2021")
        XCTAssertEqual(op1.noticeWeek, "05")
        let op2 = operations[2]
        XCTAssertEqual(op2.volume, "112")
        XCTAssertEqual(op2.noticeYear, nil)
        XCTAssertEqual(op2.noticeWeek, nil)
        let op3 = operations[3]
        XCTAssertEqual(op3.volume, "113")
        XCTAssertEqual(op3.noticeYear, nil)
        XCTAssertEqual(op3.noticeWeek, nil)
        let op4 = operations[4]
        XCTAssertEqual(op4.volume, "114")
        XCTAssertEqual(op4.noticeYear, nil)
        XCTAssertEqual(op4.noticeWeek, nil)
        let op5 = operations[5]
        XCTAssertEqual(op5.volume, "115")
        XCTAssertEqual(op5.noticeYear, nil)
        XCTAssertEqual(op5.noticeWeek, nil)
        let op6 = operations[6]
        XCTAssertEqual(op6.volume, "116")
        XCTAssertEqual(op6.noticeYear, nil)
        XCTAssertEqual(op6.noticeWeek, nil)
    }

}
