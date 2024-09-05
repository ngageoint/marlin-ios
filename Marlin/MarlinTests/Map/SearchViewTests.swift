//
//  SearchViewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/14/23.
//

import XCTest
import Combine
import OHHTTPStubs
import CoreData
import SwiftUI
import MapKit

@testable import Marlin

final class SearchViewTests: XCTestCase {

    override func setUp() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults()

        MKLocalSearchMock.results = nil
    }
    override func tearDown() {
        HTTPStubs.removeAllStubs()
        MKLocalSearchMock.results = nil
    }
    
    func testExpandCollapse() throws {
        struct Container: View {
            @StateObject var mapState: MapState = MapState()

            var body: some View {
                NavigationView {
                    SearchView(mapState: mapState)
                }
                .environmentObject(SearchRepository(native: NativeSearchProvider<MKLocalSearchMock>()))
            }
        }
        let container = Container()

        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "Expand Search")
        tester().tapView(withAccessibilityLabel: "Expand Search")
        
        tester().waitForView(withAccessibilityLabel: "Collapse Search")
        tester().tapView(withAccessibilityLabel: "Collapse Search")
        
        tester().waitForView(withAccessibilityLabel: "Expand Search")
    }

    func testSearch() throws {
        class PassThrough: ObservableObject {
            var mapState: MapState?
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            @StateObject var mapState: MapState = MapState()
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationView {
                    SearchView(mapState: mapState)
                }
                .environmentObject(SearchRepository(native: NativeSearchProvider<MKLocalSearchMock>()))
                .onAppear {
                    self.passThrough.mapState = mapState
                }
            }
        }
        let passThrough = PassThrough()
        
        let container = Container(passThrough: passThrough)

        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "Expand Search")
        tester().tapView(withAccessibilityLabel: "Expand Search")
        
        tester().waitForView(withAccessibilityLabel: "Collapse Search")
        
        
        let e = XCTNSPredicateExpectation(predicate: NSPredicate(block: { _, _ in
            return passThrough.mapState?.searchResults?.count == 1
        }), object: passThrough.mapState)
        
        tester().enterText("search", intoViewWithAccessibilityLabel: "Search Field")
         
        // wait for the debounce
        wait(for: [e], timeout: 5)
        XCTAssertEqual(MKLocalSearchMock.searchRequest?.naturalLanguageQuery, "search")
        tester().waitForView(withAccessibilityLabel: "United States")
        tester().waitForView(withAccessibilityLabel: "Location")
        expectation(forNotification: .SnackbarNotification,
                    object: nil) { notification in
            let model = try? XCTUnwrap(notification.object as? SnackbarNotification)
            XCTAssertEqual(model?.snackbarModel?.message, "Location \(UserDefaults.standard.coordinateDisplay.format(coordinate: CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0))) copied to clipboard")
            XCTAssertEqual(UIPasteboard.general.string, "\(UserDefaults.standard.coordinateDisplay.format(coordinate: CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0)))")
            return true
        }
        tester().tapView(withAccessibilityLabel: "Location")
        waitForExpectations(timeout: 10)
        
        tester().waitForView(withAccessibilityLabel: "focus")
        tester().tapView(withAccessibilityLabel: "focus")
        XCTAssertEqual(passThrough.mapState?.center?.center.latitude, 1.0)
        XCTAssertEqual(passThrough.mapState?.center?.center.longitude, 1.0)
        
        tester().waitForView(withAccessibilityLabel: "clear")
        tester().tapView(withAccessibilityLabel: "clear")
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Test item")
    }
    
    func testSearchNoResults() throws {
        MKLocalSearchMock.results = []
        class PassThrough: ObservableObject {
            var mapState: MapState?
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            @StateObject var mapState: MapState = MapState()
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationView {
                    SearchView(mapState: mapState)
                }
                .environmentObject(SearchRepository(native: NativeSearchProvider<MKLocalSearchMock>()))
                .onAppear {
                    self.passThrough.mapState = mapState
                }
            }
        }
        let passThrough = PassThrough()
        
        let container = Container(passThrough: passThrough)

        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "Expand Search")
        tester().tapView(withAccessibilityLabel: "Expand Search")
        
        tester().waitForView(withAccessibilityLabel: "Collapse Search")
        
        
        let e = XCTNSPredicateExpectation(predicate: NSPredicate(block: { _, _ in
            return passThrough.mapState?.searchResults?.count == 0
        }), object: passThrough.mapState)
        
        tester().enterText("search", intoViewWithAccessibilityLabel: "Search Field")
        
        // wait for the debounce
        tester().wait(forTimeInterval: 2)
        XCTAssertEqual(MKLocalSearchMock.searchRequest?.naturalLanguageQuery, "search")
        wait(for: [e], timeout: 5)
    }

    func testSearchCoordinates() throws {
        class PassThrough: ObservableObject {
            var mapState: MapState?
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            @StateObject var mapState: MapState = MapState()
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationView {
                    SearchView(mapState: mapState)
                }
                .environmentObject(SearchRepository(native: NativeSearchProvider<MKLocalSearchMock>()))
                .onAppear {
                    self.passThrough.mapState = mapState
                }
            }
        }
        let passThrough = PassThrough()
        
        let container = Container(passThrough: passThrough)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "Expand Search")
        tester().tapView(withAccessibilityLabel: "Expand Search")
        
        tester().waitForView(withAccessibilityLabel: "Collapse Search")
        
        
        let e = XCTNSPredicateExpectation(predicate: NSPredicate(block: { _, _ in
            return passThrough.mapState?.searchResults?.count == 1
        }), object: passThrough.mapState)
        
        tester().enterText("1N, 2E", intoViewWithAccessibilityLabel: "Search Field")
        
        // wait for the debounce
        tester().wait(forTimeInterval: 2)
        wait(for: [e], timeout: 5)
        XCTAssertEqual(MKLocalSearchMock.searchRequest?.naturalLanguageQuery, "1.0, 2.0")
        tester().waitForView(withAccessibilityLabel: "United States")
    }
    
    func testUsingSearchProvider() throws {
        class PassThrough: ObservableObject {
            var mapState: MapState?
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            @StateObject var mapState: MapState = MapState()
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationView {
                    SearchView(mapState: mapState)
                        .environmentObject(SearchRepository(native: MockSearchProvider()))
                }
                .onAppear {
                    self.passThrough.mapState = mapState
                }
            }
        }
        let passThrough = PassThrough()
        
        let container = Container(passThrough: passThrough)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "Expand Search")
        tester().tapView(withAccessibilityLabel: "Expand Search")
        
        tester().waitForView(withAccessibilityLabel: "Collapse Search")
        
        
        let e = XCTNSPredicateExpectation(predicate: NSPredicate(block: { _, _ in
            return passThrough.mapState?.searchResults?.count == 1
        }), object: passThrough.mapState)
        
        tester().enterText("search", intoViewWithAccessibilityLabel: "Search Field")
         
        // wait for the debounce
        wait(for: [e], timeout: 5)
        tester().waitForView(withAccessibilityLabel: "United States")
        tester().waitForView(withAccessibilityLabel: "Location")
        expectation(forNotification: .SnackbarNotification,
                    object: nil) { notification in
            let model = try? XCTUnwrap(notification.object as? SnackbarNotification)
            XCTAssertEqual(model?.snackbarModel?.message, "Location \(UserDefaults.standard.coordinateDisplay.format(coordinate: CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0))) copied to clipboard")
            XCTAssertEqual(UIPasteboard.general.string, "\(UserDefaults.standard.coordinateDisplay.format(coordinate: CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0)))")
            return true
        }
        tester().tapView(withAccessibilityLabel: "Location")
        waitForExpectations(timeout: 10)
        
        tester().waitForView(withAccessibilityLabel: "focus")
        tester().tapView(withAccessibilityLabel: "focus")
        XCTAssertEqual(passThrough.mapState?.center?.center.latitude, 1.0)
        XCTAssertEqual(passThrough.mapState?.center?.center.longitude, 1.0)
        
        tester().waitForView(withAccessibilityLabel: "clear")
        tester().tapView(withAccessibilityLabel: "clear")
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Test item")
    }
}

