//
//  AboutCellTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 12/29/22.
//

import XCTest
import SwiftUI
@testable import Marlin

final class AboutCellTests: XCTestCase {

    func testLoading() {
        let about = AboutCell()
        let controller = UIHostingController(rootView: about)
        let window = TestHelpers.getKeyWindowVisible()
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

}
