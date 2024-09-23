////
////  LocationFilterTests.swift
////  MarlinTests
////
////  Created by Daniel Barela on 2/15/23.
////
//
import XCTest
import SwiftUI
import CoreLocation

@testable import Marlin

@MainActor
final class LocationFilterTests: XCTestCase {
    
    func testFilterChange() async throws {
        try XCTSkipIf(TestHelpers.DISABLE_UI_TESTS, "UI tests are disabled")
        class PassThrough: ObservableObject {
            var viewModel: DataSourcePropertyFilterViewModel?
            init() {
            }
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            
            @ObservedObject var filterViewModel = PersistedFilterViewModel(dataSource: MockDataSourceFilterable())
            @ObservedObject var dataSourcePropertyFilterViewModel =
 DataSourcePropertyFilterViewModel(dataSourceProperty:
 DataSourceProperty(name: "Location", key: "locationProperty", type: .location))

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
        let view = await Container(passThrough: passThrough)
            .environmentObject(mockLocationManager as LocationManager)
        
        let controller = await UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Location latitude input")
        tester().tapView(withAccessibilityLabel: "Location latitude input")
        tester().clearTextFromFirstResponder()
        tester().enterText("10.2", intoViewWithAccessibilityLabel: "Location latitude input")
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "Done")
        tester().tapView(withAccessibilityLabel: "Done")
        
        var lats = await passThrough.viewModel?.valueLatitudeString
        XCTAssertEqual(lats, "10.2")
        var lat = await passThrough.viewModel?.valueLatitude
        XCTAssertEqual(lat, 10.2)
        var valid = await passThrough.viewModel!.isValid
        XCTAssertFalse(valid)
        
        tester().waitForView(withAccessibilityLabel: "Location longitude input")
        tester().tapView(withAccessibilityLabel: "Location longitude input")
        tester().clearTextFromFirstResponder()
        tester().enterText("20.3", intoViewWithAccessibilityLabel: "Location longitude input")
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "Done")
        tester().tapView(withAccessibilityLabel: "Done")
        var lons = await passThrough.viewModel?.valueLongitudeString
        XCTAssertEqual(lons, "20.3")
        var lon = await passThrough.viewModel?.valueLongitude
        XCTAssertEqual(lon, 20.3)
        var comparison = await passThrough.viewModel?.selectedComparison
        XCTAssertEqual(comparison, .closeTo)
        var valid2 = await passThrough.viewModel!.isValid
        XCTAssertFalse(valid2)
        
