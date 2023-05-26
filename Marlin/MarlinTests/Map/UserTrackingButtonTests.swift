//
//  UserTrackingButtonTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/31/23.
//

import XCTest
import SwiftUI
import Combine
import MapKit

@testable import Marlin

final class UserTrackingButtonTests: XCTestCase {

    override func setUp() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults()
    }
    
    override func tearDown() {
    }

    func testChangeState() {
        UserDefaults.standard.set(Int(MKUserTrackingMode.none.rawValue), forKey: "userTrackingMode")

        var mockLocationManager = MockCLLocationManager()
        var locationManager = LocationManager.shared(locationManager: mockLocationManager)
        locationManager.locationStatus = .authorizedAlways

        class PassThrough {
            var userTrackingMode: MKUserTrackingMode?
        }
        
        struct Container: View {
            @StateObject var mapState: MapState = MapState()
            @State var filterOpen: Bool = false
            
            var passThrough: PassThrough
            var mixins: [MapMixin] = []
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                ZStack {
                    UserTrackingButton(mapState: mapState)
                        
                }
                .onChange(of: mapState.userTrackingMode) { newValue in
                    passThrough.userTrackingMode = MKUserTrackingMode(rawValue: newValue)
                }
            }
        }
        let appState = AppState()
        let passThrough = PassThrough()
        
        let container = Container(passThrough: passThrough)
            .environmentObject(locationManager)
            .environmentObject(appState)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
                
        tester().waitForView(withAccessibilityLabel: "Tracking none")
        XCTAssertEqual(UserDefaults.standard.integer(forKey: "userTrackingMode"), MKUserTrackingMode.none.rawValue)
        tester().tapView(withAccessibilityLabel: "Tracking none")
        tester().waitForView(withAccessibilityLabel: "Tracking follow")
        XCTAssertEqual(UserDefaults.standard.integer(forKey: "userTrackingMode"), MKUserTrackingMode.follow.rawValue)
        tester().tapView(withAccessibilityLabel: "Tracking follow")
        tester().waitForView(withAccessibilityLabel: "Tracking follow with heading")
        XCTAssertEqual(UserDefaults.standard.integer(forKey: "userTrackingMode"), MKUserTrackingMode.followWithHeading.rawValue)
        tester().tapView(withAccessibilityLabel: "Tracking follow with heading")
        tester().waitForView(withAccessibilityLabel: "Tracking none")
        XCTAssertEqual(UserDefaults.standard.integer(forKey: "userTrackingMode"), MKUserTrackingMode.none.rawValue)
    }
    
    func testLocationNotAuthorized() {
        UserDefaults.standard.set(Int(MKUserTrackingMode.none.rawValue), forKey: "userTrackingMode")
        var mockLocationManager = MockCLLocationManager()
        var locationManager = LocationManager.shared(locationManager: mockLocationManager)
        locationManager.locationStatus = .notDetermined
        
        class PassThrough: ObservableObject {
            var userTrackingMode: MKUserTrackingMode?
            @Published var newUserTrackingMode: MKUserTrackingMode = .none
        }
        
        struct Container: View {
            @StateObject var mapState: MapState = MapState()
            @State var filterOpen: Bool = false
            
            @ObservedObject var passThrough: PassThrough
            var mixins: [MapMixin] = []
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                ZStack {
                    UserTrackingButton(mapState: mapState)
                }
                .onChange(of: mapState.userTrackingMode) { newValue in
                    passThrough.userTrackingMode = MKUserTrackingMode(rawValue: newValue)
                }
                .onChange(of: passThrough.newUserTrackingMode) { newValue in
                    mapState.userTrackingMode = newValue.rawValue
                }
            }
        }
        let appState = AppState()
        let passThrough = PassThrough()
        
        let container = Container(passThrough: passThrough)
            .environmentObject(locationManager)
            .environmentObject(appState)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "Tracking none Unauthorized")
        XCTAssertEqual(UserDefaults.standard.integer(forKey: "userTrackingMode"), MKUserTrackingMode.none.rawValue)
        tester().tapView(withAccessibilityLabel: "Tracking none Unauthorized")
        
        tester().waitForView(withAccessibilityLabel: "Location Services Disabled")
        tester().waitForView(withAccessibilityLabel: "Cancel")
        tester().tapView(withAccessibilityLabel: "Cancel")
        
        passThrough.newUserTrackingMode = MKUserTrackingMode.followWithHeading
        
        tester().waitForView(withAccessibilityLabel: "Tracking follow with heading Unauthorized")
        
        locationManager.locationStatus = .authorizedAlways
        
        tester().waitForView(withAccessibilityLabel: "Tracking follow with heading")
    }
}
