//
//  MarlinCompactWidthViewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/26/23.
//

import XCTest
import SwiftUI
import Combine
import CoreLocation

@testable import Marlin

final class MarlinCompactWidthViewTests: XCTestCase {
    let scheme = MarlinScheme()
    var cancellable = Set<AnyCancellable>()
    var persistentStore: PersistentStore = PersistenceController.shared
    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
        .receive(on: RunLoop.main)
    
    var bookmarkRepository: BookmarkRepositoryManager {
        BookmarkRepositoryManager(repository: BookmarkCoreDataRepository(context: persistentStore.viewContext))
    }
    var asamRepository: AsamRepository { AsamRepository(localDataSource: AsamCoreDataDataSource(context: persistentStore.viewContext)) }
    var moduRepository: ModuRepositoryManager { ModuRepositoryManager(repository: ModuCoreDataRepository(context: persistentStore.viewContext)) }
    var lightRepository: LightRepositoryManager { LightRepositoryManager(repository: LightCoreDataRepository(context: persistentStore.viewContext)) }
    var portRepository: PortRepositoryManager { PortRepositoryManager(repository: PortCoreDataRepository(context: persistentStore.viewContext)) }
    var dgpsRepository: DifferentialGPSStationRepositoryManager { DifferentialGPSStationRepositoryManager(repository: DifferentialGPSStationCoreDataRepository(context: persistentStore.viewContext)) }
    var radioBeaconRepository: RadioBeaconRepositoryManager { RadioBeaconRepositoryManager(repository: RadioBeaconCoreDataRepository(context: persistentStore.viewContext)) }
    var routeRepository: RouteRepositoryManager { RouteRepositoryManager(repository: RouteCoreDataRepository(context: persistentStore.viewContext)) }
    var routeWaypointRepository: RouteWaypointRepository { RouteWaypointRepository(localDataSource: RouteWaypointCoreDataDataSource(context: persistentStore.viewContext))}

