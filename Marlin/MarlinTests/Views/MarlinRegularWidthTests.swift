//
//  MarlinRegularWidthTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/24/23.
//

import XCTest
import SwiftUI
import Combine
import CoreLocation

@testable import Marlin

final class MarlinRegularWidthTests: XCTestCase {

    let scheme = MarlinScheme()
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
    
    func testLoading() {
        UserDefaults.standard.showCurrentLocation = true
        LocationManager.shared().lastLocation = CLLocation(latitude: 5.0, longitude: 4.0)
        
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
                    MarlinRegularWidth(filterOpen: $filterOpen)
                        .environmentObject(dataSourceList)
                    .onAppear {
                        self.passThrough.dataSourceList = dataSourceList
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
        
        tester().waitForAbsenceOfView(withAccessibilityLabel: "New Data Loaded")
        tester().waitForView(withAccessibilityLabel: "Current Location")
        tester().waitForView(withAccessibilityLabel: "Marlin Map")
        tester().waitForView(withAccessibilityLabel: "Data Source Rail")
        tester().waitForView(withAccessibilityLabel: "Loading initial data")
        tester().waitForView(withAccessibilityLabel: "Map Settings Button")
        tester().waitForView(withAccessibilityLabel: "User Tracking")
        
        if let dataSourceList = passThrough.dataSourceList {
            for dataSource in dataSourceList.allTabs {
                tester().waitForView(withAccessibilityLabel: "\(dataSource.dataSource.fullDataSourceName) rail item")
            }
            for dataSource in dataSourceList.allTabs.filter({ item in
                item.dataSource.isMappable
            }) {
                tester().waitForView(withAccessibilityLabel: "\(dataSource.dataSource.key) Map Toggle")
            }
        }
        
        UserDefaults.standard.initialDataLoaded = true
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Loading initial data")
    }
    
    func testSwitchRailItems() {
        UserDefaults.standard.showCurrentLocation = true
        LocationManager.shared().lastLocation = CLLocation(latitude: 5.0, longitude: 4.0)
        
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
                    MarlinRegularWidth(filterOpen: $filterOpen)
                        .environmentObject(dataSourceList)
                    .onAppear {
                        self.passThrough.dataSourceList = dataSourceList
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
        
        tester().waitForView(withAccessibilityLabel: "Marlin Map")
        if let dataSourceList = passThrough.dataSourceList {
            for dataSource in dataSourceList.allTabs {
                let listFound = viewTester().usingLabel("\(dataSource.dataSource.fullDataSourceName) List").tryFindingView()
                // this means this item is active and tapping it should hide it
                if listFound {
                    tester().tapView(withAccessibilityLabel: "\(dataSource.dataSource.fullDataSourceName) rail item")
                    tester().waitForAbsenceOfView(withAccessibilityLabel: "\(dataSource.dataSource.fullDataSourceName) List")
                } else {
                    tester().waitForTappableView(withAccessibilityLabel: "\(dataSource.dataSource.fullDataSourceName) rail item")
                    tester().tapView(withAccessibilityLabel: "\(dataSource.dataSource.fullDataSourceName) rail item")
                    tester().waitForView(withAccessibilityLabel: "\(dataSource.dataSource.fullDataSourceName) List")
                    tester().tapView(withAccessibilityLabel: "\(dataSource.dataSource.fullDataSourceName) rail item")
                    tester().waitForAbsenceOfView(withAccessibilityLabel: "\(dataSource.dataSource.fullDataSourceName) List")
                }
            }
        }
    }
    
    func testSwitchTabsWithNotification() {
        UserDefaults.standard.showCurrentLocation = true
        LocationManager.shared().lastLocation = CLLocation(latitude: 5.0, longitude: 4.0)
        
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
                    MarlinRegularWidth(filterOpen: $filterOpen)
                        .environmentObject(dataSourceList)
                    .onAppear {
                        self.passThrough.dataSourceList = dataSourceList
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
        
        tester().waitForView(withAccessibilityLabel: "Marlin Map")
        if let dataSourceList = passThrough.dataSourceList {
            for dataSource in dataSourceList.allTabs {
                NotificationCenter.default.post(name: .SwitchTabs, object: dataSource.dataSource.key)
                tester().waitForView(withAccessibilityLabel: "\(dataSource.dataSource.fullDataSourceName) List")
            }
        }
        
        NotificationCenter.default.post(name: .SwitchTabs, object: "settings")
        tester().waitForView(withAccessibilityLabel: "About")
        tester().waitForView(withAccessibilityLabel: "Marlin")
        tester().tapView(withAccessibilityLabel: "Marlin")
        
        NotificationCenter.default.post(name: .SwitchTabs, object: "submitReport")
        tester().waitForView(withAccessibilityLabel: "Submit Report")
        tester().waitForView(withAccessibilityLabel: "Marlin")
        tester().tapView(withAccessibilityLabel: "Marlin")
    }
    
    func testViewData() {
        UserDefaults.standard.showCurrentLocation = true
        LocationManager.shared().lastLocation = CLLocation(latitude: 5.0, longitude: 4.0)
        
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
                    MarlinRegularWidth(filterOpen: $filterOpen)
                        .environmentObject(dataSourceList)
                    .onAppear {
                        self.passThrough.dataSourceList = dataSourceList
                    }
                }
            }
        }
        
        var asam: Asam?
        
        persistentStore.viewContext.performAndWait {
            let newItem = Asam(context: persistentStore.viewContext)
            newItem.asamDescription = "description"
            newItem.longitude = 1.0
            newItem.latitude = 1.0
            newItem.date = Date()
            newItem.navArea = "XI"
            newItem.reference = "2022-100"
            newItem.subreg = "71"
            newItem.position = "1°00'00\"N \n1°00'00\"E"
            newItem.hostility = "Boarding"
            newItem.victim = "Boat"
            
            try? persistentStore.viewContext.save()
            asam = newItem
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
        
        tester().waitForView(withAccessibilityLabel: "Marlin Map")
        
        NotificationCenter.default.post(name: .ViewDataSource, object: ViewDataSource(dataSource: asam))
        
        tester().waitForView(withAccessibilityLabel: "Boarding: Boat")
    }
}
