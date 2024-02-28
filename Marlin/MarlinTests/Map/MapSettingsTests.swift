//
//  MapSettingsTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/12/23.
//

import XCTest
import MapKit
import Combine
import SwiftUI

@testable import Marlin

final class MapSettingsTests: XCTestCase {
    
    func testLoadingLightSettings() {
        UserDefaults.standard.actualRangeLights = false
        UserDefaults.standard.actualRangeSectorLights = false

        struct Container: View {
            @State var router: MarlinRouter = MarlinRouter()
            var body: some View {
                NavigationStack(path: $router.path) {
                    MapSettings()
                        .marlinRoutes()
                }
                .environmentObject(router)
            }
        }

        let container = Container()
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "Light Settings")
        tester().tapView(withAccessibilityLabel: "Light Settings")
        
        tester().waitForView(withAccessibilityLabel: "Show Sector Range Toggle")
        tester().tapView(withAccessibilityLabel: "Show Sector Range Toggle")
        XCTAssertTrue(UserDefaults.standard.actualRangeSectorLights)
        tester().tapView(withAccessibilityLabel: "Show Sector Range Toggle")
        XCTAssertFalse(UserDefaults.standard.actualRangeSectorLights)
        
        tester().waitForView(withAccessibilityLabel: "Show Light Range Toggle")
        tester().tapView(withAccessibilityLabel: "Show Light Range Toggle")
        XCTAssertTrue(UserDefaults.standard.actualRangeLights)
        tester().tapView(withAccessibilityLabel: "Show Light Range Toggle")
        XCTAssertFalse(UserDefaults.standard.actualRangeLights)
    }
    
    func testMapType() {
        UserDefaults.standard.set(true, forKey: "flyoverMapsEnabled")
        UserDefaults.standard.set(Int(MKMapType.standard.rawValue), forKey: "mapType")
        
        struct Container: View {
            @State var router: MarlinRouter = MarlinRouter()
            var body: some View {
                NavigationStack(path: $router.path) {
                    MapSettings()
                        .marlinRoutes()
                }
                .environmentObject(router)
            }
        }

        let container = Container()
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "Satellite Map")
        tester().tapView(withAccessibilityLabel: "Satellite Map")
        XCTAssertEqual(UserDefaults.standard.integer(forKey: "mapType"), Int(MKMapType.satellite.rawValue))
        
        tester().waitForView(withAccessibilityLabel: "Standard Map")
        tester().tapView(withAccessibilityLabel: "Standard Map")
        XCTAssertEqual(UserDefaults.standard.integer(forKey: "mapType"), Int(MKMapType.standard.rawValue))
        
        tester().waitForView(withAccessibilityLabel: "Hybrid Map")
        tester().tapView(withAccessibilityLabel: "Hybrid Map")
        XCTAssertEqual(UserDefaults.standard.integer(forKey: "mapType"), Int(MKMapType.hybrid.rawValue))
        
        tester().waitForView(withAccessibilityLabel: "Satellite Flyover Map")
        tester().tapView(withAccessibilityLabel: "Satellite Flyover Map")
        XCTAssertEqual(UserDefaults.standard.integer(forKey: "mapType"), Int(MKMapType.satelliteFlyover.rawValue))
        
        tester().waitForView(withAccessibilityLabel: "Hybrid Flyover Map")
        tester().tapView(withAccessibilityLabel: "Hybrid Flyover Map")
        XCTAssertEqual(UserDefaults.standard.integer(forKey: "mapType"), Int(MKMapType.hybridFlyover.rawValue))
        
        tester().waitForView(withAccessibilityLabel: "Muted Map")
        tester().tapView(withAccessibilityLabel: "Muted Map")
        XCTAssertEqual(UserDefaults.standard.integer(forKey: "mapType"), Int(MKMapType.mutedStandard.rawValue))
        
        tester().waitForView(withAccessibilityLabel: "Open Street Map")
        tester().tapView(withAccessibilityLabel: "Open Street Map")
        XCTAssertEqual(UserDefaults.standard.integer(forKey: "mapType"), Int(ExtraMapTypes.osm.rawValue))
    }
    
    func testGrids() {
        UserDefaults.standard.set(false, forKey: "showMGRS")
        UserDefaults.standard.set(false, forKey: "showGARS")
        
        struct Container: View {
            @State var router: MarlinRouter = MarlinRouter()
            var body: some View {
                NavigationStack(path: $router.path) {
                    MapSettings()
                        .marlinRoutes()
                }
                .environmentObject(router)
            }
        }

        let container = Container()
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "Toggle MGRS Grid")
        tester().tapView(withAccessibilityLabel: "Toggle MGRS Grid")
        XCTAssertEqual(true, UserDefaults.standard.bool(forKey: "showMGRS"))
        tester().tapView(withAccessibilityLabel: "Toggle MGRS Grid")
        XCTAssertEqual(false, UserDefaults.standard.bool(forKey: "showMGRS"))
        
        tester().waitForView(withAccessibilityLabel: "Toggle GARS Grid")
        tester().tapView(withAccessibilityLabel: "Toggle GARS Grid")
        XCTAssertEqual(true, UserDefaults.standard.bool(forKey: "showGARS"))
        tester().tapView(withAccessibilityLabel: "Toggle GARS Grid")
        XCTAssertEqual(false, UserDefaults.standard.bool(forKey: "showGARS"))
    }
}
