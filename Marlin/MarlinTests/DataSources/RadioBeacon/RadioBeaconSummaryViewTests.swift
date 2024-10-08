//
//  RadioBeaconSummaryViewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/19/23.
//

import XCTest
import Combine
import SwiftUI

@testable import Marlin

final class RadioBeaconSummaryViewTests: XCTestCase {

    func testLoading() throws {
        try XCTSkipIf(TestHelpers.DISABLE_UI_TESTS, "UI tests are disabled")
        var rb = RadioBeaconModel()

        rb.volumeNumber = "PUB 110"
        rb.aidType = "Radiobeacons"
        rb.geopoliticalHeading = "GREENLAND"
        rb.regionHeading = nil
        rb.precedingNote = nil
        rb.featureNumber = 10
        rb.name = "Ittoqqortoormit, Scoresbysund"
        rb.position = "70°29'11.99\"N \n21°58'20\"W"
        rb.characteristic = "SC\n(• • •  - • - • ).\n"
        rb.range = 200
        rb.sequenceText = nil
        rb.frequency = "343\nNON, A2A."
        rb.stationRemark = "Aeromarine."
        rb.postNote = nil
        rb.noticeNumber = 199706
        rb.removeFromList = "N"
        rb.deleteFlag = "N"
        rb.noticeWeek = "06"
        rb.noticeYear = "1997"
        rb.latitude = 1.0
        rb.longitude = 2.0
        rb.sectionHeader = "section"
        rb.canBookmark = true

        let router = MarlinRouter()
        let localDataSource = RadioBeaconStaticLocalDataSource()
        let remoteDataSource = RadioBeaconStaticRemoteDataSource()
        InjectedValues[\.radioBeaconLocalDataSource] = localDataSource
        InjectedValues[\.radioBeaconRemoteDataSource] = remoteDataSource
        localDataSource.list = [rb]
        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        InjectedValues[\.bookmarkLocalDataSource] = bookmarkLocalDataSource

        let summary = RadioBeaconSummaryView(radioBeacon: RadioBeaconListModel(radioBeaconModel:rb))
            .setShowMoreDetails(false)
            .environmentObject(router)

        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "\(rb.featureNumber!) \(rb.volumeNumber!)")
        tester().waitForView(withAccessibilityLabel: rb.name)
        tester().waitForAbsenceOfView(withAccessibilityLabel: "section")
        tester().waitForView(withAccessibilityLabel: rb.morseLetter)
        tester().waitForView(withAccessibilityLabel: rb.expandedCharacteristicWithoutCode)
        tester().waitForView(withAccessibilityLabel: rb.stationRemark)
        
        expectation(forNotification: .SnackbarNotification,
                    object: nil) { notification in
            let model = try? XCTUnwrap(notification.object as? SnackbarNotification)
            XCTAssertEqual(model?.snackbarModel?.message, "Location \(UserDefaults.standard.coordinateDisplay.format(coordinate: rb.coordinate)) copied to clipboard")
            XCTAssertEqual(UIPasteboard.general.string, "\(UserDefaults.standard.coordinateDisplay.format(coordinate: rb.coordinate))")
            return true
        }
        tester().tapView(withAccessibilityLabel: "Location")
        
        expectation(forNotification: .TabRequestFocus,
                    object: nil) { notification in
            return true
        }
        
        expectation(forNotification: .MapItemsTapped, object: nil) { notification in
            let tapNotification = try! XCTUnwrap(notification.object as? MapItemsTappedNotification)
            let rbKeys = tapNotification.itemKeys!

            let rbs = rbKeys[DataSources.radioBeacon.key]!

            XCTAssertEqual(rbs.count, 1)
            XCTAssertEqual(rbs[0], rb.itemKey)
            return true
        }
        tester().tapView(withAccessibilityLabel: "focus")
        
        waitForExpectations(timeout: 10, handler: nil)
        
        tester().waitForView(withAccessibilityLabel: "share")
        tester().tapView(withAccessibilityLabel: "share")
        
        tester().waitForTappableView(withAccessibilityLabel: "dismiss popup")
        tester().tapScreen(at: CGPoint(x:20, y:20))
        
