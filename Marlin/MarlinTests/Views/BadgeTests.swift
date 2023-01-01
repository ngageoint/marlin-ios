//
//  BadgeTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 12/30/22.
//

import XCTest
import SwiftUI

@testable import Marlin

final class BadgeTests: XCTestCase {

    func testBadge() {
        let badge = Badge(count: 5)
        let controller = UIHostingController(rootView: badge)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "5.circle.fill")
    }
    
    func testCheckBadge() {
        let badge = CheckBadge(on: Binding.constant(true))
        let controller = UIHostingController(rootView: badge)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Check On")
    }
}
