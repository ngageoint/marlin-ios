//
//  NavigationalWarningsOverviewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/15/23.
//

import XCTest
import Combine
import SwiftUI

@testable import Marlin

final class NavigationalWarningsOverviewTests: XCTestCase {

    override func setUp() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults()
    }
    
    func testNavWarningNoCurrentArea() throws {
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
            
        var navWarning2 = NavigationalWarningModel(navArea: "A")
        navWarning2.msgYear = 2022
        navWarning2.msgNumber = 1178
        navWarning2.navArea = "A"
        navWarning2.subregion = "11,26"
        navWarning2.text = "WESTERN NORTH ATLANTIC.\nFLORIDA.\n1. HAZARDOUS OPERATIONS, ROCKET LAUNCHING\n   121606Z TO 121854Z NOV, ALTERNATE\n   131606Z TO 131854Z AND 1607Z TO 1854Z DAILY\n   14 THRU 18 NOV IN AREAS BOUND BY:\n   A. 28-39.92N 080-38.33W, 28-40.00N 079-44.00W,\n      28-28.00N 079-40.00W, 28-29.97N 080-32.29W\n   B. 27-51.00N 073-56.00W, 28-37.00N 073-55.00W,\n      28-40.00N 071-21.00W, 28-13.00N 069-58.00W,\n      27-31.00N 069-58.00W, 27-21.00N 071-43.00W.\n2. CANCEL NAVAREA IV 1165/22.\n3. CANCEL THIS MSG 181954Z NOV 22.\n"
        navWarning2.status = "A"
        navWarning2.issueDate = Date()
        navWarning2.authority = "EASTERN RANGE 0/22 072203Z NOV 22."

        warnings.append(navWarning2)
            
        var navWarning3 = NavigationalWarningModel(navArea: "A")
        navWarning3.msgYear = 2022
        navWarning3.msgNumber = 1179
        navWarning3.navArea = "A"
        navWarning3.subregion = "11,26"
        navWarning3.text = "WESTERN NORTH ATLANTIC.\nFLORIDA.\n1. HAZARDOUS OPERATIONS, ROCKET LAUNCHING\n   121606Z TO 121854Z NOV, ALTERNATE\n   131606Z TO 131854Z AND 1607Z TO 1854Z DAILY\n   14 THRU 18 NOV IN AREAS BOUND BY:\n   A. 28-39.92N 080-38.33W, 28-40.00N 079-44.00W,\n      28-28.00N 079-40.00W, 28-29.97N 080-32.29W\n   B. 27-51.00N 073-56.00W, 28-37.00N 073-55.00W,\n      28-40.00N 071-21.00W, 28-13.00N 069-58.00W,\n      27-31.00N 069-58.00W, 27-21.00N 071-43.00W.\n2. CANCEL NAVAREA IV 1165/22.\n3. CANCEL THIS MSG 181954Z NOV 22.\n"
        navWarning3.status = "A"
        navWarning3.issueDate = Date()
        navWarning3.authority = "EASTERN RANGE 0/22 072203Z NOV 22."

        class PassThrough: ObservableObject {
            @Published var navArea: NavigationalWarningNavArea?
        }

        struct Container: View {
            @EnvironmentObject var locationManager: LocationManager
            @ObservedObject var passThrough: PassThrough
            @StateObject var focusedItem: ItemWrapper = ItemWrapper()
            @State var router: MarlinRouter = MarlinRouter()

            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }

            var body: some View {
                NavigationStack(path: $router.path) {
                    NavigationalWarningsOverview(focusedItem: focusedItem)
                        .environmentObject(locationManager)
                }
                .onAppear {
                    locationManager.currentNavArea = passThrough.navArea
                    GeneralLocation.shared.currentNavArea = passThrough.navArea
                    GeneralLocation.shared.currentNavAreaName = GeneralLocation.shared.currentNavArea?.name
                    //                    locationManager.currentNavArea = .NAVAREA_IV
                }
                .onChange(of: passThrough.navArea) { newValue in
                    locationManager.currentNavArea = newValue
                    GeneralLocation.shared.currentNavArea = newValue
                    GeneralLocation.shared.currentNavAreaName = newValue?.name
                }
                .environmentObject(router)
                .marlinRoutes()
            }
        }
        let appState = AppState()
        let passThrough = PassThrough()
        let mockCLLocation = MockCLLocationManager()
        let mockLocationManager = MockLocationManager(locationManager: mockCLLocation)
        mockLocationManager.currentNavArea = nil
        let localDataSource = NavigationalWarningStaticLocalDataSource()
        let remoteDataSource = NavigationalWarningRemoteDataSource()
        InjectedValues[\.navWarningLocalDataSource] = localDataSource
        InjectedValues[\.navWarningRemoteDataSource] = remoteDataSource
        localDataSource.list.append(contentsOf: warnings)
        var routeWaypointRepository = RouteWaypointRepository(localDataSource: RouteWaypointStaticLocalDataSource())

        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        let bookmarkRepository = BookmarkRepository(localDataSource: bookmarkLocalDataSource)
        let mapFeatureRepository = NavigationalWarningsMapFeatureRepository()

        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
            .environmentObject(mockLocationManager as LocationManager)
            .environmentObject(bookmarkRepository)
            .environmentObject(routeWaypointRepository)
            .environmentObject(mapFeatureRepository)
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller

        tester().waitForAnimationsToFinish()

        passThrough.navArea = nil
        tester().waitForView(withAccessibilityLabel: "NAVAREA IV")
        tester().waitForView(withAccessibilityLabel: "HYDROLANT")
    }
    
    func testNavWarningCurrentArea() throws {
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
            
        var navWarning2 = NavigationalWarningModel(navArea: "A")
        navWarning2.msgYear = 2022
        navWarning2.msgNumber = 1178
        navWarning2.navArea = "A"
        navWarning2.subregion = "11,26"
        navWarning2.text = "WESTERN NORTH ATLANTIC.\nFLORIDA.\n1. HAZARDOUS OPERATIONS, ROCKET LAUNCHING\n   121606Z TO 121854Z NOV, ALTERNATE\n   131606Z TO 131854Z AND 1607Z TO 1854Z DAILY\n   14 THRU 18 NOV IN AREAS BOUND BY:\n   A. 28-39.92N 080-38.33W, 28-40.00N 079-44.00W,\n      28-28.00N 079-40.00W, 28-29.97N 080-32.29W\n   B. 27-51.00N 073-56.00W, 28-37.00N 073-55.00W,\n      28-40.00N 071-21.00W, 28-13.00N 069-58.00W,\n      27-31.00N 069-58.00W, 27-21.00N 071-43.00W.\n2. CANCEL NAVAREA IV 1165/22.\n3. CANCEL THIS MSG 181954Z NOV 22.\n"
        navWarning2.status = "A"
        navWarning2.issueDate = Date()
        navWarning2.authority = "EASTERN RANGE 0/22 072203Z NOV 22."

        warnings.append(navWarning2)
            
        var navWarning3 = NavigationalWarningModel(navArea: "A")
        navWarning3.msgYear = 2022
        navWarning3.msgNumber = 1179
        navWarning3.navArea = "A"
        navWarning3.subregion = "11,26"
        navWarning3.text = "WESTERN NORTH ATLANTIC.\nFLORIDA.\n1. HAZARDOUS OPERATIONS, ROCKET LAUNCHING\n   121606Z TO 121854Z NOV, ALTERNATE\n   131606Z TO 131854Z AND 1607Z TO 1854Z DAILY\n   14 THRU 18 NOV IN AREAS BOUND BY:\n   A. 28-39.92N 080-38.33W, 28-40.00N 079-44.00W,\n      28-28.00N 079-40.00W, 28-29.97N 080-32.29W\n   B. 27-51.00N 073-56.00W, 28-37.00N 073-55.00W,\n      28-40.00N 071-21.00W, 28-13.00N 069-58.00W,\n      27-31.00N 069-58.00W, 27-21.00N 071-43.00W.\n2. CANCEL NAVAREA IV 1165/22.\n3. CANCEL THIS MSG 181954Z NOV 22.\n"
        navWarning3.status = "A"
        navWarning3.issueDate = Date()
        navWarning3.authority = "EASTERN RANGE 0/22 072203Z NOV 22."

        warnings.append(navWarning3)
        
        class PassThrough: ObservableObject {
            @Published var navArea: NavigationalWarningNavArea?
        }
        
        struct Container: View {
            @EnvironmentObject var locationManager: LocationManager
            @ObservedObject var passThrough: PassThrough
            @StateObject var focusedItem: ItemWrapper = ItemWrapper()
            @State var router: MarlinRouter = MarlinRouter()

            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationStack(path: $router.path) {
                    NavigationalWarningsOverview(focusedItem: focusedItem)
                        .environmentObject(locationManager)
                }
                .marlinRoutes()
                .onAppear {
                    GeneralLocation.shared.currentNavArea = .NAVAREA_IV
                    GeneralLocation.shared.currentNavAreaName = GeneralLocation.shared.currentNavArea?.name
//                    locationManager.currentNavArea = .NAVAREA_IV
                }
                .onChange(of: passThrough.navArea) { newValue in
                    locationManager.currentNavArea = newValue
                    GeneralLocation.shared.currentNavArea = newValue
                    GeneralLocation.shared.currentNavAreaName = newValue?.name
                }
                 
            }
        }
        let appState = AppState()
        let passThrough = PassThrough()
        let mockCLLocation = MockCLLocationManager()
        let mockLocationManager = MockLocationManager(locationManager: mockCLLocation)
        mockLocationManager.currentNavArea = nil
        var localDataSource = NavigationalWarningStaticLocalDataSource()
        let remoteDataSource = NavigationalWarningRemoteDataSource()
        InjectedValues[\.navWarningLocalDataSource] = localDataSource
        InjectedValues[\.navWarningRemoteDataSource] = remoteDataSource
        localDataSource.list.append(contentsOf: warnings)
        var routeWaypointRepository = RouteWaypointRepository(localDataSource: RouteWaypointStaticLocalDataSource())

        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        let bookmarkRepository = BookmarkRepository(localDataSource: bookmarkLocalDataSource)
        let mapFeatureRepository = NavigationalWarningsMapFeatureRepository()

        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
            .environmentObject(mockLocationManager as LocationManager)
            .environmentObject(bookmarkRepository)
            .environmentObject(routeWaypointRepository)
            .environmentObject(mapFeatureRepository)
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "NAVAREA IV (Current)")
        tester().waitForView(withAccessibilityLabel: "HYDROLANT")
        
        passThrough.navArea = .HYDROLANT
        tester().waitForView(withAccessibilityLabel: "NAVAREA IV")
        tester().waitForView(withAccessibilityLabel: "HYDROLANT (Current)")
    }
}