class MKLocalSearchMock: MKLocalSearch {
    
    static var searchRequest: MKLocalSearch.Request?
    static var results: [MKMapItem]?
    
    override init(request: MKLocalSearch.Request) {
        super.init(request: request)
        MKLocalSearchMock.searchRequest = request
    }
    
    override func start(completionHandler: @escaping MKLocalSearch.CompletionHandler) {
        let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0))
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Test item"
        mapItem.pointOfInterestCategory = .airport
        
        let mapItems = MKLocalSearchMock.results ?? [mapItem]
        let response: MKLocalSearch.Response = MockMKLocalSearchResponse(mapItems: mapItems)
        completionHandler(response, nil)
    }
}

class MockMKLocalSearchResponse: MKLocalSearch.Response {
    var _mapItems: [MKMapItem]
    override var mapItems: [MKMapItem] {
        return _mapItems
    }
    
    init(mapItems: [MKMapItem]) {
        self._mapItems = mapItems
    }
}

class MockSearchProvider: SearchProvider {
    func performSearch(searchText: String, region: MKCoordinateRegion?, onCompletion: @escaping ([Marlin.SearchResultModel]) -> Void) {
        if(searchText == "search"){
            let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0))
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = "Test item"
            mapItem.pointOfInterestCategory = .airport
            onCompletion([SearchResultModel(mapItem: mapItem)])
        } else {
            onCompletion([])
        }
    }
    
    func performSearchNear(region: MKCoordinateRegion?, zoom: Int, onCompletion: @escaping ([Marlin.SearchResultModel]) -> Void) {
        
    }
    
    func performSearch(
        searchText: String,
        region: MKCoordinateRegion?,
        onCompletion: @escaping ([MKMapItem]) -> Void) {
            if(searchText == "search"){
                let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0))
                let mapItem = MKMapItem(placemark: placemark)
                mapItem.name = "Test item"
                mapItem.pointOfInterestCategory = .airport
                onCompletion([mapItem])
            } else {
                onCompletion([])
            }
        }
}
