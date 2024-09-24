////
////  AsamDetailViewTests.swift
////  MarlinTests
////
////  Created by Daniel Barela on 12/30/22.
////
//
//import XCTest
//import SwiftUI
//
//@testable import Marlin
//
//final class AsamDetailViewTests: XCTestCase {
//    override func setUpWithError() throws {
//        throw XCTSkip("ASAMs are disabled.")
//    }
//    
//    func testLoading() {
//        var asam = AsamModel()
//        asam.asamDescription = "description"
//        asam.longitude = 1.0
//        asam.latitude = 1.0
//        asam.date = Date(timeIntervalSince1970: 0)
//        asam.navArea = "XI"
//        asam.reference = "2022-100"
//        asam.subreg = "71"
//        asam.position = "1°00'00\"N \n1°00'00\"E"
//        asam.hostility = "Boarding"
//        asam.victim = "Boat"
//        asam.canBookmark = true
//
//        let localDataSource = AsamStaticLocalDataSource()
//        InjectedValues[\.asamLocalDataSource] = localDataSource
//        let remoteDataSource = AsamRemoteDataSource()
//        InjectedValues[\.asamRemoteDataSource] = remoteDataSource
//        localDataSource.list = [asam]
//        let repository = AsamRepository()
//        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
//        InjectedValues[\.bookmarkLocalDataSource] = bookmarkLocalDataSource
//        
//        let routeWaypointRepository = RouteWaypointRepository(localDataSource: RouteWaypointStaticLocalDataSource())
//        let view = AsamDetailView(reference: asam.reference!)
//            .environmentObject(repository)
//            .environmentObject(routeWaypointRepository)
//        let controller = UIHostingController(rootView: view)
//        let window = TestHelpers.getKeyWindowVisible()
//        window.rootViewController = controller
//        
//        tester().waitForView(withAccessibilityLabel: "Boarding: Boat")
//        tester().waitForView(withAccessibilityLabel: asam.asamDescription)
//        tester().waitForView(withAccessibilityLabel: asam.hostility)
//        tester().waitForView(withAccessibilityLabel: asam.victim)
//        tester().waitForView(withAccessibilityLabel: asam.reference)
//        tester().waitForView(withAccessibilityLabel: asam.subreg)
//        tester().waitForView(withAccessibilityLabel: asam.navArea)
//        tester().waitForView(withAccessibilityLabel: asam.dateString)
//    }
//
//    func xtestTapButtons() throws {
//        try XCTSkipIf(TestHelpers.DISABLE_UI_TESTS, "UI tests are disabled")
//        var asam = AsamModel()
//        asam.asamDescription = "description"
//        asam.longitude = 1.0
//        asam.latitude = 1.0
//        asam.date = Date(timeIntervalSince1970: 0)
//        asam.navArea = "XI"
//        asam.reference = "2022-100"
//        asam.subreg = "71"
//        asam.position = "1°00'00\"N \n1°00'00\"E"
//        asam.hostility = "Boarding"
//        asam.victim = "Boat"
//
//        let localDataSource = AsamStaticLocalDataSource()
//        InjectedValues[\.asamLocalDataSource] = localDataSource
//        let remoteDataSource = AsamRemoteDataSource()
//        InjectedValues[\.asamRemoteDataSource] = remoteDataSource
//        localDataSource.list = [asam]
//        let repository = AsamRepository()
//        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
//        InjectedValues[\.bookmarkLocalDataSource] = bookmarkLocalDataSource
//        
//        var routeWaypointRepository = RouteWaypointRepository(localDataSource: RouteWaypointStaticLocalDataSource())
//        let view = AsamDetailView(reference: asam.reference!)
//            .environmentObject(repository)
//            .environmentObject(routeWaypointRepository)
//        let controller = UIHostingController(rootView: view)
//        let window = TestHelpers.getKeyWindowVisible()
//        window.rootViewController = controller
//
//        // TODO: this is untestable b/c KIF thinks the button can become first responder so it fails to tap
//        expectation(forNotification: .SnackbarNotification,
//                    object: nil) { notification in
//            print("Notification \(notification)")
//            return true
//        }
//
//        tester().tapView(withAccessibilityLabel: "Location")
//        waitForExpectations(timeout: 10, handler: nil)
//
//        try BookmarkHelper().verifyBookmarkButton(bookmarkable: asam)
//    }
//
//    func testLoadingNoHostility() {
//        var asam = AsamModel()
//
//        asam.asamDescription = "description"
//        asam.longitude = 1.0
//        asam.latitude = 1.0
//        asam.date = Date(timeIntervalSince1970: 0)
//        asam.navArea = "XI"
//        asam.reference = "2022-100"
//        asam.subreg = "71"
//        asam.position = "1°00'00\"N \n1°00'00\"E"
//        asam.hostility = nil
//        asam.victim = "Boat"
//
//        let localDataSource = AsamStaticLocalDataSource()
//        InjectedValues[\.asamLocalDataSource] = localDataSource
//        let remoteDataSource = AsamRemoteDataSource()
//        InjectedValues[\.asamRemoteDataSource] = remoteDataSource
//        localDataSource.list = [asam]
//        let repository = AsamRepository()
//        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
//        InjectedValues[\.bookmarkLocalDataSource] = bookmarkLocalDataSource
//        
//        var routeWaypointRepository = RouteWaypointRepository(localDataSource: RouteWaypointStaticLocalDataSource())
//        let summary = AsamDetailView(reference: asam.reference!)
//            .environmentObject(repository)
//            .environmentObject(routeWaypointRepository)
//
//        let controller = UIHostingController(rootView: summary)
//        let window = TestHelpers.getKeyWindowVisible()
//        window.rootViewController = controller
//        tester().waitForView(withAccessibilityLabel: "Boat")
//        tester().waitForView(withAccessibilityLabel: asam.asamDescription)
//        tester().waitForView(withAccessibilityLabel: asam.hostility)
//        tester().waitForView(withAccessibilityLabel: asam.victim)
//        tester().waitForView(withAccessibilityLabel: asam.reference)
//        tester().waitForView(withAccessibilityLabel: asam.subreg)
//        tester().waitForView(withAccessibilityLabel: asam.navArea)
//        tester().waitForView(withAccessibilityLabel: asam.dateString)
//    }
//
//    func testLoadingNoVictim() {
//        var asam = AsamModel()
//
//        asam.asamDescription = "description"
//        asam.longitude = 1.0
//        asam.latitude = 1.0
//        asam.date = Date(timeIntervalSince1970: 0)
//        asam.navArea = "XI"
//        asam.reference = "2022-100"
//        asam.subreg = "71"
//        asam.position = "1°00'00\"N \n1°00'00\"E"
//        asam.hostility = "Boarding"
//        asam.victim = nil
//
//        let localDataSource = AsamStaticLocalDataSource()
//        InjectedValues[\.asamLocalDataSource] = localDataSource
//        let remoteDataSource = AsamRemoteDataSource()
//        InjectedValues[\.asamRemoteDataSource] = remoteDataSource
//        localDataSource.list = [asam]
//        let repository = AsamRepository()
//        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
//        InjectedValues[\.bookmarkLocalDataSource] = bookmarkLocalDataSource
//        
//        var routeWaypointRepository = RouteWaypointRepository(localDataSource: RouteWaypointStaticLocalDataSource())
//        let summary = AsamDetailView(reference: asam.reference!)
//            .environmentObject(repository)
//            .environmentObject(routeWaypointRepository)
//
//        let controller = UIHostingController(rootView: summary)
//        let window = TestHelpers.getKeyWindowVisible()
//        window.rootViewController = controller
//        tester().waitForView(withAccessibilityLabel: "Boarding")
//    }
//
//}
