//
//  MarlinViewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/17/23.
//

import XCTest
import SwiftUI
import Combine
import CoreLocation
import OHHTTPStubs

@testable import Marlin

final class MarlinViewTests: XCTestCase {
    
    var cancellable = Set<AnyCancellable>()
    var persistentStore: PersistentStore = PersistenceController.shared
    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
        .receive(on: RunLoop.main)
    
    override func setUp(completion: @escaping (Error?) -> Void) {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults()
        
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
    
    func testShowOnboarding() {
        UserDefaults.standard.showCurrentLocation = true
        LocationManager.shared.lastLocation = CLLocation(latitude: 5.0, longitude: 4.0)
        
        class PassThrough {
            var dataSourceList: DataSourceList?
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
                    MarlinView()
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
        
        tester().waitForView(withAccessibilityLabel: "Set Sail")
    }
    
    func testShowDisclaimer() {
        UserDefaults.standard.set(true, forKey: "onboardingComplete")
        UserDefaults.standard.showCurrentLocation = true
        LocationManager.shared.lastLocation = CLLocation(latitude: 5.0, longitude: 4.0)
        
        class PassThrough {
            var dataSourceList: DataSourceList?
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
                    MarlinView()
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
        XCTAssertFalse(UserDefaults.standard.bool(forKey: "disclaimerAccepted"))
        tester().waitForView(withAccessibilityLabel: "Legal Disclaimer")
        tester().waitForView(withAccessibilityLabel: "Accept")
        tester().tapView(withAccessibilityLabel: "Accept")
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "disclaimerAccepted"))
    }
    
    func testShowSnackbar() {
        UserDefaults.standard.set(true, forKey: "onboardingComplete")
        UserDefaults.standard.set(true, forKey: "disclaimerAccepted")
        UserDefaults.standard.showCurrentLocation = true
        LocationManager.shared.lastLocation = CLLocation(latitude: 5.0, longitude: 4.0)
        
        class PassThrough {
            var dataSourceList: DataSourceList?
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
                    MarlinView()
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
        tester().waitForView(withAccessibilityLabel: "Current Location")
        NotificationCenter.default.post(name: .SnackbarNotification, object: SnackbarNotification(snackbarModel: SnackbarModel(message: "Testing is fun")))
        tester().waitForView(withAccessibilityLabel: "Testing is fun")
    }
    
    func testShowFilter() {
        UserDefaults.standard.set(true, forKey: "onboardingComplete")
        UserDefaults.standard.set(true, forKey: "disclaimerAccepted")
        UserDefaults.standard.showCurrentLocation = true
        LocationManager.shared.lastLocation = CLLocation(latitude: 5.0, longitude: 4.0)
        
        class PassThrough {
            var dataSourceList: DataSourceList?
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
                    MarlinView()
                        .onAppear {
                            passThrough.dataSourceList = dataSourceList
                        }
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
        tester().waitForView(withAccessibilityLabel: "Filter")
        tester().tapView(withAccessibilityLabel: "Filter")
        
        for ds in passThrough.dataSourceList!.mappedDataSources {
            tester().waitForView(withAccessibilityLabel: "\(ds.dataSource.fullDataSourceName) filter row")
        }
        
        tester().tapView(withAccessibilityLabel: "Close Filter")
    }
    
    func testMapItemsTapped() {
        UserDefaults.standard.set(true, forKey: "onboardingComplete")
        UserDefaults.standard.set(true, forKey: "disclaimerAccepted")
        UserDefaults.standard.showCurrentLocation = true
        LocationManager.shared.lastLocation = CLLocation(latitude: 5.0, longitude: 4.0)
        
        var newItem: Asam?
        persistentStore.viewContext.performAndWait {
            let asam = Asam(context: persistentStore.viewContext)
            asam.asamDescription = "description"
            asam.longitude = 1.0
            asam.latitude = 1.0
            asam.date = Date(timeIntervalSince1970: 0)
            asam.navArea = "XI"
            asam.reference = "2022-100"
            asam.subreg = "71"
            asam.position = "1°00'00\"N \n1°00'00\"E"
            asam.hostility = "Boarding"
            asam.victim = "Boat"
            
            newItem = asam
            try? persistentStore.viewContext.save()
        }
        guard let newItem = newItem else {
            XCTFail()
            return
        }
        
        class PassThrough {
            var dataSourceList: DataSourceList?
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
                    MarlinView()
                        .onAppear {
                            passThrough.dataSourceList = dataSourceList
                        }
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
        tester().waitForView(withAccessibilityLabel: "Filter")
        
        NotificationCenter.default.post(name: .MapItemsTapped, object: MapItemsTappedNotification(items: [newItem]))
        tester().waitForView(withAccessibilityLabel: "Boarding: Boat")
        NotificationCenter.default.post(name: .DismissBottomSheet, object: "marlin view")
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Boarding: Boat")
    }
    
    func testDocumentPreview() {
        UserDefaults.standard.set(true, forKey: "onboardingComplete")
        UserDefaults.standard.set(true, forKey: "disclaimerAccepted")
        UserDefaults.standard.showCurrentLocation = true
        LocationManager.shared.lastLocation = CLLocation(latitude: 5.0, longitude: 4.0)
        
        class PassThrough {
            var dataSourceList: DataSourceList?
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
                    MarlinView()
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
        tester().waitForView(withAccessibilityLabel: "Current Location")
        let path = OHPathForFile("mockEpub.rtf", type(of: self))!
        
        NotificationCenter.default.post(name: .DocumentPreview, object: URL(fileURLWithPath: path))
        tester().waitForView(withAccessibilityLabel: "Done")
        
        DocumentController.shared.dismissPreview()
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Done")
    }
}
