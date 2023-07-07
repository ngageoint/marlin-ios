//
//  LocationFilterTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/15/23.
//

import XCTest
import SwiftUI
import CoreLocation

@testable import Marlin

final class LocationFilterTests: XCTestCase {
    
    func testFilterChange() {
        class PassThrough: ObservableObject {
            var viewModel: DataSourcePropertyFilterViewModel?
            init() {
            }
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            
            @ObservedObject var filterViewModel = PersistedFilterViewModel(dataSource: MockDataSource.self)
            @ObservedObject var dataSourcePropertyFilterViewModel = DataSourcePropertyFilterViewModel(dataSourceProperty: DataSourceProperty(name: "Location", key: "locationProperty", type: .location))
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
                self.passThrough.viewModel = dataSourcePropertyFilterViewModel
            }
            
            var body: some View {
                NavigationView {
                    LocationFilter(filterViewModel: filterViewModel, viewModel: dataSourcePropertyFilterViewModel)
                }
                .onAppear {
                    dataSourcePropertyFilterViewModel.selectedComparison = .closeTo
                }
            }
        }
        
        let mockCLLocation = MockCLLocationManager()
        let mockLocationManager = MockLocationManager(locationManager: mockCLLocation)
        mockLocationManager.currentNavArea = nil
        
        let passThrough = PassThrough()
        let view = Container(passThrough: passThrough)
            .environmentObject(mockLocationManager as LocationManager)
        
