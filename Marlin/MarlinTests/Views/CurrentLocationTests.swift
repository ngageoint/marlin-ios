//
//  CurrentLocationTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/11/23.
//

import XCTest
import SwiftUI
import CoreLocation

@testable import Marlin

final class CurrentLocationTests: XCTestCase {
    
    func testShowCurrentLocationTap() {
        let mockLocationManager = MockCLLocationManager()
        let locationManager = LocationManager.shared(locationManager: mockLocationManager)
        locationManager.lastLocation = CLLocation(latitude: 1.0, longitude: 2.0)
        UserDefaults.standard.set(true, forKey: "showCurrentLocation")
        
        expectation(forNotification: .SnackbarNotification, object: nil) { notification in
            let snackbarNotification = try? XCTUnwrap(notification.object as? SnackbarNotification)
            XCTAssertTrue(((snackbarNotification?.snackbarModel?.message?.starts(with: "Location")) != nil))
            return true
        }
        
        let currentLocation = CurrentLocation()
            .environmentObject(locationManager)
        
        let controller = UIHostingController(rootView: currentLocation)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Current Location")
        tester().tapView(withAccessibilityLabel: "Current Location")
        
        waitForExpectations(timeout: 10)
    }
}
