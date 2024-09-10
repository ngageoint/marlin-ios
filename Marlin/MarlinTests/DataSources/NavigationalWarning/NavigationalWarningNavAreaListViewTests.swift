//
//  NavigationalWarningNavAreaListViewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/14/23.
//

import XCTest
import Combine
import SwiftUI

@testable import Marlin

final class NavigationalWarningNavAreaListViewTests: XCTestCase {

    override func setUp() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults()
    }

    func testOneNavWarning() throws {
        try XCTSkipIf(TestHelpers.DISABLE_UI_TESTS, "UI tests are disabled")
        var warnings: [NavigationalWarningModel] = []
        var navWarning = NavigationalWarningModel(navArea: "4")
        navWarning.msgYear = 2022
        navWarning.msgNumber = 1177
        navWarning.navArea = "4"
        navWarning.subregion = "11,26"
        navWarning.text = "WESTERN NORTH ATLANTIC.\nFLORIDA.\n1. HAZARDOUS OPERATIONS, ROCKET LAUNCHING\n   121606Z TO 121854Z NOV, ALTERNATE\n   131606Z TO 131854Z AND 1607Z TO 1854Z DAILY\n   14 THRU 18 NOV IN AREAS BOUND BY:\n   A. 28-39.92N 080-38.33W, 28-40.00N 079-44.00W,\n      28-28.00N 079-40.00W, 28-29.97N 080-32.29W\n   B. 27-51.00N 073-56.00W, 28-37.00N 073-55.00W,\n      28-40.00N 071-21.00W, 28-13.00N 069-58.00W,\n      27-31.00N 069-58.00W, 27-21.00N 071-43.00W.\n2. CANCEL NAVAREA IV 1165/22.\n3. CANCEL THIS MSG 181954Z NOV 22.\n"
        navWarning.status = "A"
        navWarning.issueDate = Date()
        navWarning.authority = "EASTERN RANGE 0/22 072203Z NOV 22."

        warnings.append(navWarning)
        
        class PassThrough: ObservableObject {
            var navArea: String

            init(navArea: String) {
                self.navArea = navArea
            }
        }
        
        struct Container: View {
            @State var router: MarlinRouter = MarlinRouter()
            @ObservedObject var passThrough: PassThrough
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationStack(path: $router.path) {
                    NavigationalWarningNavAreaListView(navArea: passThrough.navArea, mapName: "Navigational Warning List View Map")
                        .marlinRoutes()
                }
                .environmentObject(router)
            }
        }
        let appState = AppState()
        let passThrough = PassThrough(navArea: "4")
        
        let localDataSource = NavigationalWarningStaticLocalDataSource()
        let remoteDataSource = NavigationalWarningRemoteDataSource()
        InjectedValues[\.navWarningLocalDataSource] = localDataSource
        InjectedValues[\.navWarningRemoteDataSource] = remoteDataSource
        localDataSource.list.append(contentsOf: warnings)

        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        InjectedValues[\.bookmarkLocalDataSource] = bookmarkLocalDataSource
        var routeWaypointRepository = RouteWaypointRepository(localDataSource: RouteWaypointStaticLocalDataSource())

        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
            .environmentObject(routeWaypointRepository)

        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "\(warnings[0].itemTitle) summary")
        tester().tapView(withAccessibilityLabel: "\(warnings[0].itemTitle) summary")
    }
    
    func testOneNavWarningNavAreasView() throws {
        try XCTSkipIf(TestHelpers.DISABLE_UI_TESTS, "UI tests are disabled")
        var warnings: [NavigationalWarningModel] = []
        var navWarning = NavigationalWarningModel(navArea: "4")
        navWarning.msgYear = 2022
        navWarning.msgNumber = 1177
        navWarning.navArea = "4"
        navWarning.subregion = "11,26"
        navWarning.text = "WESTERN NORTH ATLANTIC.\nFLORIDA.\n1. HAZARDOUS OPERATIONS, ROCKET LAUNCHING\n   121606Z TO 121854Z NOV, ALTERNATE\n   131606Z TO 131854Z AND 1607Z TO 1854Z DAILY\n   14 THRU 18 NOV IN AREAS BOUND BY:\n   A. 28-39.92N 080-38.33W, 28-40.00N 079-44.00W,\n      28-28.00N 079-40.00W, 28-29.97N 080-32.29W\n   B. 27-51.00N 073-56.00W, 28-37.00N 073-55.00W,\n      28-40.00N 071-21.00W, 28-13.00N 069-58.00W,\n      27-31.00N 069-58.00W, 27-21.00N 071-43.00W.\n2. CANCEL NAVAREA IV 1165/22.\n3. CANCEL THIS MSG 181954Z NOV 22.\n"
        navWarning.status = "A"
        navWarning.issueDate = Date()
        navWarning.authority = "EASTERN RANGE 0/22 072203Z NOV 22."

        warnings.append(navWarning)

        class PassThrough: ObservableObject {
            var navArea: String

            init(navArea: String) {
                self.navArea = navArea
            }
        }
        
        struct Container: View {
            
            @ObservedObject var passThrough: PassThrough
            @StateObject var focusedItem: ItemWrapper = ItemWrapper()
            @State var router: MarlinRouter = MarlinRouter()

            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationStack(path: $router.path) {
                    NavigationalWarningsOverview(focusedItem: focusedItem)
                        .marlinRoutes()
                }
                .environmentObject(router)
            }
        }
        let appState = AppState()
        let passThrough = PassThrough(navArea: "4")
        let mockCLLocation = MockCLLocationManager()
        let mockLocationManager = MockLocationManager(locationManager: mockCLLocation)
        let localDataSource = NavigationalWarningStaticLocalDataSource()
        let remoteDataSource = NavigationalWarningRemoteDataSource()
        InjectedValues[\.navWarningLocalDataSource] = localDataSource
        InjectedValues[\.navWarningRemoteDataSource] = remoteDataSource
        localDataSource.list.append(contentsOf: warnings)
        var routeWaypointRepository = RouteWaypointRepository(localDataSource: RouteWaypointStaticLocalDataSource())

        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        InjectedValues[\.bookmarkLocalDataSource] = bookmarkLocalDataSource
        let mapFeatureRepository = NavigationalWarningsMapFeatureRepository()
        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
            .environmentObject(mockLocationManager as LocationManager)
            .environmentObject(routeWaypointRepository)
            .environmentObject(mapFeatureRepository)
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "NAVAREA IV")
        tester().tapView(withAccessibilityLabel: "NAVAREA IV")
        tester().waitForView(withAccessibilityLabel: "\(warnings[warnings.count - 1].itemTitle) summary")
        tester().tapView(withAccessibilityLabel: "\(warnings[warnings.count - 1].itemTitle) summary")
        tester().wait(forTimeInterval: 5)
    }
    
    func testALotOfNavWarnings() throws {
        var dateComponents = DateComponents()
        dateComponents.year = 2022
        dateComponents.month = 1
        dateComponents.day = 1
        dateComponents.hour = 12
        dateComponents.minute = 0
        dateComponents.second = 0
        dateComponents.nanosecond = 0
        dateComponents.timeZone = TimeZone(secondsFromGMT: 0)
        
        let year = Calendar.current.date(from: dateComponents)!
        var warnings: [NavigationalWarningModel] = []
        for i in 1...12 {
            var navWarning = NavigationalWarningModel(navArea: "4")
            navWarning.msgYear = 2022
            navWarning.msgNumber = Int(13 - i)
            navWarning.navArea = "4"
            navWarning.subregion = "11,26"
            navWarning.text = "WESTERN NORTH ATLANTIC.\nFLORIDA.\n1. HAZARDOUS OPERATIONS, ROCKET LAUNCHING\n   121606Z TO 121854Z NOV, ALTERNATE\n   131606Z TO 131854Z AND 1607Z TO 1854Z DAILY\n   14 THRU 18 NOV IN AREAS BOUND BY:\n   A. 28-39.92N 080-38.33W, 28-40.00N 079-44.00W,\n      28-28.00N 079-40.00W, 28-29.97N 080-32.29W\n   B. 27-51.00N 073-56.00W, 28-37.00N 073-55.00W,\n      28-40.00N 071-21.00W, 28-13.00N 069-58.00W,\n      27-31.00N 069-58.00W, 27-21.00N 071-43.00W.\n2. CANCEL NAVAREA IV 1165/22.\n3. CANCEL THIS MSG 181954Z NOV 22.\n"
            navWarning.status = "A"
            navWarning.issueDate = Calendar.current.date(bySetting: .month, value: 13 - i, of: year)
            navWarning.authority = "EASTERN RANGE 0/22 072203Z NOV 22."

            warnings.append(navWarning)
        }
        
        class PassThrough: ObservableObject {
            var navArea: String

            init(navArea: String) {
                self.navArea = navArea
            }
        }
        
        struct Container: View {
            
            @ObservedObject var passThrough: PassThrough
            @State var router: MarlinRouter = MarlinRouter()

            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationStack(path: $router.path) {
                    NavigationalWarningNavAreaListView(navArea: passThrough.navArea, mapName: "Navigational Warning List View Map")
                        .marlinRoutes()
                }
                .environmentObject(router)
            }
        }
        let appState = AppState()
        let passThrough = PassThrough(navArea: "4")
        let localDataSource = NavigationalWarningStaticLocalDataSource()
        let remoteDataSource = NavigationalWarningRemoteDataSource()
        InjectedValues[\.navWarningLocalDataSource] = localDataSource
        InjectedValues[\.navWarningRemoteDataSource] = remoteDataSource
        localDataSource.list.append(contentsOf: warnings)
        var routeWaypointRepository = RouteWaypointRepository(localDataSource: RouteWaypointStaticLocalDataSource())

        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        InjectedValues[\.bookmarkLocalDataSource] = bookmarkLocalDataSource
        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
            .environmentObject(routeWaypointRepository)
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller

        tester().waitForView(withAccessibilityLabel: "Unread Warnings")
        // have to do multiple scrolls due to lazy v stack not being completely set up and KIF not playing well together
        tester().scrollView(withAccessibilityIdentifier: "Navigation Warning Scroll", byFractionOfSizeHorizontal: 0, vertical: 1.0)
        tester().wait(forTimeInterval: 1)
        tester().scrollView(withAccessibilityIdentifier: "Navigation Warning Scroll", byFractionOfSizeHorizontal: 0, vertical: 1.0)
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Unread Warnings")
    }
    
    func testALotOfNavWarningsScrollTopWithTap() throws {
        try XCTSkipIf(TestHelpers.DISABLE_UI_TESTS, "UI tests are disabled")
        var dateComponents = DateComponents()
        dateComponents.year = 2022
        dateComponents.month = 1
        dateComponents.day = 1
        dateComponents.hour = 12
        dateComponents.minute = 0
        dateComponents.second = 0
        dateComponents.nanosecond = 0
        dateComponents.timeZone = TimeZone(secondsFromGMT: 0)
        
        let year = Calendar.current.date(from: dateComponents)!
        var warnings: [NavigationalWarningModel] = []
        for i in 1...12 {
            var navWarning = NavigationalWarningModel(navArea: "4")
            navWarning.msgYear = 2022
            navWarning.msgNumber = Int(13 - i)
            navWarning.navArea = "4"
            navWarning.subregion = "11,26"
            navWarning.text = "WESTERN NORTH ATLANTIC.\nFLORIDA.\n1. HAZARDOUS OPERATIONS, ROCKET LAUNCHING\n   121606Z TO 121854Z NOV, ALTERNATE\n   131606Z TO 131854Z AND 1607Z TO 1854Z DAILY\n   14 THRU 18 NOV IN AREAS BOUND BY:\n   A. 28-39.92N 080-38.33W, 28-40.00N 079-44.00W,\n      28-28.00N 079-40.00W, 28-29.97N 080-32.29W\n   B. 27-51.00N 073-56.00W, 28-37.00N 073-55.00W,\n      28-40.00N 071-21.00W, 28-13.00N 069-58.00W,\n      27-31.00N 069-58.00W, 27-21.00N 071-43.00W.\n2. CANCEL NAVAREA IV 1165/22.\n3. CANCEL THIS MSG 181954Z NOV 22.\n"
            navWarning.status = "A"
            navWarning.issueDate = Calendar.current.date(bySetting: .month, value: 13 - i, of: year)
            navWarning.authority = "EASTERN RANGE 0/22 072203Z NOV 22."

            warnings.append(navWarning)
        }
        
        class PassThrough: ObservableObject {
            var navArea: String

            init(navArea: String) {
                self.navArea = navArea
            }
        }
        
        struct Container: View {
            
            @ObservedObject var passThrough: PassThrough
            @State var router: MarlinRouter = MarlinRouter()

            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationStack(path: $router.path) {
                    NavigationalWarningNavAreaListView(navArea: passThrough.navArea, mapName: "Navigational Warning List View Map")
                        .marlinRoutes()
                }
                .environmentObject(router)
            }
        }
        let appState = AppState()
        let passThrough = PassThrough(navArea: "4")
        let localDataSource = NavigationalWarningStaticLocalDataSource()
        let remoteDataSource = NavigationalWarningRemoteDataSource()
        InjectedValues[\.navWarningLocalDataSource] = localDataSource
        InjectedValues[\.navWarningRemoteDataSource] = remoteDataSource
        localDataSource.list.append(contentsOf: warnings)
        var routeWaypointRepository = RouteWaypointRepository(localDataSource: RouteWaypointStaticLocalDataSource())

        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        InjectedValues[\.bookmarkLocalDataSource] = bookmarkLocalDataSource
        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
            .environmentObject(routeWaypointRepository)
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "Unread Warnings")
        tester().tapView(withAccessibilityLabel: "Unread Warnings")
        tester().waitForAnimationsToFinish()
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Unread Warnings")
    }
    
    func testALotOfNavWarningsWithLastSeen() throws {
        try XCTSkipIf(TestHelpers.DISABLE_UI_TESTS, "UI tests are disabled")
        var dateComponents = DateComponents()
        dateComponents.year = 2022
        dateComponents.month = 1
        dateComponents.day = 1
        dateComponents.hour = 12
        dateComponents.minute = 0
        dateComponents.second = 0
        dateComponents.nanosecond = 0
        dateComponents.timeZone = TimeZone(secondsFromGMT: 0)
        
        let year = Calendar.current.date(from: dateComponents)!
        var warnings: [NavigationalWarningModel] = []
        for i in 1...12 {
            var navWarning = NavigationalWarningModel(navArea: "4")
            navWarning.msgYear = 2022
            navWarning.msgNumber = Int(13 - i)
            navWarning.navArea = "4"
            navWarning.subregion = "11,26"
            navWarning.text = "WESTERN NORTH ATLANTIC.\nFLORIDA.\n1. HAZARDOUS OPERATIONS, ROCKET LAUNCHING\n   121606Z TO 121854Z NOV, ALTERNATE\n   131606Z TO 131854Z AND 1607Z TO 1854Z DAILY\n   14 THRU 18 NOV IN AREAS BOUND BY:\n   A. 28-39.92N 080-38.33W, 28-40.00N 079-44.00W,\n      28-28.00N 079-40.00W, 28-29.97N 080-32.29W\n   B. 27-51.00N 073-56.00W, 28-37.00N 073-55.00W,\n      28-40.00N 071-21.00W, 28-13.00N 069-58.00W,\n      27-31.00N 069-58.00W, 27-21.00N 071-43.00W.\n2. CANCEL NAVAREA IV 1165/22.\n3. CANCEL THIS MSG 181954Z NOV 22.\n"
            navWarning.status = "A"
            navWarning.issueDate = Calendar.current.date(bySetting: .month, value: 13 - i, of: year)
            navWarning.authority = "EASTERN RANGE 0/22 072203Z NOV 22."

            warnings.append(navWarning)
        }
        
        class PassThrough: ObservableObject {
            var navArea: String

            init(navArea: String) {
                self.navArea = navArea
            }
        }
        
        struct Container: View {
            
            @ObservedObject var passThrough: PassThrough
            @State var router: MarlinRouter = MarlinRouter()

            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationStack(path: $router.path) {
                    NavigationalWarningNavAreaListView(navArea: passThrough.navArea, mapName: "Navigational Warning List View Map")
                        .marlinRoutes()
                }
                .environmentObject(router)
            }
        }
        let appState = AppState()
        let passThrough = PassThrough(navArea: "4")
        
        let localDataSource = NavigationalWarningStaticLocalDataSource()
        let remoteDataSource = NavigationalWarningRemoteDataSource()
        InjectedValues[\.navWarningLocalDataSource] = localDataSource
        InjectedValues[\.navWarningRemoteDataSource] = remoteDataSource
        localDataSource.list.append(contentsOf: warnings)
        var routeWaypointRepository = RouteWaypointRepository(localDataSource: RouteWaypointStaticLocalDataSource())

        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        InjectedValues[\.bookmarkLocalDataSource] = bookmarkLocalDataSource
        UserDefaults.standard.setValue(warnings[5].primaryKey, forKey: "lastSeen-4")
        
        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
            .environmentObject(routeWaypointRepository)
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForAnimationsToFinish()
        
        tester().waitForView(withAccessibilityLabel: "Unread Warnings")
        tester().tapView(withAccessibilityLabel: "Unread Warnings")
        tester().waitForAnimationsToFinish()
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Unread Warnings")
    }
    
    func testALotOfNavWarningsWithLastSeenThatDoesNotExist() throws {
        try XCTSkipIf(TestHelpers.DISABLE_UI_TESTS, "UI tests are disabled")
        var dateComponents = DateComponents()
        dateComponents.year = 2022
        dateComponents.month = 1
        dateComponents.day = 1
        dateComponents.hour = 12
        dateComponents.minute = 0
        dateComponents.second = 0
        dateComponents.nanosecond = 0
        dateComponents.timeZone = TimeZone(secondsFromGMT: 0)
        
        let year = Calendar.current.date(from: dateComponents)!
        var warnings: [NavigationalWarningModel] = []
        for i in 1...12 {
            var navWarning = NavigationalWarningModel(navArea: "4")
            navWarning.msgYear = 2022
            navWarning.msgNumber = Int(13 - i)
            navWarning.navArea = "4"
            navWarning.subregion = "11,26"
            navWarning.text = "WESTERN NORTH ATLANTIC.\nFLORIDA.\n1. HAZARDOUS OPERATIONS, ROCKET LAUNCHING\n   121606Z TO 121854Z NOV, ALTERNATE\n   131606Z TO 131854Z AND 1607Z TO 1854Z DAILY\n   14 THRU 18 NOV IN AREAS BOUND BY:\n   A. 28-39.92N 080-38.33W, 28-40.00N 079-44.00W,\n      28-28.00N 079-40.00W, 28-29.97N 080-32.29W\n   B. 27-51.00N 073-56.00W, 28-37.00N 073-55.00W,\n      28-40.00N 071-21.00W, 28-13.00N 069-58.00W,\n      27-31.00N 069-58.00W, 27-21.00N 071-43.00W.\n2. CANCEL NAVAREA IV 1165/22.\n3. CANCEL THIS MSG 181954Z NOV 22.\n"
            navWarning.status = "A"
            navWarning.issueDate = Calendar.current.date(bySetting: .month, value: 13 - i, of: year)
            navWarning.authority = "EASTERN RANGE 0/22 072203Z NOV 22."

            warnings.append(navWarning)
        }
        
        class PassThrough: ObservableObject {
            var navArea: String

            init(navArea: String) {
                self.navArea = navArea
            }
        }
        
        struct Container: View {
            
            @ObservedObject var passThrough: PassThrough
            @State var router: MarlinRouter = MarlinRouter()

            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationStack(path: $router.path) {
                    NavigationalWarningNavAreaListView(navArea: passThrough.navArea, mapName: "Navigational Warning List View Map")
                        .marlinRoutes()
                }
                .environmentObject(router)
            }
        }
        let appState = AppState()
        let passThrough = PassThrough(navArea: "4")
        
        UserDefaults.standard.setValue("no", forKey: "lastSeen-4")
        let localDataSource = NavigationalWarningStaticLocalDataSource()
        let remoteDataSource = NavigationalWarningRemoteDataSource()
        InjectedValues[\.navWarningLocalDataSource] = localDataSource
        InjectedValues[\.navWarningRemoteDataSource] = remoteDataSource
        localDataSource.list.append(contentsOf: warnings)
        var routeWaypointRepository = RouteWaypointRepository(localDataSource: RouteWaypointStaticLocalDataSource())

        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        InjectedValues[\.bookmarkLocalDataSource] = bookmarkLocalDataSource
        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
            .environmentObject(routeWaypointRepository)
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForAnimationsToFinish()
        
        tester().waitForView(withAccessibilityLabel: "Unread Warnings")
        tester().tapView(withAccessibilityLabel: "Unread Warnings")
        tester().waitForAnimationsToFinish()
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Unread Warnings")
    }

}
