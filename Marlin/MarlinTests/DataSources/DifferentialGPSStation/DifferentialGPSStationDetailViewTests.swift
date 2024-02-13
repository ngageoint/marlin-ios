//
//  DifferentialGPSStationDetailViewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/12/23.
//

import XCTest
import Combine
import SwiftUI

@testable import Marlin

final class DifferentialGPSStationDetailViewTests: XCTestCase {
    override func setUp() {
        for dataSource in DataSourceDefinitions.allCases {
            UserDefaults.standard.initialDataLoaded = false
            UserDefaults.standard.clearLastSyncTimeSeconds(dataSource.definition)
        }
        UserDefaults.standard.lastLoadDate = Date(timeIntervalSince1970: 0)
        
        UserDefaults.standard.setValue(Date(), forKey: "forceReloadDate")
    }
    
    override func tearDown() {
    }
    
    func testLoading() {
        var dgps = DifferentialGPSStationModel()
        dgps.volumeNumber = "PUB 112"
        dgps.aidType = "Differential GPS Stations"
        dgps.geopoliticalHeading = "KOREA"
        dgps.regionHeading = "region heading"
        dgps.sectionHeader = "KOREA: region heading"
        dgps.precedingNote = "preceeding note"
        dgps.featureNumber = 6
        dgps.name = "Chojin Dan Lt"
        dgps.position = "1°00'00\"N \n2°00'00.00\"E"
        dgps.latitude = 1.0
        dgps.longitude = 2.0
        dgps.stationID = "T670\nR740\nR741"
        dgps.range = 100
        dgps.frequency = 292
        dgps.transferRate = 200
        dgps.remarks = "Message types: 3, 5, 7, 9, 16."
        dgps.postNote = "post note"
        dgps.noticeNumber = 201134
        dgps.removeFromList = "N"
        dgps.deleteFlag = "N"
        dgps.noticeWeek = "34"
        dgps.noticeYear = "2011"

        let localDataSource = DifferentialGPSStationStaticLocalDataSource()
        localDataSource.list = [dgps]
        let repository = DifferentialGPSStationRepository(
            localDataSource: localDataSource,
            remoteDataSource: DifferentialGPSStationRemoteDataSource()
        )
        let bookmarkStaticRepository = BookmarkStaticRepository(dgpsRepository: repository)
        let bookmarkRepository = BookmarkRepositoryManager(repository: bookmarkStaticRepository)

        let routeWaypointRepository = RouteWaypointRepository(localDataSource: RouteWaypointStaticLocalDataSource())
        let view = DifferentialGPSStationDetailView(featureNumber: dgps.featureNumber, volumeNumber: dgps.volumeNumber)
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
            .environmentObject(routeWaypointRepository)
        let controller = UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller

        tester().waitForView(withAccessibilityLabel: "6 PUB 112")
        tester().waitForView(withAccessibilityLabel: "\(dgps.featureNumber ?? 0)")
        tester().waitForView(withAccessibilityLabel: dgps.name)
        tester().waitForView(withAccessibilityLabel: dgps.geopoliticalHeading)
        tester().waitForView(withAccessibilityLabel: dgps.position)
        tester().waitForView(withAccessibilityLabel: dgps.stationID)
        tester().waitForView(withAccessibilityLabel: "\(dgps.range ?? 0)")
        tester().waitForView(withAccessibilityLabel: "\(dgps.frequency ?? 0)")
        tester().waitForView(withAccessibilityLabel: "\(dgps.transferRate ?? 0)")
        tester().waitForView(withAccessibilityLabel: dgps.remarks)
        tester().waitForView(withAccessibilityLabel: "\(dgps.noticeNumber ?? 0)")
        tester().waitForView(withAccessibilityLabel: dgps.precedingNote)
        tester().waitForView(withAccessibilityLabel: dgps.postNote)
    }

    func xtestTapButtons() {
        var dgps = DifferentialGPSStationModel()
        dgps.volumeNumber = "PUB 112"
        dgps.aidType = "Differential GPS Stations"
        dgps.geopoliticalHeading = "KOREA"
        dgps.regionHeading = "region heading"
        dgps.sectionHeader = "KOREA: region heading"
        dgps.precedingNote = "preceeding note"
        dgps.featureNumber = 6
        dgps.name = "Chojin Dan Lt"
        dgps.position = "1°00'00\"N \n2°00'00.00\"E"
        dgps.latitude = 1.0
        dgps.longitude = 2.0
        dgps.stationID = "T670\nR740\nR741"
        dgps.range = 100
        dgps.frequency = 292
        dgps.transferRate = 200
        dgps.remarks = "Message types: 3, 5, 7, 9, 16."
        dgps.postNote = "post note"
        dgps.noticeNumber = 201134
        dgps.removeFromList = "N"
        dgps.deleteFlag = "N"
        dgps.noticeWeek = "34"
        dgps.noticeYear = "2011"

        let localDataSource = DifferentialGPSStationStaticLocalDataSource()
        localDataSource.list = [dgps]
        let repository = DifferentialGPSStationRepository(
            localDataSource: localDataSource,
            remoteDataSource: DifferentialGPSStationRemoteDataSource()
        )
        let bookmarkStaticRepository = BookmarkStaticRepository(dgpsRepository: repository)
        let bookmarkRepository = BookmarkRepositoryManager(repository: bookmarkStaticRepository)

        let routeWaypointRepository = RouteWaypointRepository(localDataSource: RouteWaypointStaticLocalDataSource())
        let view = DifferentialGPSStationDetailView(featureNumber: dgps.featureNumber, volumeNumber: dgps.volumeNumber)
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
            .environmentObject(routeWaypointRepository)
        let controller = UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller

        // TODO: this is untestable b/c KIF thinks the button can become first responder so it fails to tap
        expectation(forNotification: .SnackbarNotification,
                    object: nil) { notification in
            print("Notification \(notification)")
            return true
        }

        tester().tapView(withAccessibilityLabel: "Location")
        waitForExpectations(timeout: 10, handler: nil)

        BookmarkHelper().verifyBookmarkButton(bookmarkable: dgps)
    }
}