        try BookmarkHelper().verifyBookmarkButton(bookmarkable: rb)
    }
    
    func testShowMoreDetails() throws {
        try XCTSkipIf(TestHelpers.DISABLE_UI_TESTS, "UI tests are disabled")
        var rb = RadioBeaconModel()

        rb.volumeNumber = "PUB 110"
        rb.aidType = "Radiobeacons"
        rb.geopoliticalHeading = "GREENLAND"
        rb.regionHeading = nil
        rb.precedingNote = nil
        rb.featureNumber = 10
        rb.name = "Ittoqqortoormit, Scoresbysund"
        rb.position = "70°29'11.99\"N \n21°58'20\"W"
        rb.characteristic = "SC\n(• • •  - • - • ).\n"
        rb.range = 200
        rb.sequenceText = nil
        rb.frequency = "343\nNON, A2A."
        rb.stationRemark = "Aeromarine."
        rb.postNote = nil
        rb.noticeNumber = 199706
        rb.removeFromList = "N"
        rb.deleteFlag = "N"
        rb.noticeWeek = "06"
        rb.noticeYear = "1997"
        rb.latitude = 1.0
        rb.longitude = 2.0
        rb.sectionHeader = "section"
        rb.canBookmark = true

        let router = MarlinRouter()
        let localDataSource = RadioBeaconStaticLocalDataSource()
        let remoteDataSource = RadioBeaconStaticRemoteDataSource()
        InjectedValues[\.radioBeaconLocalDataSource] = localDataSource
        InjectedValues[\.radioBeaconRemoteDataSource] = remoteDataSource
        localDataSource.list = [rb]
        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        InjectedValues[\.bookmarkLocalDataSource] = bookmarkLocalDataSource

        let summary = RadioBeaconSummaryView(radioBeacon: RadioBeaconListModel(radioBeaconModel:rb))
            .setShowMoreDetails(true)
            .environmentObject(router)

        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "\(rb.featureNumber!) \(rb.volumeNumber!)")
        tester().waitForView(withAccessibilityLabel: "section")

        XCTAssertEqual(router.path.count, 0)
        tester().tapView(withAccessibilityLabel: "More Details")
        XCTAssertEqual(router.path.count, 1)

        tester().waitForAbsenceOfView(withAccessibilityLabel: "scope")
    }
    
    func testShowSectionHeader() {
        var rb = RadioBeaconModel()

        rb.volumeNumber = "PUB 110"
        rb.aidType = "Radiobeacons"
        rb.geopoliticalHeading = "GREENLAND"
        rb.regionHeading = nil
        rb.precedingNote = nil
        rb.featureNumber = 10
        rb.name = "Ittoqqortoormit, Scoresbysund"
        rb.position = "70°29'11.99\"N \n21°58'20\"W"
        rb.characteristic = "SC\n(• • •  - • - • ).\n"
        rb.range = 200
        rb.sequenceText = nil
        rb.frequency = "343\nNON, A2A."
        rb.stationRemark = "Aeromarine."
        rb.postNote = nil
        rb.noticeNumber = 199706
        rb.removeFromList = "N"
        rb.deleteFlag = "N"
        rb.noticeWeek = "06"
        rb.noticeYear = "1997"
        rb.latitude = 1.0
        rb.longitude = 2.0
        rb.sectionHeader = "section"
        rb.canBookmark = true

        let router = MarlinRouter()
        let localDataSource = RadioBeaconStaticLocalDataSource()
        let remoteDataSource = RadioBeaconStaticRemoteDataSource()
        InjectedValues[\.radioBeaconLocalDataSource] = localDataSource
        InjectedValues[\.radioBeaconRemoteDataSource] = remoteDataSource
        localDataSource.list = [rb]
        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        InjectedValues[\.bookmarkLocalDataSource] = bookmarkLocalDataSource

        let summary = RadioBeaconSummaryView(radioBeacon: RadioBeaconListModel(radioBeaconModel:rb))
            .setShowSectionHeader(true)
            .environmentObject(router)
        
        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "\(rb.featureNumber!) \(rb.volumeNumber!)")
        tester().waitForView(withAccessibilityLabel: "section")
        tester().waitForAbsenceOfView(withAccessibilityLabel: "More Details")
        
        tester().waitForAbsenceOfView(withAccessibilityLabel: "scope")
    }
}
