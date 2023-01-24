//
//  SubmitReportViewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/24/23.
//

import XCTest
import SwiftUI

@testable import Marlin

final class SubmitReportViewTests: XCTestCase {

    func testSubmitReportTypesVisible() throws {
        let submitReportView = SubmitReportView()
        
        let controller = UIHostingController(rootView: submitReportView)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        // this is the best we can do for now.  No way to intercept the link click
        tester().waitForView(withAccessibilityLabel: "Submit Anti-Shipping Activity Message (ASAM) Report")
        tester().waitForView(withAccessibilityLabel: "Submit Observer Report")
        tester().waitForView(withAccessibilityLabel: "Submit Mobile Offshore Drilling Unit (MODU) Movement Report")
        tester().waitForView(withAccessibilityLabel: "Submit US Navy Port Visit Report")
        tester().waitForView(withAccessibilityLabel: "Submit Ship Hostile Action Report")

    }

}
