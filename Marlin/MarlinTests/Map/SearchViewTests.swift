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

    var cancellable = Set<AnyCancellable>()
    var persistentStore: PersistentStore = PersistenceController.shared
    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
        .receive(on: RunLoop.main)
    
    override func setUp(completion: @escaping (Error?) -> Void) {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults(withMetrics: false)

        for item in DataSourceList().allTabs {
            UserDefaults.standard.initialDataLoaded = false
            UserDefaults.standard.clearLastSyncTimeSeconds(item.dataSource as! any BatchImportable.Type)
        }
        UserDefaults.standard.lastLoadDate = Date(timeIntervalSince1970: 0)
        UserDefaults.standard.setValue(Date(), forKey: "forceReloadDate")
        
        UserDefaults.standard.setFilter(ElectronicPublication.key, filter: [])
        UserDefaults.standard.setSort(ElectronicPublication.key, sort: ElectronicPublication.defaultSort)
        
        persistentStore.viewContext.performAndWait {
            if let epubs = persistentStore.viewContext.fetchAll(ElectronicPublication.self) {
                for epub in epubs {
                    persistentStore.viewContext.delete(epub)
                }
            }
        }
        
        persistentStoreLoadedPub
            .removeDuplicates()
            .sink { output in
                let e5 = XCTNSPredicateExpectation(predicate: NSPredicate(block: { observedObject, change in
                    if let count = try? self.persistentStore.countOfObjects(ElectronicPublication.self) {
                        return count == 0
                    }
                    return false
                }), object: self.persistentStore.viewContext)
                self.wait(for: [e5], timeout: 10)
                completion(nil)
            }
            .store(in: &cancellable)
        persistentStore.reset()
        MKLocalSearchMock.results = nil
    }
    override func tearDown(completion: @escaping (Error?) -> Void) {
        persistentStore.viewContext.performAndWait {
            if let epubs = persistentStore.viewContext.fetchAll(ElectronicPublication.self) {
                for epub in epubs {
                    persistentStore.viewContext.delete(epub)
                }
            }
        }
        completion(nil)
        HTTPStubs.removeAllStubs()
        MKLocalSearchMock.results = nil
    }
    
    func testExpandCollapse() throws {
        class PassThrough: ObservableObject {
            
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
            }
        }
        let passThrough = PassThrough()
        
        let container = Container(passThrough: passThrough)
            .environment(\.managedObjectContext, persistentStore.viewContext)
        
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
                    SearchView<MKLocalSearchMock>(mapState: mapState)
                }
                .onAppear {
                    self.passThrough.mapState = mapState
                }
            }
        }
        let passThrough = PassThrough()
        
        let container = Container(passThrough: passThrough)
            .environment(\.managedObjectContext, persistentStore.viewContext)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "Expand Search")
        tester().tapView(withAccessibilityLabel: "Expand Search")
        
        tester().waitForView(withAccessibilityLabel: "Collapse Search")
        
        
        let e = XCTNSPredicateExpectation(predicate: NSPredicate(block: { _, _ in
            return passThrough.mapState?.searchResults?.count == 1
        }), object: passThrough.mapState)
        
        tester().enterText("hello", intoViewWithAccessibilityLabel: "Search Field")
         
        // wait for the debounce
        wait(for: [e], timeout: 5)
        XCTAssertEqual(MKLocalSearchMock.searchRequest?.naturalLanguageQuery, "hello")
        tester().waitForView(withAccessibilityLabel: "Test item")
        tester().waitForView(withAccessibilityLabel: "Location")
        expectation(forNotification: .SnackbarNotification,
                    object: nil) { notification in
            let model = try? XCTUnwrap(notification.object as? SnackbarNotification)
            XCTAssertEqual(model?.snackbarModel?.message, "Location 1.0, 1.0 copied to clipboard")
            XCTAssertEqual(UIPasteboard.general.string, "1.0, 1.0")
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
                    SearchView<MKLocalSearchMock>(mapState: mapState)
                }
                .onAppear {
                    self.passThrough.mapState = mapState
                }
            }
        }
        let passThrough = PassThrough()
        
        let container = Container(passThrough: passThrough)
            .environment(\.managedObjectContext, persistentStore.viewContext)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "Expand Search")
        tester().tapView(withAccessibilityLabel: "Expand Search")
        
        tester().waitForView(withAccessibilityLabel: "Collapse Search")
        
        
        let e = XCTNSPredicateExpectation(predicate: NSPredicate(block: { _, _ in
            return passThrough.mapState?.searchResults?.count == 0
        }), object: passThrough.mapState)
        
        tester().enterText("hello no results", intoViewWithAccessibilityLabel: "Search Field")
        
        // wait for the debounce
        tester().wait(forTimeInterval: 2)
        XCTAssertEqual(MKLocalSearchMock.searchRequest?.naturalLanguageQuery, "hello no results")
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
                    SearchView<MKLocalSearchMock>(mapState: mapState)
                }
                .onAppear {
                    self.passThrough.mapState = mapState
                }
            }
        }
        let passThrough = PassThrough()
        
        let container = Container(passThrough: passThrough)
            .environment(\.managedObjectContext, persistentStore.viewContext)
        
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
        tester().waitForView(withAccessibilityLabel: "Test item")
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
