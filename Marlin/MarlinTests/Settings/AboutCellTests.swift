//
//  AboutCellTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 12/29/22.
//

import XCTest
import SwiftUI
import KIF

@testable import Marlin

final class AboutCellTests: KIFTestCase {
    
    override func setUp() async throws {
        if TestHelpers.DISABLE_UI_TESTS {
            throw XCTSkip("UI tests are disabled")
        }
        await TestHelpers.asyncGetKeyWindowVisible()
    }
    
    func testLoadingAgain() {
        let about = AboutCell()
        let controller = UIHostingController(rootView: about)
        print("xxx request the window")
        let window = TestHelpers.getKeyWindowVisible()
        print("ok got it \(window)")
        window.rootViewController = controller
        tester().waitForTappableView(withAccessibilityLabel: "About")
        
        expectation(forNotification: .SwitchTabs,
                    object: nil) { notification in
            print("Notification \(notification)")
            XCTAssertEqual(notification.object as? String, "settings")
            return true
        }
        tester().tapView(withAccessibilityLabel: "About")
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testLoading()  {
        let about = AboutCell()
        let controller = UIHostingController(rootView: about)
        print("xxx request the window")
        let window = TestHelpers.getKeyWindowVisible()
        print("ok got it \(window)")
        window.rootViewController = controller
        tester().waitForTappableView(withAccessibilityLabel: "About")
        
        expectation(forNotification: .SwitchTabs,
                    object: nil) { notification in
            print("Notification \(notification)")
            XCTAssertEqual(notification.object as? String, "settings")
            return true
        }
        tester().tapView(withAccessibilityLabel: "About")
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    

//    @MainActor
//    func testLoadingAgain() async {
//        let about = AboutCell()
//        let controller = UIHostingController(rootView: about)
//        print("xxx request the window")
//        let window = await TestHelpers.asyncGetKeyWindowVisible()
//        print("ok got it \(window)")
//        window.rootViewController = controller
//        tester().waitForTappableView(withAccessibilityLabel: "About")
//
//        expectation(forNotification: .SwitchTabs,
//                    object: nil) { notification in
//            print("Notification \(notification)")
//            XCTAssertEqual(notification.object as? String, "settings")
//            return true
//        }
//        tester().tapView(withAccessibilityLabel: "About")
//
//        waitForExpectations(timeout: 10, handler: nil)
//    }
//
//    @MainActor
//    func testLoading() async {
//        let about = AboutCell()
//        let controller = UIHostingController(rootView: about)
//        print("xxx request the window")
//        let window = await TestHelpers.asyncGetKeyWindowVisible()
//        print("ok got it \(window)")
//        window.rootViewController = controller
//        tester().waitForTappableView(withAccessibilityLabel: "About")
//
//        expectation(forNotification: .SwitchTabs,
//                    object: nil) { notification in
//            print("Notification \(notification)")
//            XCTAssertEqual(notification.object as? String, "settings")
//            return true
//        }
//        tester().tapView(withAccessibilityLabel: "About")
//
//        waitForExpectations(timeout: 10, handler: nil)
//    }

}