        let controller = UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Location latitude input")
        tester().tapView(withAccessibilityLabel: "Location latitude input")
        tester().clearTextFromFirstResponder()
        tester().enterText("10.2", intoViewWithAccessibilityLabel: "Location latitude input")
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "Done")
        tester().tapView(withAccessibilityLabel: "Done")
        XCTAssertEqual(passThrough.viewModel?.valueLatitudeString, "10.2")
        XCTAssertEqual(passThrough.viewModel?.valueLatitude, 10.2)
        XCTAssertFalse(passThrough.viewModel!.isValid)
        
        tester().waitForView(withAccessibilityLabel: "Location longitude input")
        tester().tapView(withAccessibilityLabel: "Location longitude input")
        tester().clearTextFromFirstResponder()
        tester().enterText("20.3", intoViewWithAccessibilityLabel: "Location longitude input")
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "Done")
        tester().tapView(withAccessibilityLabel: "Done")
        XCTAssertEqual(passThrough.viewModel?.valueLongitudeString, "20.3")
        XCTAssertEqual(passThrough.viewModel?.valueLongitude, 20.3)
        XCTAssertEqual(passThrough.viewModel?.selectedComparison, .closeTo)
        XCTAssertFalse(passThrough.viewModel!.isValid)
        
        tester().waitForView(withAccessibilityLabel: "Location distance input")
        tester().tapView(withAccessibilityLabel: "Location distance input")
        tester().clearTextFromFirstResponder()
        tester().enterText("500", intoViewWithAccessibilityLabel: "Location distance input")
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "Done")
        tester().tapView(withAccessibilityLabel: "Done")
        XCTAssertEqual(passThrough.viewModel?.valueInt, 500)
        XCTAssertTrue(passThrough.viewModel!.isValid)
    }
    
    func xtestSetLocationWithMap() {
        class PassThrough: ObservableObject {
            var viewModel: DataSourcePropertyFilterViewModel?
            init() {
            }
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            
            @ObservedObject var filterViewModel = PersistedFilterViewModel(dataSource: MockDataSource.self)
            @ObservedObject var dataSourcePropertyFilterViewModel = DataSourcePropertyFilterViewModel(dataSourceProperty: DataSourceProperty(name: "Location", key: "locationProperty", type: .location))
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
                self.passThrough.viewModel = dataSourcePropertyFilterViewModel
            }
            
            var body: some View {
                NavigationView {
                    LocationFilter(filterViewModel: filterViewModel, viewModel: dataSourcePropertyFilterViewModel)
                }
                .onAppear {
                    dataSourcePropertyFilterViewModel.selectedComparison = .closeTo
                }
            }
        }
        
        let mockCLLocation = MockCLLocationManager()
        let mockLocationManager = MockLocationManager(locationManager: mockCLLocation)
        mockLocationManager.currentNavArea = nil
        
        let passThrough = PassThrough()
        let view = Container(passThrough: passThrough)
            .environmentObject(mockLocationManager as LocationManager)
        
        let controller = UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForTappableView(withAccessibilityLabel: "Location map input")
        // tap to activate
        tester().tapView(withAccessibilityLabel: "Location map input")
        tester().wait(forTimeInterval: 2)
        // TODO: tap to set location I don't understand why this isn't working....
        tester().waitForView(withAccessibilityLabel: "Location map input2")
        XCTAssertEqual(passThrough.viewModel?.valueLatitudeString, "0.0")
        XCTAssertEqual(passThrough.viewModel?.valueLatitude, 0.0)
        XCTAssertEqual(passThrough.viewModel?.valueLongitudeString, "0.0")
        XCTAssertEqual(passThrough.viewModel?.valueLongitude, 0.0)
        XCTAssertFalse(passThrough.viewModel!.isValid)
        
        tester().waitForView(withAccessibilityLabel: "Location distance input")
        tester().tapView(withAccessibilityLabel: "Location distance input")
        tester().clearTextFromFirstResponder()
        tester().enterText("500", intoViewWithAccessibilityLabel: "Location distance input")
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "Done")
        tester().tapView(withAccessibilityLabel: "Done")
        XCTAssertEqual(passThrough.viewModel?.valueInt, 500)
        XCTAssertTrue(passThrough.viewModel!.isValid)
    }
    
    func testInvalid() {
        class PassThrough: ObservableObject {
            var viewModel: DataSourcePropertyFilterViewModel?
            init() {
            }
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            
            @ObservedObject var filterViewModel = PersistedFilterViewModel(dataSource: MockDataSource.self)
            @ObservedObject var dataSourcePropertyFilterViewModel = DataSourcePropertyFilterViewModel(dataSourceProperty: DataSourceProperty(name: "Location", key: "locationProperty", type: .location))
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
                self.passThrough.viewModel = dataSourcePropertyFilterViewModel
            }
            
            var body: some View {
                NavigationView {
                    LocationFilter(filterViewModel: filterViewModel, viewModel: dataSourcePropertyFilterViewModel)
                }
                .onAppear {
                    dataSourcePropertyFilterViewModel.selectedComparison = .closeTo
                }
            }
        }
        let mockCLLocation = MockCLLocationManager()
        let mockLocationManager = MockLocationManager(locationManager: mockCLLocation)
        mockLocationManager.currentNavArea = nil
        
        let passThrough = PassThrough()
        let view = Container(passThrough: passThrough)
            .environmentObject(mockLocationManager as LocationManager)
        
        let controller = UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Location latitude input")
        tester().tapView(withAccessibilityLabel: "Location latitude input")
        tester().clearTextFromFirstResponder()
        tester().enterText("Turtle", intoViewWithAccessibilityLabel: "Location latitude input")
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "Done")
        tester().tapView(withAccessibilityLabel: "Done")
        tester().waitForView(withAccessibilityLabel: "Invalid Latitude")
        XCTAssertEqual(passThrough.viewModel?.valueLatitudeString, "Turtle")
        XCTAssertEqual(passThrough.viewModel?.valueLatitude, nil)
        XCTAssertFalse(passThrough.viewModel!.isValid)
        
        tester().waitForView(withAccessibilityLabel: "Location longitude input")
        tester().tapView(withAccessibilityLabel: "Location longitude input")
        tester().clearTextFromFirstResponder()
        tester().enterText("tiger", intoViewWithAccessibilityLabel: "Location longitude input")
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "Done")
        tester().tapView(withAccessibilityLabel: "Done")
        tester().waitForView(withAccessibilityLabel: "Invalid Longitude")
        XCTAssertEqual(passThrough.viewModel?.valueLongitudeString, "tiger")
        XCTAssertEqual(passThrough.viewModel?.valueLongitude, nil)
        XCTAssertEqual(passThrough.viewModel?.selectedComparison, .closeTo)
        XCTAssertFalse(passThrough.viewModel!.isValid)
        
        tester().waitForView(withAccessibilityLabel: "Location distance input")
        tester().tapView(withAccessibilityLabel: "Location distance input")
        tester().clearTextFromFirstResponder()
        tester().enterText("purple", intoViewWithAccessibilityLabel: "Location distance input")
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "Done")
        tester().tapView(withAccessibilityLabel: "Done")
        
        XCTAssertEqual(passThrough.viewModel?.valueInt, nil)
        XCTAssertFalse(passThrough.viewModel!.isValid)
    }
    
    func testNearMeNoLocation() {
        class PassThrough: ObservableObject {
            var viewModel: DataSourcePropertyFilterViewModel?
            init() {
            }
        }
        
        struct Container: View {
            @EnvironmentObject var locationManager: LocationManager
            @ObservedObject var passThrough: PassThrough
            
            @ObservedObject var filterViewModel = PersistedFilterViewModel(dataSource: MockDataSource.self)
            @ObservedObject var dataSourcePropertyFilterViewModel = DataSourcePropertyFilterViewModel(dataSourceProperty: DataSourceProperty(name: "Location", key: "locationProperty", type: .location))
            
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
                self.passThrough.viewModel = dataSourcePropertyFilterViewModel
            }
            
            var body: some View {
                NavigationView {
                    LocationFilter(filterViewModel: filterViewModel, viewModel: dataSourcePropertyFilterViewModel)
                        .environmentObject(locationManager)
                }
                .onAppear {
                    dataSourcePropertyFilterViewModel.locationManager = locationManager
                    dataSourcePropertyFilterViewModel.selectedComparison = .nearMe
                }
            }
        }
        
        let mockCLLocation = MockCLLocationManager()
        let mockLocationManager = LocationManager.shared(locationManager: mockCLLocation)
        mockLocationManager.currentNavArea = nil
        mockLocationManager.lastLocation = nil
        
        let passThrough = PassThrough()
        let view = Container(passThrough: passThrough)
            .environmentObject(mockLocationManager as LocationManager)
        
        let controller = UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Location latitude input")
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Location longitude input")
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Location distance input")
        tester().waitForView(withAccessibilityLabel: "No current location")
        XCTAssertFalse(passThrough.viewModel!.isValid)
    }
    
    func testNearMe() {
        class PassThrough: ObservableObject {
            var viewModel: DataSourcePropertyFilterViewModel?
            init() {
            }
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            
            @ObservedObject var filterViewModel = PersistedFilterViewModel(dataSource: MockDataSource.self)
            @ObservedObject var dataSourcePropertyFilterViewModel: DataSourcePropertyFilterViewModel
            
            var locationManager: LocationManager
            
            init(passThrough: PassThrough) {
                var mockLocationManager = MockCLLocationManager()
                locationManager = LocationManager.shared(locationManager: mockLocationManager)
                self.passThrough = passThrough
                locationManager.lastLocation = CLLocation(latitude: 12, longitude: 14)
                self.dataSourcePropertyFilterViewModel = DataSourcePropertyFilterViewModel(dataSourceProperty: DataSourceProperty(name: "Location", key: "locationProperty", type: .location))
                dataSourcePropertyFilterViewModel.locationManager = locationManager
                self.passThrough.viewModel = dataSourcePropertyFilterViewModel
            }
            
            var body: some View {
                NavigationView {
                    LocationFilter(filterViewModel: filterViewModel, viewModel: dataSourcePropertyFilterViewModel)
                        .environmentObject(locationManager)
                }
                .onAppear {
                    dataSourcePropertyFilterViewModel.selectedComparison = .nearMe
                }
            }
        }
        let mockCLLocation = MockCLLocationManager()
        let mockLocationManager = MockLocationManager(locationManager: mockCLLocation)
        mockLocationManager.currentNavArea = nil
        
        let passThrough = PassThrough()
        let view = Container(passThrough: passThrough)
            .environmentObject(mockLocationManager as LocationManager)
        
        let controller = UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Location latitude input")
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Location longitude input")
        tester().waitForView(withAccessibilityLabel: "Location distance input")
        XCTAssertFalse(passThrough.viewModel!.isValid)
        
        tester().tapView(withAccessibilityLabel: "Location distance input")
        tester().clearTextFromFirstResponder()
        tester().enterText("500", intoViewWithAccessibilityLabel: "Location distance input")
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "Done")
        tester().tapView(withAccessibilityLabel: "Done")
        XCTAssertEqual(passThrough.viewModel?.valueInt, 500)
        XCTAssertTrue(passThrough.viewModel!.isValid)
    }
}
