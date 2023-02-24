//
//  MarlinMapTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/26/23.
//

import XCTest
import SwiftUI
import Combine
import CoreLocation
import MapKit
import gars_ios
import mgrs_ios

@testable import Marlin

final class MarlinMapTests: XCTestCase {
    
    var cancellable = Set<AnyCancellable>()
    var persistentStore: PersistentStore = PersistenceController.shared
    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
        .receive(on: RunLoop.main)
    
    override func setUp(completion: @escaping (Error?) -> Void) {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults(withMetrics: false)

        UserDefaults.standard.initialDataLoaded = false
        for item in DataSourceList().allTabs {
            UserDefaults.standard.initialDataLoaded = false
            UserDefaults.standard.clearLastSyncTimeSeconds(item.dataSource as! any BatchImportable.Type)
        }
        UserDefaults.standard.lastLoadDate = Date(timeIntervalSince1970: 0)
        
        UserDefaults.standard.setValue(Date(), forKey: "forceReloadDate")
        persistentStoreLoadedPub
            .removeDuplicates()
            .sink { output in
                completion(nil)
            }
            .store(in: &cancellable)
        persistentStore.reset()
    }
    
    override func tearDown() {
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = nil
    }
    
    func testMapType() {
        
        UserDefaults.standard.set(Int(MKMapType.standard.rawValue), forKey: "mapType")
        
        class PassThrough {
        }
        
        struct Container: View {
            @StateObject var dataSourceList: DataSourceList = DataSourceList()
            @StateObject var mapState: MapState = MapState()
            @State var filterOpen: Bool = false
            
            var passThrough: PassThrough
            var mixins: [MapMixin] = []
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                ZStack {
                    MarlinMap(name: "Marlin Compact Map", mixins: mixins, mapState: mapState)
                }
            }
        }
        
        let appState = AppState()
        let passThrough = PassThrough()
        UNNotificationSettings.fakeAuthorizationStatus = .notDetermined
        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
            .environment(\.managedObjectContext, persistentStore.viewContext)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        let map = viewTester().usingLabel("Marlin Compact Map").view as! MKMapView
        let e = XCTKeyPathExpectation(keyPath: \MKMapView.mapType, observedObject: map) { observedObject, change in
            return await observedObject.mapType.rawValue == MKMapType.standard.rawValue
        }
        wait(for: [e], timeout: 10)
        
        UserDefaults.standard.set(Int(MKMapType.satellite.rawValue), forKey: "mapType")
        let e2 = XCTKeyPathExpectation(keyPath: \MKMapView.mapType, observedObject: map) { observedObject, change in
            return await observedObject.mapType.rawValue == MKMapType.satellite.rawValue
        }
        wait(for: [e2], timeout: 10)
        
        UserDefaults.standard.set(Int(MKMapType.mutedStandard.rawValue), forKey: "mapType")
        let e3 = XCTKeyPathExpectation(keyPath: \MKMapView.mapType, observedObject: map) { observedObject, change in
            return await observedObject.mapType.rawValue == MKMapType.mutedStandard.rawValue
        }
        wait(for: [e3], timeout: 10)
        
        UserDefaults.standard.set(Int(MKMapType.hybrid.rawValue), forKey: "mapType")
        let e4 = XCTKeyPathExpectation(keyPath: \MKMapView.mapType, observedObject: map) { observedObject, change in
            return await observedObject.mapType.rawValue == MKMapType.hybrid.rawValue
        }
        wait(for: [e4], timeout: 10)
        
        UserDefaults.standard.set(Int(MKMapType.satelliteFlyover.rawValue), forKey: "mapType")
        let e5 = XCTKeyPathExpectation(keyPath: \MKMapView.mapType, observedObject: map) { observedObject, change in
            return await observedObject.mapType.rawValue == MKMapType.satelliteFlyover.rawValue
        }
        wait(for: [e5], timeout: 10)
        
        UserDefaults.standard.set(Int(MKMapType.hybridFlyover.rawValue), forKey: "mapType")
        let e6 = XCTKeyPathExpectation(keyPath: \MKMapView.mapType, observedObject: map) { observedObject, change in
            return await observedObject.mapType.rawValue == MKMapType.hybridFlyover.rawValue
        }
        wait(for: [e6], timeout: 10)
        
