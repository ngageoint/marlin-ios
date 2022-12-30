//
//  AboutViewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 12/29/22.
//

import XCTest
import SwiftUI

@testable import Marlin

final class AboutViewTests: XCTestCase {

    override func setUp() {
        UserDefaults.standard.setValue(false, forKey: "showMapScale")
        UserDefaults.standard.setValue(false, forKey: "flyoverMapsEnabled")
        UserDefaults.standard.setValue(false, forKey: "searchEnabled")
        UserDefaults.standard.setValue(false, forKey: "filterEnabled")
        UserDefaults.standard.setValue(false, forKey: "sortEnabled")
    }
    
    override func tearDown() {
    }
    
    func testTapDisclaimer() {
        let about = AboutView()

        let nav = NavigationView<AboutView> {
            about
        }
        
        let controller = UIHostingController(rootView: nav)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForTappableView(withAccessibilityLabel: "Disclaimer")
        tester().tapView(withAccessibilityLabel: "Disclaimer")

        tester().waitForView(withAccessibilityLabel: "Legal Disclaimer")
        tester().waitForView(withAccessibilityLabel: "Security Policy")
        tester().waitForView(withAccessibilityLabel: "Disclaimer of Liability")
        tester().waitForView(withAccessibilityLabel: "Disclaimer of Endorsement")

    }
    
    func testTapContactUs() {
        let about = AboutView()
        
        let nav = NavigationView<AboutView> {
            about
        }
        
        let controller = UIHostingController(rootView: nav)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForTappableView(withAccessibilityLabel: "Contact Us")
        // can't test that mail app opens on simulator, this is as good as it gets
    }
    
    func testDeveloperTools() {
        let version = Bundle.main.releaseVersionNumber ?? ""
        let buildVersion = Bundle.main.buildVersionNumber ?? ""
        
        let about = AboutView()
        
        let controller = UIHostingController(rootView: about)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Marlin v\(version)")
        tester().waitForView(withAccessibilityLabel: "Marlin")
        
        tester().tapView(withAccessibilityLabel: "Marlin")
        tester().tapView(withAccessibilityLabel: "Marlin")
        tester().tapView(withAccessibilityLabel: "Marlin")
        tester().tapView(withAccessibilityLabel: "Marlin")
        tester().tapView(withAccessibilityLabel: "Marlin")

        tester().waitForView(withAccessibilityLabel: "Marlin v\(version) (\(buildVersion))")
    }
}
