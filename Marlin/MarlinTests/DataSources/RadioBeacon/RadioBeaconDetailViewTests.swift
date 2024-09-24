//
//  RadioBeaconDetailViewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/19/23.
//

import XCTest
import Combine
import SwiftUI

@testable import Marlin

final class RadioBeaconDetailViewTests: XCTestCase {
    override func setUp() {
        Task.init {
            await TestHelpers.asyncGetKeyWindowVisible()
        }
        UserDefaults.standard.initialDataLoaded = false
        UserDefaults.standard.clearLastSyncTimeSeconds(DataSources.asam)

        UserDefaults.standard.lastLoadDate = Date(timeIntervalSince1970: 0)

        UserDefaults.standard.setValue(Date(), forKey: "forceReloadDate")
    }

    override func tearDown() {
    }

    func testLoading() {
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
        rb.sequenceText = "sequence text"

        let router = MarlinRouter()
        let localDataSource = RadioBeaconStaticLocalDataSource()
        let remoteDataSource = RadioBeaconStaticRemoteDataSource()
        InjectedValues[\.radioBeaconLocalDataSource] = localDataSource
        InjectedValues[\.radioBeaconRemoteDataSource] = remoteDataSource
        localDataSource.list = [rb]
        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        InjectedValues[\.bookmarkLocalDataSource] = bookmarkLocalDataSource
        let routeWaypointRepository = RouteWaypointRepository(localDataSource: RouteWaypointStaticLocalDataSource())

        let detailView = RadioBeaconDetailView(featureNumber: 10, volumeNumber: "PUB 110")
            .environmentObject(routeWaypointRepository)

        let controller = UIHostingController(rootView: detailView)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "\(rb.featureNumber!) \(rb.volumeNumber!)")
        tester().waitForView(withAccessibilityLabel: rb.name)
        tester().waitForView(withAccessibilityLabel: "section")
        tester().waitForView(withAccessibilityLabel: rb.morseLetter)
        tester().waitForView(withAccessibilityLabel: rb.expandedCharacteristicWithoutCode)
        tester().waitForView(withAccessibilityLabel: rb.stationRemark)

        tester().waitForView(withAccessibilityLabel: "Number")
        tester().waitForView(withAccessibilityLabel: "Name & Location")
        tester().waitForView(withAccessibilityLabel: "Geopolitical Heading")
        tester().waitForView(withAccessibilityLabel: "Position")
        tester().waitForView(withAccessibilityLabel: "Characteristic")
        tester().waitForView(withAccessibilityLabel: "Range (nmi)")
        tester().waitForView(withAccessibilityLabel: "Sequence")
        tester().waitForView(withAccessibilityLabel: "Frequency (kHz)")
        tester().waitForView(withAccessibilityLabel: "Remarks")

        tester().waitForView(withAccessibilityLabel: "\(rb.featureNumber!)")
        tester().waitForView(withAccessibilityLabel: rb.name)
        tester().waitForView(withAccessibilityLabel: rb.geopoliticalHeading)
        tester().waitForView(withAccessibilityLabel: "\(rb.position ?? "")")
        tester().waitForView(withAccessibilityLabel: rb.expandedCharacteristic)
        tester().waitForView(withAccessibilityLabel: "\(rb.range!)")
        tester().waitForView(withAccessibilityLabel: rb.sequenceText)
        tester().waitForView(withAccessibilityLabel: rb.frequency)
        tester().waitForView(withAccessibilityLabel: rb.stationRemark)

    }

    func xtestButtons() throws {
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
        let routeWaypointRepository = RouteWaypointRepository(localDataSource: RouteWaypointStaticLocalDataSource())

        let detailView = RadioBeaconDetailView(featureNumber: 10, volumeNumber: "PUB 110")
            .environmentObject(routeWaypointRepository)

        let controller = UIHostingController(rootView: detailView)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "\(rb.featureNumber!) \(rb.volumeNumber!)")
        // TODO: cant't test this due to KIF wanting buttons to become first responders
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
            let rb = tapNotification.items as! [RadioBeaconModel]
            XCTAssertEqual(rb.count, 1)
            XCTAssertEqual(rb[0].name, "Ittoqqortoormit, Scoresbysund")
            return true
        }
        tester().tapView(withAccessibilityLabel: "focus")
        
        waitForExpectations(timeout: 10, handler: nil)
        
        tester().waitForView(withAccessibilityLabel: "share")
        tester().tapView(withAccessibilityLabel: "share")
        
        tester().waitForTappableView(withAccessibilityLabel: "dismiss popup")
        tester().tapScreen(at: CGPoint(x:20, y:20))
//        try BookmarkHelper().verifyBookmarkButton(bookmarkable: rb)
    }
}