        UserDefaults.standard.set(Int(ExtraMapTypes.osm.rawValue), forKey: "mapType")
        let e7 = XCTKeyPathExpectation(keyPath: \MKMapView.mapType, observedObject: map) { observedObject, change in
            let overlays = await observedObject.overlays
            for overlay in overlays {
                if let tileOverlay = overlay as? MKTileOverlay {
                    if tileOverlay.urlTemplate == "https://osm.gs.mil/tiles/default/{z}/{x}/{y}.png" {
                        return true
                    }
                }
            }
            return false
        }
        wait(for: [e7], timeout: 10)
        
        UserDefaults.standard.set(Int(MKMapType.standard.rawValue), forKey: "mapType")
        let e8 = XCTKeyPathExpectation(keyPath: \MKMapView.mapType, observedObject: map) { observedObject, change in
            let standardSet = await observedObject.mapType.rawValue == MKMapType.standard.rawValue
            if !standardSet {
                return false
            }
            var foundOSMOverlay = false
            let overlays = await observedObject.overlays
            for overlay in overlays {
                if let tileOverlay = overlay as? MKTileOverlay {
                    if tileOverlay.urlTemplate == "https://osm.gs.mil/tiles/default/{z}/{x}/{y}.png" {
                        foundOSMOverlay = true
                    }
                }
            }
            return !foundOSMOverlay
        }
        wait(for: [e8], timeout: 10)
    }
    
    func testGrids() {
        UserDefaults.standard.set(false, forKey: "showGARS")
        UserDefaults.standard.set(false, forKey: "showMGRS")
        
        class PassThrough {
        }
        
        struct Container: View {
            @StateObject var dataSourceList: DataSourceList = DataSourceList()
            @StateObject var mapState: MapState = MapState()
            @State var filterOpen: Bool = false
            
            var passThrough: PassThrough
            var mixins: [MapMixin] = []
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                ZStack {
                    MarlinMap(name: "Marlin Compact Map", mixins: mixins, mapState: mapState)
                }
            }
        }
        
        let appState = AppState()
        let passThrough = PassThrough()
        UNNotificationSettings.fakeAuthorizationStatus = .notDetermined
        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
            .environment(\.managedObjectContext, persistentStore.viewContext)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        let map = viewTester().usingLabel("Marlin Compact Map").view as! MKMapView
        let e2 = XCTNSPredicateExpectation(predicate: NSPredicate(block: { observedObject, change in
            guard let map = observedObject as? MKMapView else {
                return false
            }
            var foundGARSOverlay = false
            let overlays = map.overlays
            for overlay in overlays {
                if let _ = overlay as? GARSTileOverlay {
                    foundGARSOverlay = true
                }
            }
            return !foundGARSOverlay
        }), object: map)
        wait(for: [e2], timeout: 10)
        
        UserDefaults.standard.set(true, forKey: "showGARS")

        let e = XCTNSPredicateExpectation(predicate: NSPredicate(block: { observedObject, change in
            guard let map = observedObject as? MKMapView else {
                return false
            }
            var foundGARSOverlay = false
            let overlays = map.overlays
            for overlay in overlays {
                if let _ = overlay as? GARSTileOverlay {
                    foundGARSOverlay = true
                }
            }
            return foundGARSOverlay
        }), object: map)
        wait(for: [e], timeout: 10)
        
        UserDefaults.standard.set(false, forKey: "showGARS")
        
        let e5 = XCTNSPredicateExpectation(predicate: NSPredicate(block: { observedObject, change in
            guard let map = observedObject as? MKMapView else {
                return false
            }
            var foundGARSOverlay = false
            let overlays = map.overlays
            for overlay in overlays {
                if let _ = overlay as? GARSTileOverlay {
                    foundGARSOverlay = true
                }
            }
            return !foundGARSOverlay
        }), object: map)
        wait(for: [e5], timeout: 10)
        
        let e3 = XCTNSPredicateExpectation(predicate: NSPredicate(block: { observedObject, change in
            guard let map = observedObject as? MKMapView else {
                return false
            }
            var foundMGRSOverlay = false
            let overlays = map.overlays
            for overlay in overlays {
                if let _ = overlay as? MGRSTileOverlay {
                    foundMGRSOverlay = true
                }
            }
            return !foundMGRSOverlay
        }), object: map)
        wait(for: [e3], timeout: 10)
        
        UserDefaults.standard.set(true, forKey: "showMGRS")
        
        let e4 = XCTNSPredicateExpectation(predicate: NSPredicate(block: { observedObject, change in
            guard let map = observedObject as? MKMapView else {
                return false
            }
            var foundMGRSOverlay = false
            let overlays = map.overlays
            for overlay in overlays {
                if let _ = overlay as? MGRSTileOverlay {
                    foundMGRSOverlay = true
                }
            }
            return foundMGRSOverlay
        }), object: map)
        wait(for: [e4], timeout: 10)
        
        UserDefaults.standard.set(false, forKey: "showMGRS")
        let e6 = XCTNSPredicateExpectation(predicate: NSPredicate(block: { observedObject, change in
            guard let map = observedObject as? MKMapView else {
                return false
            }
            var foundMGRSOverlay = false
            let overlays = map.overlays
            for overlay in overlays {
                if let _ = overlay as? MGRSTileOverlay {
                    foundMGRSOverlay = true
                }
            }
            return !foundMGRSOverlay
        }), object: map)
        wait(for: [e6], timeout: 10)
    }
    
    func testMapScale() {
        UserDefaults.standard.set(true, forKey: "showMapScale")
        
        class PassThrough {
        }
        
        struct Container: View {
            @StateObject var dataSourceList: DataSourceList = DataSourceList()
            @StateObject var mapState: MapState = MapState()
            @State var filterOpen: Bool = false
            
            var passThrough: PassThrough
            var mixins: [MapMixin] = []
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                ZStack {
                    MarlinMap(name: "Marlin Compact Map", mixins: mixins, mapState: mapState)
                }
            }
        }
        
        let appState = AppState()
        let passThrough = PassThrough()
        UNNotificationSettings.fakeAuthorizationStatus = .notDetermined
        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
            .environment(\.managedObjectContext, persistentStore.viewContext)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "Map Scale")
        
        UserDefaults.standard.set(false, forKey: "showMapScale")
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Map Scale")
        
        UserDefaults.standard.set(true, forKey: "showMapScale")
        tester().waitForView(withAccessibilityLabel: "Map Scale")
    }
    
    func testSetCenter() {
        class PassThrough {
        }
        
        struct Container: View {
            @StateObject var dataSourceList: DataSourceList = DataSourceList()
            @StateObject var mapState: MapState = MapState()
            @State var filterOpen: Bool = false
            
            var passThrough: PassThrough
            var mixins: [MapMixin] = []
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                ZStack {
                    MarlinMap(name: "Marlin Compact Map", mixins: mixins, mapState: mapState)
                }
                .onAppear {
                    mapState.center = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), latitudinalMeters: 10000, longitudinalMeters: 10000)
                }
            }
        }
        
        let appState = AppState()
        let passThrough = PassThrough()
        UNNotificationSettings.fakeAuthorizationStatus = .notDetermined
        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
            .environment(\.managedObjectContext, persistentStore.viewContext)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        let map = viewTester().usingLabel("Marlin Compact Map").view as! MKMapView
        
        let e = XCTNSPredicateExpectation(predicate: NSPredicate(block: { observedObject, change in
            guard let map = observedObject as? MKMapView else {
                return false
            }
            let center = map.centerCoordinate
            return center.latitude == 0 && center.longitude == 0
        }), object: map)
        wait(for: [e], timeout: 10)
    }
    
    func testAddAndRemoveOverlays() {
        class PassThrough: ObservableObject {
            @Published var overlayToAdd: MKTileOverlay?
            @Published var overlayToRemove: MKTileOverlay?
        }
        
        struct Container: View {
            @StateObject var dataSourceList: DataSourceList = DataSourceList()
            @StateObject var mapState: MapState = MapState()
            @State var filterOpen: Bool = false
            
            @ObservedObject var passThrough: PassThrough
            var mixins: [MapMixin] = []
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                ZStack {
                    MarlinMap(name: "Marlin Compact Map", mixins: mixins, mapState: mapState)
                }
                .onAppear {
                    if let overlayToAdd = passThrough.overlayToAdd {
                        mapState.overlays.insert(overlayToAdd, at: 0)
                    }
                }
                .onChange(of: passThrough.overlayToAdd) { newValue in
                    guard let newValue = newValue else {
                        return
                    }
                    mapState.overlays.insert(newValue, at: 0)
                }
                .onChange(of: passThrough.overlayToRemove) { newValue in
                    guard newValue != nil else {
                        return
                    }
                    mapState.overlays.remove(at: 0)
                }
            }
        }
        
        let appState = AppState()
        let passThrough = PassThrough()
        UNNotificationSettings.fakeAuthorizationStatus = .notDetermined
        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
            .environment(\.managedObjectContext, persistentStore.viewContext)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Marlin Compact Map")
        let map = viewTester().usingLabel("Marlin Compact Map").view as! MKMapView
        
        let overlay = MKTileOverlay(urlTemplate: "https://example.com")
        let overlay2 = MKTileOverlay(urlTemplate: "https://example.com/nope")
        
        passThrough.overlayToAdd = overlay
        
        let e = XCTNSPredicateExpectation(predicate: NSPredicate(block: { observedObject, change in
            guard let map = observedObject as? MKMapView else {
                return false
            }
            var foundOverlay = false
            let overlays = map.overlays
            for overlay in overlays {
                if let tileOverlay = overlay as? MKTileOverlay {
                    if tileOverlay.urlTemplate == "https://example.com" {
                        foundOverlay = true
                    }
                }
            }
            return foundOverlay
        }), object: map)
        wait(for: [e], timeout: 10)
        
        passThrough.overlayToAdd = overlay2
        let e3 = XCTNSPredicateExpectation(predicate: NSPredicate(block: { observedObject, change in
            guard let map = observedObject as? MKMapView else {
                return false
            }
            var foundOverlay = false
            let overlays = map.overlays
            for overlay in overlays {
                if let tileOverlay = overlay as? MKTileOverlay {
                    if tileOverlay.urlTemplate == "https://example.com/nope" {
                        foundOverlay = true
                    }
                }
            }
            return foundOverlay
        }), object: map)
        wait(for: [e3], timeout: 10)
        
        passThrough.overlayToRemove = overlay
        let e2 = XCTNSPredicateExpectation(predicate: NSPredicate(block: { observedObject, change in
            guard let map = observedObject as? MKMapView else {
                return false
            }
            var foundOverlay = false
            let overlays = map.overlays
            for overlay in overlays {
                if let tileOverlay = overlay as? MKTileOverlay {
                    if tileOverlay.urlTemplate == "https://example.com/nope" {
                        foundOverlay = true
                    }
                }
            }
            return !foundOverlay
        }), object: map)
        wait(for: [e2], timeout: 10)
    }
    
    func testTapAsamFeature() {
        UserDefaults.standard.set(true, forKey: "showOnMap\(Asam.key)")
        UserDefaults.standard.setFilter(Asam.key, filter: [])
        class PassThrough {
        }
        
        struct Container: View {
            @StateObject var dataSourceList: DataSourceList = DataSourceList()
            @StateObject var mapState: MapState = MapState()
            @State var filterOpen: Bool = false
            
            var passThrough: PassThrough
            var mixins: [MapMixin] = [AsamMap(showAsTiles: true)]
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                ZStack {
                    MarlinMap(name: "Marlin Compact Map", mixins: mixins, mapState: mapState)
                }
                .onAppear {
                    mapState.center = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 1, longitude: 2), latitudinalMeters: 10000, longitudinalMeters: 10000)
                }
            }
        }
        
        var newItem: Asam?
        var newItem2: Asam?
        persistentStore.viewContext.performAndWait {
            let asam = Asam(context: persistentStore.viewContext)
            asam.asamDescription = "description"
            asam.longitude = 2.0
            asam.latitude = 1.0
            asam.date = Date(timeIntervalSince1970: 0)
            asam.navArea = "XI"
            asam.reference = "2022-100"
            asam.subreg = "71"
            asam.position = "1°00'00\"N \n2°00'00\"E"
            asam.hostility = "Boarding"
            asam.victim = "Boat"
            
            let asam2 = Asam(context: persistentStore.viewContext)
            asam2.asamDescription = "description2"
            asam2.longitude = 20.0
            asam2.latitude = 10.0
            asam2.date = Date(timeIntervalSince1970: 0)
            asam2.navArea = "XI"
            asam2.reference = "2022-101"
            asam2.subreg = "71"
            asam2.position = "1°00'00\"N \n2°00'00\"E"
            asam2.hostility = "Boarding"
            asam2.victim = "Boat"
            
            newItem = asam
            newItem2 = asam2
            try? persistentStore.viewContext.save()
        }
        guard let newItem = newItem else {
            XCTFail()
            return
        }
        
        let appState = AppState()
        let passThrough = PassThrough()
        UNNotificationSettings.fakeAuthorizationStatus = .notDetermined
        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
            .environment(\.managedObjectContext, persistentStore.viewContext)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        let map = viewTester().usingLabel("Marlin Compact Map").view as! MKMapView
        
        let e = XCTNSPredicateExpectation(predicate: NSPredicate(block: { observedObject, change in
            guard let map = observedObject as? MKMapView else {
                return false
            }
            let center = map.centerCoordinate
            return center.latitude <= 1.02 && center.latitude >= 0.98 && center.longitude <= 2.02 && center.longitude >= 1.98
        }), object: map)
        wait(for: [e], timeout: 10)
        
        expectation(forNotification: .MapItemsTapped, object: nil) { notification in
            
            let tapNotification = try! XCTUnwrap(notification.object as? MapItemsTappedNotification)
            let asam = tapNotification.items as! [Asam]
            XCTAssertEqual(asam.count, 1)
            XCTAssertEqual(asam[0].hostility, newItem.hostility)
            return true
        }
        tester().tapView(withAccessibilityLabel: "Marlin Compact Map")
        waitForExpectations(timeout: 10, handler: nil)
        
        NotificationCenter.default.post(Notification(name: .FocusMapOnItem, object: FocusMapOnItemNotification(item: newItem)))
        
        let e2 = XCTNSPredicateExpectation(predicate: NSPredicate(block: { observedObject, change in
            guard let map = observedObject as? MKMapView else {
                return false
            }
            let center = map.centerCoordinate
            return center.latitude < 1.0 && center.longitude <= 2.02 && center.longitude >= 1.98
        }), object: map)
        wait(for: [e2], timeout: 10)
        
        let e5 = XCTNSPredicateExpectation(predicate: NSPredicate(block: { observedObject, change in
            guard let map = observedObject as? MKMapView else {
                return false
            }
            return map.annotations.filter({ annotation in
                return !(annotation is MKUserLocation)
            }).count == 1
        }), object: map)
        wait(for: [e5], timeout: 10)
                
        NotificationCenter.default.post(Notification(name: .FocusMapOnItem, object: FocusMapOnItemNotification(item: newItem2)))
        
        let e3 = XCTNSPredicateExpectation(predicate: NSPredicate(block: { observedObject, change in
            guard let map = observedObject as? MKMapView else {
                return false
            }
            let center = map.centerCoordinate
            return center.latitude < 10.0 && center.latitude > 9.0 && center.longitude <= 20.02 && center.longitude >= 19.98
        }), object: map)
        wait(for: [e3], timeout: 10)
        
        let e6 = XCTNSPredicateExpectation(predicate: NSPredicate(block: { observedObject, change in
            guard let map = observedObject as? MKMapView else {
                return false
            }
            return map.annotations.filter({ annotation in
                return !(annotation is MKUserLocation)
            }).count == 1
        }), object: map)
        wait(for: [e6], timeout: 10)
        
        NotificationCenter.default.post(Notification(name: .FocusMapOnItem, object: FocusMapOnItemNotification()))
        let e4 = XCTNSPredicateExpectation(predicate: NSPredicate(block: { observedObject, change in
            guard let map = observedObject as? MKMapView else {
                return false
            }
            return map.annotations.filter({ annotation in
                return !(annotation is MKUserLocation)
            }).count == 0
        }), object: map)
        wait(for: [e4], timeout: 10)
        
        tester().wait(forTimeInterval: 5)
    }

}
