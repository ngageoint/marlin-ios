//
//  AsamSummaryViewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 12/20/22.
//

import XCTest
import SwiftUI

@testable import Marlin

final class AsamSummaryViewTests: XCTestCase {

    override func setUpWithError() throws {
        throw XCTSkip("ASAMs are disabled.")
    }
    
    func testLoading() async throws {
        try XCTSkipIf(TestHelpers.DISABLE_UI_TESTS, "UI tests are disabled")
        var asam = AsamModel()
        asam.asamDescription = "description"
        asam.longitude = 1.0
        asam.latitude = 1.0
        asam.date = Date()
        asam.navArea = "XI"
        asam.reference = "2022-100"
        asam.subreg = "71"
        asam.position = "1°00'00\"N \n1°00'00\"E"
        asam.hostility = "Boarding"
        asam.victim = "Boat"
        asam.canBookmark = true

        let localDataSource = AsamStaticLocalDataSource()
        InjectedValues[\.asamLocalDataSource] = localDataSource
        let remoteDataSource = AsamRemoteDataSourceImpl()
        InjectedValues[\.asamRemoteDataSource] = remoteDataSource
        
        localDataSource.list = [asam]
        let repository = AsamRepository()
        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        InjectedValues[\.bookmarkLocalDataSource] = bookmarkLocalDataSource
        
        let summary = AsamSummaryView(asam: AsamListModel(asamModel:asam))
            .environmentObject(MarlinRouter())
        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Boarding: Boat")
        TestHelpers.printAllAccessibilityLabelsInWindows()
        
        expectation(forNotification: .SnackbarNotification,
                    object: nil) { notification in
            print("Notification \(notification)")
            return true
        }
        tester().tapView(withAccessibilityLabel: "Location")
        
        waitForExpectations(timeout: 10, handler: nil)
        
        try await BookmarkHelper().verifyBookmarkButton(bookmarkable: asam)
    }
    
