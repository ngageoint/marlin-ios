//
//  DifferentialGPSStationRepositoryTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/13/24.
//

import Foundation
import Combine
import CoreData
import OHHTTPStubs

@testable import Marlin

final class DifferentialGPSStationRepositoryTests: XCTestCase {

    override func setUp() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults()

        UserDefaults.standard.initialDataLoaded = false
        UserDefaults.standard.clearLastSyncTimeSeconds(DataSources.dgps)
        UserDefaults.standard.lastLoadDate = Date(timeIntervalSince1970: 0)

        UserDefaults.standard.setValue(Date(), forKey: "forceReloadDate")
    }

    override func tearDown() {
    }

    func testFetch() async {
        var models: [DGPSStationModel] = []

        let data: [[String: AnyHashable?]] = [
            [
                "volumeNumber": "PUB 112",
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
        let jsonData = try! JSONSerialization.data(withJSONObject: data)
        let decoded: [DGPSStationModel] = try! JSONDecoder().decode([DGPSStationModel].self, from: jsonData)

        models.append(contentsOf: decoded)

        let loadingExpectation = expectation(forNotification: .DataSourceLoading,
                                             object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.dgps.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let loadedExpectation = expectation(forNotification: .DataSourceLoaded,
                                            object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.dgps.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let updatedExpectation = expectation(forNotification: .DataSourceUpdated,
                                             object: nil) { notification in
            if let notificationObject = notification.object as? DataSourceUpdatedNotification {
                XCTAssertEqual(notificationObject.key, DataSources.dgps.key)
                XCTAssertEqual(notificationObject.inserts, 2)
            }
            return true
        }
        let localDataSource = DifferentialGPSStationStaticLocalDataSource()
        let remoteDataSource = DifferentialGPSStationStaticRemoteDataSource()
        remoteDataSource.list = models
        let repository = DGPSStationRepository(localDataSource: localDataSource, remoteDataSource: remoteDataSource)

        let dgps = await repository.fetch()
        XCTAssertEqual(2, dgps.count)

        await fulfillment(of: [loadingExpectation, loadedExpectation, updatedExpectation])

        let repoData = repository.getDGPSStation(featureNumber: 6, volumeNumber: "PUB 112")
        XCTAssertNotNil(repoData)
        XCTAssertEqual(repoData, localDataSource.getDifferentialGPSStation(featureNumber: 6, volumeNumber: "PUB 112"))

        let repoDatas = await repository.getDifferentialGPSStations(filters: nil)
        let localDatas = await localDataSource.getDifferentialGPSStations(filters: nil)
        XCTAssertNotNil(repoDatas)
        XCTAssertEqual(repoDatas.count, localDatas.count)

        XCTAssertEqual(repository.getCount(filters: nil), localDataSource.getCount(filters: nil))
    }

    func testCreateOperation() {
        let localDataSource = DifferentialGPSStationStaticLocalDataSource()
        let remoteDataSource = DifferentialGPSStationStaticRemoteDataSource()
        var newest = DGPSStationModel()
        newest.noticeNumber = 202204
        newest.noticeYear = "2022"
        newest.noticeWeek = "04"
        localDataSource.list = [
            newest
        ]
        let repository = DGPSStationRepository(localDataSource: localDataSource, remoteDataSource: remoteDataSource)
        let operation = repository.createOperation()
        XCTAssertNotNil(operation.noticeYear)
        XCTAssertEqual(operation.noticeYear, "2022")
        XCTAssertNotNil(operation.noticeWeek)
        XCTAssertEqual(operation.noticeWeek, "05")
    }

}
