//
//  ModuSummaryTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/19/23.
//

import XCTest
import Combine
import SwiftUI

@testable import Marlin

final class ModuSummaryTests: XCTestCase {
    func testLoading() async throws {
        try XCTSkipIf(TestHelpers.DISABLE_UI_TESTS, "UI tests are disabled")
        var modu = ModuModel()

        modu.name = "ABAN II"
        modu.date = Date(timeIntervalSince1970: 0)
        modu.rigStatus = "Active"
        modu.specialStatus = "Wide Berth Requested"
        modu.distance = 5
        modu.latitude = 1.0
        modu.longitude = 2.0
        modu.position = "16°20'30.6\"N \n81°55'27\"E"
        modu.navArea = "HYDROPAC"
        modu.region = 6
        modu.subregion = 63
        modu.canBookmark = true

        let localDataSource = ModuStaticLocalDataSource()
        InjectedValues[\.moduLocalDataSource] = localDataSource
        
        let remoteDataSource = ModuRemoteDataSourceImpl()
        InjectedValues[\.moduRemoteDataSource] = remoteDataSource
        
        localDataSource.list = [modu]
        let repository = ModuRepository()
        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        InjectedValues[\.bookmarkLocalDataSource] = bookmarkLocalDataSource
        
        let summary = ModuSummaryView(modu: ModuListModel(moduModel: modu))
            .setShowMoreDetails(false)
            .environmentObject(repository)
            .environmentObject(MarlinRouter())

        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Active")
        tester().waitForView(withAccessibilityLabel: "Wide Berth Requested")
        tester().waitForView(withAccessibilityLabel: "ABAN II")
        tester().waitForView(withAccessibilityLabel: modu.dateString)
        
        expectation(forNotification: .SnackbarNotification,
                    object: nil) { notification in
            let model = try? XCTUnwrap(notification.object as? SnackbarNotification)
            XCTAssertEqual(model?.snackbarModel?.message, "Location \(UserDefaults.standard.coordinateDisplay.format(coordinate: modu.coordinate)) copied to clipboard")
            XCTAssertEqual(UIPasteboard.general.string, "\(UserDefaults.standard.coordinateDisplay.format(coordinate: modu.coordinate))")
            return true
        }
        tester().tapView(withAccessibilityLabel: "Location")
        
        expectation(forNotification: .TabRequestFocus,
                    object: nil) { notification in
            return true
        }
        
        expectation(forNotification: .MapItemsTapped, object: nil) { notification in
            let tapNotification = try! XCTUnwrap(notification.object as? MapItemsTappedNotification)
            let moduKeys = tapNotification.itemKeys!

            let modus = moduKeys[DataSources.modu.key]!

            XCTAssertEqual(modus.count, 1)
            XCTAssertEqual(modus[0], modu.itemKey)
            return true
        }
        tester().tapView(withAccessibilityLabel: "focus")
        
        waitForExpectations(timeout: 10, handler: nil)
        
        tester().waitForView(withAccessibilityLabel: "share")
        tester().tapView(withAccessibilityLabel: "share")
        
        tester().waitForTappableView(withAccessibilityLabel: "dismiss popup")
        tester().tapScreen(at: CGPoint(x:20, y:20))
        
        try await BookmarkHelper().verifyBookmarkButton(bookmarkable: modu)
    }
    
    func testShowMoreDetails() throws {
        try XCTSkipIf(TestHelpers.DISABLE_UI_TESTS, "UI tests are disabled")
        var modu = ModuModel()

        modu.name = "ABAN II"
        modu.date = Date(timeIntervalSince1970: 0)
        modu.rigStatus = "Active"
        modu.specialStatus = "Wide Berth Requested"
        modu.distance = 5
        modu.latitude = 1.0
        modu.longitude = 2.0
        modu.position = "16°20'30.6\"N \n81°55'27\"E"
        modu.navArea = "HYDROPAC"
        modu.region = 6
        modu.subregion = 63

        let router = MarlinRouter()
        let localDataSource = ModuStaticLocalDataSource()
        InjectedValues[\.moduLocalDataSource] = localDataSource
        
        let remoteDataSource = ModuRemoteDataSourceImpl()
        InjectedValues[\.moduRemoteDataSource] = remoteDataSource
        
        localDataSource.list = [modu]
        let repository = ModuRepository()
        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        InjectedValues[\.bookmarkLocalDataSource] = bookmarkLocalDataSource
        
        let summary = ModuSummaryView(modu: ModuListModel(moduModel: modu))
            .setShowMoreDetails(true)
            .environmentObject(repository)
            .environmentObject(router)

        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Active")
        
        XCTAssertEqual(router.path.count, 0)
        tester().tapView(withAccessibilityLabel: "More Details")
        XCTAssertEqual(router.path.count, 1)

        tester().waitForAbsenceOfView(withAccessibilityLabel: "scope")
    }
}