        tester().waitForView(withAccessibilityLabel: "Location distance input")
        tester().tapView(withAccessibilityLabel: "Location distance input")
        tester().clearTextFromFirstResponder()
        tester().enterText("500", intoViewWithAccessibilityLabel: "Location distance input")
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "Done")
        tester().tapView(withAccessibilityLabel: "Done")
        var int = await passThrough.viewModel?.valueInt
        XCTAssertEqual(int, 500)
        var valid3 = await passThrough.viewModel!.isValid
        XCTAssertTrue(valid3)
    }
    
    func xtestSetLocationWithMap() async throws {
        try XCTSkipIf(TestHelpers.DISABLE_UI_TESTS, "UI tests are disabled")
        class PassThrough: ObservableObject {
            var viewModel: DataSourcePropertyFilterViewModel?
            init() {
            }
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            
            @ObservedObject var filterViewModel = PersistedFilterViewModel(dataSource: MockDataSourceFilterable())
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
        let view = await Container(passThrough: passThrough)
            .environmentObject(mockLocationManager as LocationManager)
        
        let controller = await UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForTappableView(withAccessibilityLabel: "Location map input")
        // tap to activate
        // TODO: tap to set location I don't understand why this isn't working....
        tester().tapView(withAccessibilityLabel: "Location map input")
        tester().wait(forTimeInterval: 2)
        tester().waitForView(withAccessibilityLabel: "Location map input2")
        var lats = await passThrough.viewModel?.valueLatitudeString
        var lat = await passThrough.viewModel?.valueLatitude
        var lons = await passThrough.viewModel?.valueLongitudeString
        var lon = await passThrough.viewModel?.valueLongitude
        var valid = await passThrough.viewModel!.isValid
        
        XCTAssertEqual(lats, "0.0")
        XCTAssertEqual(lat, 0.0)
        XCTAssertEqual(lons, "0.0")
        XCTAssertEqual(lon, 0.0)
        XCTAssertFalse(valid)
        
        tester().waitForView(withAccessibilityLabel: "Location distance input")
        tester().tapView(withAccessibilityLabel: "Location distance input")
        tester().clearTextFromFirstResponder()
        tester().enterText("500", intoViewWithAccessibilityLabel: "Location distance input")
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "Done")
        tester().tapView(withAccessibilityLabel: "Done")
        var int = await passThrough.viewModel?.valueInt
        XCTAssertEqual(int, 500)
        var valid2 = await passThrough.viewModel!.isValid
        XCTAssertTrue(valid2)
    }
    
    func testInvalid() async throws {
        try XCTSkipIf(TestHelpers.DISABLE_UI_TESTS, "UI tests are disabled")
        class PassThrough: ObservableObject {
            var viewModel: DataSourcePropertyFilterViewModel?
            init() {
            }
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            
            @ObservedObject var filterViewModel = PersistedFilterViewModel(dataSource: MockDataSourceFilterable())
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
        let view = await Container(passThrough: passThrough)
            .environmentObject(mockLocationManager as LocationManager)
        
        let controller = await UIHostingController(rootView: view)
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
        var lats = await passThrough.viewModel?.valueLatitudeString
        var lat = await passThrough.viewModel?.valueLatitude
        var valid = await passThrough.viewModel!.isValid
        XCTAssertEqual(lats, "Turtle")
        XCTAssertEqual(lat, nil)
        XCTAssertFalse(valid)
        
        tester().waitForView(withAccessibilityLabel: "Location longitude input")
        tester().tapView(withAccessibilityLabel: "Location longitude input")
        tester().clearTextFromFirstResponder()
        tester().enterText("tiger", intoViewWithAccessibilityLabel: "Location longitude input")
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "Done")
        tester().tapView(withAccessibilityLabel: "Done")
        tester().waitForView(withAccessibilityLabel: "Invalid Longitude")
        var lons = await passThrough.viewModel?.valueLongitudeString
        var lon = await passThrough.viewModel?.valueLongitude
        var comparison = await passThrough.viewModel?.selectedComparison
        valid = await passThrough.viewModel!.isValid
        XCTAssertEqual(lons, "tiger")
        XCTAssertEqual(lon, nil)
        XCTAssertEqual(comparison, .closeTo)
        XCTAssertFalse(valid)
        
        tester().waitForView(withAccessibilityLabel: "Location distance input")
        tester().tapView(withAccessibilityLabel: "Location distance input")
        tester().clearTextFromFirstResponder()
        tester().enterText("purple", intoViewWithAccessibilityLabel: "Location distance input")
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "Done")
        tester().tapView(withAccessibilityLabel: "Done")
        
        var int = await passThrough.viewModel?.valueInt
        XCTAssertEqual(int, nil)
        valid = await passThrough.viewModel!.isValid
        XCTAssertFalse(valid)
    }
    
    func testNearMeNoLocation() async {
        class PassThrough: ObservableObject {
            var viewModel: DataSourcePropertyFilterViewModel?
            init() {
            }
        }
        
        struct Container: View {
            @EnvironmentObject var locationManager: LocationManager
            @ObservedObject var passThrough: PassThrough
            
            @ObservedObject var filterViewModel = PersistedFilterViewModel(dataSource: MockDataSourceFilterable())
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
        let view = await Container(passThrough: passThrough)
            .environmentObject(mockLocationManager as LocationManager)
        
        let controller = await UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Location latitude input")
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Location longitude input")
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Location distance input")
        tester().waitForView(withAccessibilityLabel: "No current location")
        var valid = await passThrough.viewModel!.isValid
        XCTAssertFalse(valid)
    }
    
    func testNearMe() async throws {
        try XCTSkipIf(TestHelpers.DISABLE_UI_TESTS, "UI tests are disabled")
        class PassThrough: ObservableObject {
            var viewModel: DataSourcePropertyFilterViewModel?
            init() {
            }
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            
            @ObservedObject var filterViewModel = PersistedFilterViewModel(dataSource: MockDataSourceFilterable())
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
        let view = await Container(passThrough: passThrough)
            .environmentObject(mockLocationManager as LocationManager)
        
        let controller = await UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Location latitude input")
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Location longitude input")
        tester().waitForView(withAccessibilityLabel: "Location distance input")
        var valid = await passThrough.viewModel!.isValid
        XCTAssertFalse(valid)
        
        tester().tapView(withAccessibilityLabel: "Location distance input")
        tester().clearTextFromFirstResponder()
        tester().enterText("500", intoViewWithAccessibilityLabel: "Location distance input")
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "Done")
        tester().tapView(withAccessibilityLabel: "Done")
        var int = await passThrough.viewModel?.valueInt
        XCTAssertEqual(int, 500)
        valid = await passThrough.viewModel!.isValid
        XCTAssertTrue(valid)
    }

    func testBounds() async throws {
        try XCTSkipIf(TestHelpers.DISABLE_UI_TESTS, "UI tests are disabled")
        class PassThrough: ObservableObject {
            var viewModel: DataSourcePropertyFilterViewModel?
            init() {
            }
        }

        struct Container: View {
            @ObservedObject var passThrough: PassThrough

            @ObservedObject var filterViewModel = PersistedFilterViewModel(dataSource: MockDataSourceFilterable())
            @ObservedObject var dataSourcePropertyFilterViewModel =
            DataSourcePropertyFilterViewModel(dataSourceProperty:
                                                DataSourceProperty(name: "Location", key: "locationProperty", type: .location))

            init(passThrough: PassThrough) {
                self.passThrough = passThrough
                self.passThrough.viewModel = dataSourcePropertyFilterViewModel
            }

            var body: some View {
                NavigationView {
                    LocationFilter(filterViewModel: filterViewModel, viewModel: dataSourcePropertyFilterViewModel)
                }
                .onAppear {
                    dataSourcePropertyFilterViewModel.selectedComparison = .bounds
                }
            }
        }

        let mockCLLocation = MockCLLocationManager()
        let mockLocationManager = MockLocationManager(locationManager: mockCLLocation)
        mockLocationManager.currentNavArea = nil

        let passThrough = PassThrough()
        let view = await Container(passThrough: passThrough)
            .environmentObject(mockLocationManager as LocationManager)

        let controller = await UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Location min latitude input")
        tester().tapView(withAccessibilityLabel: "Location min latitude input")
        tester().clearTextFromFirstResponder()
        tester().enterText("10.2", intoViewWithAccessibilityLabel: "Location min latitude input")
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "Done")
        tester().tapView(withAccessibilityLabel: "Done")
        var minlats = await passThrough.viewModel?.valueMinLatitudeString
        var minLat = await passThrough.viewModel?.valueMinLatitude
        var valid = await passThrough.viewModel!.isValid
        XCTAssertEqual(minlats, "10.2")
        XCTAssertEqual(minLat, 10.2)
        XCTAssertFalse(valid)

        tester().waitForView(withAccessibilityLabel: "Location max latitude input")
        tester().tapView(withAccessibilityLabel: "Location max latitude input")
        tester().clearTextFromFirstResponder()
        tester().enterText("10.4", intoViewWithAccessibilityLabel: "Location max latitude input")
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "Done")
        tester().tapView(withAccessibilityLabel: "Done")
        var maxLats = await passThrough.viewModel?.valueMaxLatitudeString
        var maxLat = await passThrough.viewModel?.valueMaxLatitude
        valid = await passThrough.viewModel!.isValid
        XCTAssertEqual(maxLats, "10.4")
        XCTAssertEqual(maxLat, 10.4)
        XCTAssertFalse(valid)

        tester().waitForView(withAccessibilityLabel: "Location min longitude input")
        tester().tapView(withAccessibilityLabel: "Location min longitude input")
        tester().clearTextFromFirstResponder()
        tester().enterText("20.3", intoViewWithAccessibilityLabel: "Location min longitude input")
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "Done")
        tester().tapView(withAccessibilityLabel: "Done")
        var minLons = await passThrough.viewModel?.valueMinLongitudeString
        var minLon = await passThrough.viewModel?.valueMinLongitude
        valid = await passThrough.viewModel!.isValid
        XCTAssertEqual(minLons, "20.3")
        XCTAssertEqual(minLon, 20.3)
        XCTAssertFalse(valid)

        tester().waitForView(withAccessibilityLabel: "Location max longitude input")
        tester().tapView(withAccessibilityLabel: "Location max longitude input")
        tester().clearTextFromFirstResponder()
        tester().enterText("20.5", intoViewWithAccessibilityLabel: "Location max longitude input")
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "Done")
        tester().tapView(withAccessibilityLabel: "Done")
        var maxLons = await passThrough.viewModel?.valueMaxLongitudeString
        var maxLon = await passThrough.viewModel?.valueMaxLongitude
        valid = await passThrough.viewModel!.isValid
        XCTAssertEqual(maxLons, "20.5")
        XCTAssertEqual(maxLon, 20.5)
        XCTAssertTrue(valid)
    }
}
