//
//  ModuDetailViewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/19/23.
//

import XCTest
import Combine
import SwiftUI

@testable import Marlin

final class ModuDetailViewTests: XCTestCase {

    func testLoading() {
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

        let localDataSource = ModuStaticLocalDataSource()
        InjectedValues[\.moduLocalDataSource] = localDataSource
        
        let remoteDataSource = ModuRemoteDataSource()
        InjectedValues[\.moduRemoteDataSource] = remoteDataSource
        
        localDataSource.list = [modu]
        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        InjectedValues[\.bookmarkLocalDataSource] = bookmarkLocalDataSource
        
        let routeWaypointRepository = RouteWaypointRepository(localDataSource: RouteWaypointStaticLocalDataSource())
        let detailView = ModuDetailView(name: "ABAN II")
            .environmentObject(routeWaypointRepository)

        let controller = UIHostingController(rootView: detailView)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "ABAN II")
        tester().waitForView(withAccessibilityLabel: modu.dateString)
        tester().waitForView(withAccessibilityLabel: modu.rigStatus)
        tester().waitForView(withAccessibilityLabel: modu.specialStatus)
        tester().waitForView(withAccessibilityLabel: "\(modu.distance!)")
        tester().waitForView(withAccessibilityLabel: modu.navArea)
        tester().waitForView(withAccessibilityLabel: "\(modu.subregion!)")
    }

    func xtestButtons() {
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

        let localDataSource = ModuStaticLocalDataSource()
        InjectedValues[\.moduLocalDataSource] = localDataSource
        
        let remoteDataSource = ModuRemoteDataSource()
        InjectedValues[\.moduRemoteDataSource] = remoteDataSource
        
        localDataSource.list = [modu]
        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        InjectedValues[\.bookmarkLocalDataSource] = bookmarkLocalDataSource
        
        let routeWaypointRepository = RouteWaypointRepository(localDataSource: RouteWaypointStaticLocalDataSource())
        let detailView = ModuDetailView(name: "ABAN II")
            .environmentObject(routeWaypointRepository)

        let controller = UIHostingController(rootView: detailView)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "ABAN II")
        tester().waitForView(withAccessibilityLabel: modu.dateString)

        // TODO: this is untestable b/c KIF thinks the button can become first responder so it fails to tap
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
            let modu = tapNotification.items as! [ModuModel]
            XCTAssertEqual(modu.count, 1)
            XCTAssertEqual(modu[0].name, "ABAN II")
            return true
        }
        tester().tapView(withAccessibilityLabel: "focus")
        
        waitForExpectations(timeout: 10, handler: nil)
        
        tester().waitForView(withAccessibilityLabel: "share")
        tester().tapView(withAccessibilityLabel: "share")
        
        tester().waitForTappableView(withAccessibilityLabel: "dismiss popup")
        tester().tapScreen(at: CGPoint(x:20, y:20))
        
        BookmarkHelper().verifyBookmarkButton(bookmarkable: modu)
    }
}
