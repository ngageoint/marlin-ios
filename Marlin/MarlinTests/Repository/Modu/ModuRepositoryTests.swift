//
//  ModuRepositoryTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/14/24.
//

import Foundation
import Combine
import CoreData
import OHHTTPStubs

@testable import Marlin

final class ModuRepositoryTests: XCTestCase {

    override func setUp() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults()

        UserDefaults.standard.initialDataLoaded = false
        UserDefaults.standard.clearLastSyncTimeSeconds(DataSources.modu)
        UserDefaults.standard.lastLoadDate = Date(timeIntervalSince1970: 0)

        UserDefaults.standard.setValue(Date(), forKey: "forceReloadDate")
    }

    override func tearDown() {
    }

    func testFetch() async {
        var models: [ModuModel] = []

        let data: [[String: AnyHashable?]] = [
            [
                "name": "ABAN II",
                "date": "2022-09-16",
                "rigStatus": "Active",
                "specialStatus": "Wide Berth Requested",
                "distance": nil,
                "latitude": 16.34183333300001,
                "longitude": 81.92416666700001,
                "position": "16°20'30.6\"N \n81°55'27\"E",
                "navArea": "HYDROPAC",
                "region": 6,
                "subregion": 63
            ],
            [
                "name": "ABAN III",
                "date": "2022-10-28",
                "rigStatus": "Inactive",
                "specialStatus": "Wide Berth Requested",
                "distance": nil,
                "latitude": 18.67283333300003,
                "longitude": 72.35783333299997,
                "position": "18°40'22.2\"N \n72°21'28.2\"E",
                "navArea": "HYDROPAC",
                "region": 6,
                "subregion": 63
            ]
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: data)
        let decoded: [ModuModel] = try! JSONDecoder().decode([ModuModel].self, from: jsonData)

        models.append(contentsOf: decoded)

        let loadingExpectation = expectation(forNotification: .DataSourceLoading,
                                             object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.modu.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let loadedExpectation = expectation(forNotification: .DataSourceLoaded,
                                            object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.modu.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let updatedExpectation = expectation(forNotification: .DataSourceUpdated,
                                             object: nil) { notification in
            if let notificationObject = notification.object as? DataSourceUpdatedNotification {
                XCTAssertEqual(notificationObject.key, DataSources.modu.key)
                XCTAssertEqual(notificationObject.inserts, 2)
            }
            return true
        }
        
        let localDataSource = ModuStaticLocalDataSource()
        InjectedValues[\.moduLocalDataSource] = localDataSource
        
        let remoteDataSource = ModuStaticRemoteDataSource()
        InjectedValues[\.moduRemoteDataSource] = remoteDataSource
        
        remoteDataSource.list = models
        let repository = ModuRepository()

        let modus = await repository.fetchModus()
        XCTAssertEqual(2, modus.count)

        await fulfillment(of: [loadingExpectation, loadedExpectation, updatedExpectation])

        let repoModu = repository.getModu(name: "ABAN II")
        XCTAssertNotNil(repoModu)
        XCTAssertEqual(repoModu, localDataSource.getModu(name: "ABAN II"))

        let repoModus = await repository.getModus(filters: nil)
        let localModus = await localDataSource.getModus(filters: nil)
        XCTAssertNotNil(repoModus)
        XCTAssertEqual(repoModus.count, localModus.count)

        XCTAssertEqual(repository.getCount(filters: nil), localDataSource.getCount(filters: nil))
    }

    func testCreateOperation() {
        let localDataSource = ModuStaticLocalDataSource()
        InjectedValues[\.moduLocalDataSource] = localDataSource
        
        let remoteDataSource = ModuStaticRemoteDataSource()
        InjectedValues[\.moduRemoteDataSource] = remoteDataSource
        
        var newest = ModuModel()
        newest.date = Date(timeIntervalSince1970: 0)
        localDataSource.list = [
            newest
        ]
        let repository = ModuRepository()
        let operation = repository.createOperation()
        XCTAssertNotNil(operation.dateString)
        XCTAssertEqual(operation.dateString, newest.dateString)
    }

}