    func testLoadingNoHostility() {
        var newItem = AsamModel()
        newItem.asamDescription = "description"
        newItem.longitude = 1.0
        newItem.latitude = 1.0
        newItem.date = Date()
        newItem.navArea = "XI"
        newItem.reference = "2022-100"
        newItem.subreg = "71"
        newItem.position = "1°00'00\"N \n1°00'00\"E"
        newItem.hostility = nil
        newItem.victim = "Boat"
        
        let localDataSource = AsamStaticLocalDataSource()
        InjectedValues[\.asamLocalDataSource] = localDataSource
        let remoteDataSource = AsamRemoteDataSourceImpl()
        InjectedValues[\.asamRemoteDataSource] = remoteDataSource
        localDataSource.list = [newItem]
        let repository = AsamRepository()
        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        InjectedValues[\.bookmarkLocalDataSource] = bookmarkLocalDataSource
        
        let summary = AsamSummaryView(asam: AsamListModel(asamModel:newItem))
            .environmentObject(MarlinRouter())
        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Boat")
        TestHelpers.printAllAccessibilityLabelsInWindows()
        
        expectation(forNotification: .SnackbarNotification,
                    object: nil) { notification in
            print("Notification \(notification)")
            return true
        }
        tester().tapView(withAccessibilityLabel: "Location")
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testLoadingNoVictim() {
        var newItem = AsamModel()
        newItem.asamDescription = "description"
        newItem.longitude = 1.0
        newItem.latitude = 1.0
        newItem.date = Date()
        newItem.navArea = "XI"
        newItem.reference = "2022-100"
        newItem.subreg = "71"
        newItem.position = "1°00'00\"N \n1°00'00\"E"
        newItem.hostility = "Boarding"
        newItem.victim = nil
        
        let localDataSource = AsamStaticLocalDataSource()
        InjectedValues[\.asamLocalDataSource] = localDataSource
        let remoteDataSource = AsamRemoteDataSourceImpl()
        InjectedValues[\.asamRemoteDataSource] = remoteDataSource
        localDataSource.list = [newItem]
        let repository = AsamRepository()
        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        InjectedValues[\.bookmarkLocalDataSource] = bookmarkLocalDataSource
        
        let summary = AsamSummaryView(asam: AsamListModel(asamModel:newItem))
            .environmentObject(MarlinRouter())
        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Boarding")
        TestHelpers.printAllAccessibilityLabelsInWindows()
        
        expectation(forNotification: .SnackbarNotification,
                    object: nil) { notification in
            print("Notification \(notification)")
            return true
        }
        tester().tapView(withAccessibilityLabel: "Location")
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testLoadingShowMoreDetails() {
        var newItem = AsamModel()
        newItem.asamDescription = "description"
        newItem.longitude = 1.0
        newItem.latitude = 1.0
        newItem.date = Date()
        newItem.navArea = "XI"
        newItem.reference = "2022-100"
        newItem.subreg = "71"
        newItem.position = "1°00'00\"N \n1°00'00\"E"
        newItem.hostility = "Boarding"
        newItem.victim = "Boat"
        
        let router = MarlinRouter()
        let localDataSource = AsamStaticLocalDataSource()
        InjectedValues[\.asamLocalDataSource] = localDataSource
        let remoteDataSource = AsamRemoteDataSourceImpl()
        InjectedValues[\.asamRemoteDataSource] = remoteDataSource
        
        localDataSource.list = [newItem]
        let repository = AsamRepository()
        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        InjectedValues[\.bookmarkLocalDataSource] = bookmarkLocalDataSource
        
        let summary = AsamSummaryView(asam: AsamListModel(asamModel:newItem), showMoreDetails: true)
            .environmentObject(MarlinRouter())
        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Boarding: Boat")
        TestHelpers.printAllAccessibilityLabelsInWindows()

        XCTAssertEqual(router.path.count, 0)
        tester().tapView(withAccessibilityLabel: "More Details")

        tester().waitForAbsenceOfView(withAccessibilityLabel: "scope")
    }
    
    func testLoadingShowMoreDetailsFalse() {
        var newItem = AsamModel()
        newItem.asamDescription = "description"
        newItem.longitude = 1.0
        newItem.latitude = 1.0
        newItem.date = Date()
        newItem.navArea = "XI"
        newItem.reference = "2022-100"
        newItem.subreg = "71"
        newItem.position = "1°00'00\"N \n1°00'00\"E"
        newItem.hostility = "Boarding"
        newItem.victim = "Boat"
        
        let router = MarlinRouter()
        let localDataSource = AsamStaticLocalDataSource()
        InjectedValues[\.asamLocalDataSource] = localDataSource
        let remoteDataSource = AsamRemoteDataSourceImpl()
        InjectedValues[\.asamRemoteDataSource] = remoteDataSource
        localDataSource.list = [newItem]
        let repository = AsamRepository()
        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        InjectedValues[\.bookmarkLocalDataSource] = bookmarkLocalDataSource
        
        let summary = AsamSummaryView(asam: AsamListModel(asamModel:newItem), showMoreDetails: false)
//        let summary = AsamSummaryView(asam: AsamListModel(asam: newItem), showMoreDetails: false)
            .environmentObject(MarlinRouter())
        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "focus")
        TestHelpers.printAllAccessibilityLabelsInWindows()
        
        expectation(forNotification: .TabRequestFocus,
                    object: nil) { notification in
            return true
        }
        
        expectation(forNotification: .MapItemsTapped, object: nil) { notification in
            
            let tapNotification = try! XCTUnwrap(notification.object as? MapItemsTappedNotification)
            let asams = tapNotification.itemKeys![DataSources.asam.key] as! [String]
            XCTAssertEqual(asams.count, 1)
            XCTAssertEqual(asams[0], "2022-100")
            return true
        }
        tester().tapView(withAccessibilityLabel: "focus")
        
        waitForExpectations(timeout: 10, handler: nil)
        
        tester().waitForView(withAccessibilityLabel: "share")
        tester().tapView(withAccessibilityLabel: "share")
        
        tester().waitForTappableView(withAccessibilityLabel: "dismiss popup")
        tester().tapScreen(at: CGPoint(x:20, y:20))
    }

}