    override func setUp(completion: @escaping (Error?) -> Void) {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults()

        UserDefaults.standard.initialDataLoaded = false
        for item in DataSourceList().allTabs {
            UserDefaults.standard.initialDataLoaded = false
            UserDefaults.standard.clearLastSyncTimeSeconds(item.dataSource.definition)
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
        let mockCLLocation = MockCLLocationManager()
        let mockLocationManager = MockLocationManager(locationManager: mockCLLocation)
        mockLocationManager.lastLocation = CLLocation(latitude: 5.0, longitude: 4.0)
        
        class PassThrough {
            var dataSourceList: DataSourceList?
        }
        
        struct Container: View {
            @StateObject var dataSourceList: DataSourceList = DataSourceList()
            @State var filterOpen: Bool = false

            var passThrough: PassThrough
            var mixins: [MapMixin] = []
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                ZStack {
                    MarlinCompactWidth(filterOpen: $filterOpen)
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
            .environmentObject(mockLocationManager as LocationManager)            
            .environmentObject(bookmarkRepository)
            .environmentObject(asamRepository)
            .environmentObject(moduRepository)
            .environmentObject(lightRepository)
            .environmentObject(portRepository)
            .environmentObject(dgpsRepository)
            .environmentObject(radioBeaconRepository)
            .environmentObject(routeRepository)

        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForAbsenceOfView(withAccessibilityLabel: "New Data Loaded")
        tester().waitForView(withAccessibilityLabel: "Current Location")
        tester().waitForView(withAccessibilityLabel: "Marlin Map")
        tester().waitForView(withAccessibilityLabel: "Marlin Map Tab")
        tester().waitForView(withAccessibilityLabel: "Loading initial data")
        tester().waitForView(withAccessibilityLabel: "Map Settings Button")
        tester().waitForView(withAccessibilityLabel: "User Tracking")
        tester().tapView(withAccessibilityLabel: "Expand Map Toggle")
        
        if let dataSourceList = passThrough.dataSourceList {
            for dataSource in dataSourceList.tabs {
                tester().waitForView(withAccessibilityLabel: "\(dataSource.dataSource.definition.key)List")
            }
            for dataSource in dataSourceList.allTabs.filter({ item in
                item.dataSource.definition.mappable
            }) {
                tester().waitForView(withAccessibilityLabel: "\(dataSource.dataSource.definition.key) Map Toggle")
            }
        }
        
        tester().tapView(withAccessibilityLabel: "Collapse Map Toggle")
        
        UserDefaults.standard.initialDataLoaded = true
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Loading initial data")
    }
    
    func testSwitchTabs() {
        UserDefaults.standard.showCurrentLocation = true
        let mockCLLocation = MockCLLocationManager()
        let mockLocationManager = MockLocationManager(locationManager: mockCLLocation)
        mockLocationManager.lastLocation = CLLocation(latitude: 5.0, longitude: 4.0)
        
        class PassThrough {
            var dataSourceList: DataSourceList?
        }
        
        struct Container: View {
            @StateObject var dataSourceList: DataSourceList = DataSourceList()
            @State var filterOpen: Bool = false
            
            var passThrough: PassThrough
            var mixins: [MapMixin] = []
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                ZStack {
                    MarlinCompactWidth(filterOpen: $filterOpen)
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
            .environmentObject(mockLocationManager as LocationManager)
            .environmentObject(bookmarkRepository)
            .environmentObject(asamRepository)
            .environmentObject(moduRepository)
            .environmentObject(lightRepository)
            .environmentObject(portRepository)
            .environmentObject(dgpsRepository)
            .environmentObject(radioBeaconRepository)
            .environmentObject(routeRepository)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "Marlin Map")
        if let dataSourceList = passThrough.dataSourceList {
            for dataSource in dataSourceList.tabs {
                tester().waitForView(withAccessibilityLabel: "\(dataSource.dataSource.definition.key)List")
                tester().tapView(withAccessibilityLabel: "\(dataSource.dataSource.definition.key)List")
                tester().waitForAbsenceOfView(withAccessibilityLabel: "Marlin Map")
                tester().waitForView(withAccessibilityLabel: dataSource.dataSource.definition.fullName)
                tester().tapView(withAccessibilityLabel: "Marlin Map Tab")
                tester().waitForView(withAccessibilityLabel: "Marlin Map")
            }
            
            tester().tapView(withAccessibilityLabel: "\(dataSourceList.tabs[0].dataSource.definition.key)List")
            tester().waitForView(withAccessibilityLabel: dataSourceList.tabs[0].dataSource.definition.fullName)
            tester().waitForAbsenceOfView(withAccessibilityLabel: "Marlin Map")
            NotificationCenter.default.post(name: .TabRequestFocus, object: nil)
            tester().waitForView(withAccessibilityLabel: "Marlin Map")
        }
    }
    
    func testSwitchTabsWithNotification() {
        UserDefaults.standard.showCurrentLocation = true
        let mockCLLocation = MockCLLocationManager()
        let mockLocationManager = MockLocationManager(locationManager: mockCLLocation)
        mockLocationManager.lastLocation = CLLocation(latitude: 5.0, longitude: 4.0)
        
        class PassThrough {
            var dataSourceList: DataSourceList?
        }
        
        struct Container: View {
            @StateObject var dataSourceList: DataSourceList = DataSourceList()
            @State var filterOpen: Bool = false
            
            var passThrough: PassThrough
            var mixins: [MapMixin] = []
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                ZStack {
                    MarlinCompactWidth(filterOpen: $filterOpen)
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
            .environmentObject(mockLocationManager as LocationManager)
            .environmentObject(bookmarkRepository)
            .environmentObject(asamRepository)
            .environmentObject(moduRepository)
            .environmentObject(lightRepository)
            .environmentObject(portRepository)
            .environmentObject(dgpsRepository)
            .environmentObject(radioBeaconRepository)
            .environmentObject(routeRepository)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "Marlin Map")
        if let dataSourceList = passThrough.dataSourceList {
            for dataSource in dataSourceList.tabs {
                NotificationCenter.default.post(name: .SwitchTabs, object: dataSource.dataSource.definition.key)
                tester().waitForView(withAccessibilityLabel: dataSource.dataSource.definition.fullName)
                NotificationCenter.default.post(name: .TabRequestFocus, object: nil)
                tester().waitForView(withAccessibilityLabel: "Marlin Map")
            }
        }
        
        NotificationCenter.default.post(name: .SwitchTabs, object: "settings")
        tester().waitForView(withAccessibilityLabel: "About")
        NotificationCenter.default.post(name: .TabRequestFocus, object: nil)
        tester().waitForView(withAccessibilityLabel: "Marlin Map")
        
        NotificationCenter.default.post(name: .SwitchTabs, object: "submitReport")
        tester().waitForView(withAccessibilityLabel: "Submit Report")
        NotificationCenter.default.post(name: .TabRequestFocus, object: nil)
        tester().waitForView(withAccessibilityLabel: "Marlin Map")
    }
    
    func testOpenSideMenu() {
        UserDefaults.standard.showCurrentLocation = true
        let mockCLLocation = MockCLLocationManager()
        let mockLocationManager = MockLocationManager(locationManager: mockCLLocation)
        mockLocationManager.lastLocation = CLLocation(latitude: 5.0, longitude: 4.0)
        
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
                    MarlinCompactWidth(filterOpen: $filterOpen)
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
            .environmentObject(mockLocationManager as LocationManager)
            .environmentObject(bookmarkRepository)
            .environmentObject(asamRepository)
            .environmentObject(moduRepository)
            .environmentObject(lightRepository)
            .environmentObject(portRepository)
            .environmentObject(dgpsRepository)
            .environmentObject(radioBeaconRepository)
            .environmentObject(routeRepository)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "Marlin Map")
        tester().waitForView(withAccessibilityLabel: "Side Menu Closed")
        tester().tapView(withAccessibilityLabel: "Side Menu")
        tester().waitForView(withAccessibilityLabel: "Side Menu Open")
    }
    
    func testViewData() {
        UserDefaults.standard.showCurrentLocation = true
        let mockCLLocation = MockCLLocationManager()
        let mockLocationManager = MockLocationManager(locationManager: mockCLLocation)
        mockLocationManager.lastLocation = CLLocation(latitude: 5.0, longitude: 4.0)
        
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
                    MarlinCompactWidth(filterOpen: $filterOpen)
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
            .environmentObject(mockLocationManager as LocationManager)
            .environmentObject(bookmarkRepository)
            .environmentObject(asamRepository)
            .environmentObject(moduRepository)
            .environmentObject(lightRepository)
            .environmentObject(portRepository)
            .environmentObject(dgpsRepository)
            .environmentObject(radioBeaconRepository)
            .environmentObject(routeRepository)
            .environmentObject(routeWaypointRepository)

        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "Marlin Map")
        
        NotificationCenter.default.post(name: .ViewDataSource, object: ViewDataSource(dataSource: asam))
        
        tester().waitForView(withAccessibilityLabel: "Boarding: Boat")
    }
}
