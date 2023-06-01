//
//  OnboardingViewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/25/23.
//

import XCTest
import SwiftUI
import Combine
import CoreLocation

@testable import Marlin

final class OnboardingViewTests: XCTestCase {
    
    override func setUp() async throws {
        await TestHelpers.asyncGetKeyWindowVisible()

        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults()
    }
    
    override func tearDown() {
    }
    
    func testFlow() throws {
        UserDefaults.standard.set(false, forKey: "disclaimerAccepted")
        UserDefaults.standard.set(false, forKey: "onboardingComplete")
        UserDefaults.standard.set(true, forKey: "showOnMap\(Asam.key)")
        UserDefaults.standard.set(true, forKey: "showOnMap\(Modu.key)")
        UserDefaults.standard.set(true, forKey: "showOnMap\(Light.key)")
        UserDefaults.standard.set(true, forKey: "showOnMap\(Port.key)")
        UserDefaults.standard.set(true, forKey: "showOnMap\(RadioBeacon.key)")
        UserDefaults.standard.set(true, forKey: "showOnMap\(DifferentialGPSStation.key)")
        
        let initialTabs = 2
        UserDefaults.standard.set(initialTabs, forKey: "userTabs")
        
        let mockLocationManager = MockCLLocationManager()
        let locationManager = LocationManager.shared(locationManager: mockLocationManager)
        (locationManager.locationManager as? MockCLLocationManager)?.overriddenAuthStatus = .notDetermined
        locationManager.locationManager(locationManager.locationManager!, didChangeAuthorization: .notDetermined)
        
        UNNotificationSettings.swizzleAuthorizationStatus()
        
        let mockUserNotificationCenter = UserNotificationCenterMock()
        
        class PassThrough {
            var dataSourceListAll: [DataSourceItem]?
            var dataSourceListTabs: [DataSourceItem]?
            var dataSourceListNonTabs: [DataSourceItem]?
            var dataSourceMapped: [DataSourceItem]?
        }
        
        struct Container: View {
            var passThrough: PassThrough
            var userNotificationCenter: UserNotificationCenter
            
            init(passThrough: PassThrough, userNotificationCenter: UserNotificationCenter) {
                self.passThrough = passThrough
                self.userNotificationCenter = userNotificationCenter
            }
            
            var body: some View {
                OnboardingView(userNotificationCenter: userNotificationCenter)
            }
        }
        let passThrough = PassThrough()
        UNNotificationSettings.fakeAuthorizationStatus = .notDetermined
        let dataSourceList: DataSourceList = DataSourceList()
        XCTAssertEqual(dataSourceList.tabItems.count, 10)
        
        let container = Container(passThrough: passThrough, userNotificationCenter: mockUserNotificationCenter)
            .environmentObject(locationManager)
            .environmentObject(dataSourceList)
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Set Sail")
        tester().tapView(withAccessibilityLabel: "Set Sail")
        
        tester().waitForView(withAccessibilityLabel: "Accept")
        tester().tapView(withAccessibilityLabel: "Accept")
        tester().waitForView(withAccessibilityLabel: "Yes, Enable My Location")
        tester().tapView(withAccessibilityLabel: "Yes, Enable My Location")
        
        XCTAssertTrue((locationManager.locationManager as? MockCLLocationManager)!.requestAuthorizationCalled)
        
        tester().waitForView(withAccessibilityLabel: "Yes, Enable Notifications")
        tester().tapView(withAccessibilityLabel: "Yes, Enable Notifications")
        
        XCTAssertTrue(mockUserNotificationCenter.requestAuthorizationCalled)
        
        tester().waitForView(withAccessibilityLabel: "Marlin Tabs")
        for tab in dataSourceList.allTabs {
            tester().waitForView(withAccessibilityLabel: "\(tab.dataSource.fullDataSourceName) Tab")
        }
        
        XCTAssertEqual(dataSourceList.tabs.count, initialTabs)
        for tab in dataSourceList.tabs {
            // verify they are checked
            tester().waitForView(withAccessibilityLabel: "\(tab.dataSource.fullDataSourceName) Tab On")
        }
        
        for nontab in dataSourceList.nonTabs {
            // verify they are not checked
            tester().waitForView(withAccessibilityLabel: "\(nontab.dataSource.fullDataSourceName) Tab Off")
        }
        
        let firstNonTab = dataSourceList.nonTabs[0].dataSource.fullDataSourceName
        tester().tapView(withAccessibilityLabel: "\(firstNonTab) Tab Off")
        tester().waitForView(withAccessibilityLabel: "\(firstNonTab) Tab On")
        XCTAssertEqual(dataSourceList.tabs.count, initialTabs + 1)
        
        let secondNonTab = dataSourceList.nonTabs[0].dataSource.fullDataSourceName
        tester().tapView(withAccessibilityLabel: "\(secondNonTab) Tab Off")
        tester().waitForView(withAccessibilityLabel: "\(secondNonTab) Tab On")
        XCTAssertEqual(dataSourceList.tabs.count, initialTabs + 2)
        
        let thirdNonTab = dataSourceList.nonTabs[0].dataSource.fullDataSourceName
        tester().tapView(withAccessibilityLabel: "\(thirdNonTab) Tab Off")
        tester().waitForView(withAccessibilityLabel: "\(thirdNonTab) Tab On")
        XCTAssertEqual(dataSourceList.tabs.count, DataSourceList.MAX_TABS)
        
        let fourthNonTab = dataSourceList.nonTabs[0].dataSource.fullDataSourceName
        tester().tapView(withAccessibilityLabel: "\(fourthNonTab) Tab Off")
        tester().waitForView(withAccessibilityLabel: "\(fourthNonTab) Tab On")
        XCTAssertEqual(dataSourceList.tabs.count, DataSourceList.MAX_TABS)
        
        tester().waitForView(withAccessibilityLabel: "Next")
        tester().tapView(withAccessibilityLabel: "Next")
        
        // order should match the order the user chose
        XCTAssertEqual(dataSourceList.tabs[0].dataSource.fullDataSourceName, firstNonTab)
        XCTAssertEqual(dataSourceList.tabs[1].dataSource.fullDataSourceName, secondNonTab)
        XCTAssertEqual(dataSourceList.tabs[2].dataSource.fullDataSourceName, thirdNonTab)
        XCTAssertEqual(dataSourceList.tabs[3].dataSource.fullDataSourceName, fourthNonTab)
        
        
        tester().waitForView(withAccessibilityLabel: "Marlin Map")
        for tab in dataSourceList.allTabs.filter({ item in
            item.dataSource.isMappable
        }) {
            tester().waitForView(withAccessibilityLabel: "\(tab.dataSource.fullDataSourceName) Map")
        }
        
        for mapped in dataSourceList.mappedDataSources {
            // verify they are checked
            tester().waitForView(withAccessibilityLabel: "\(mapped.dataSource.fullDataSourceName) Map On")
            // flip em
            tester().tapView(withAccessibilityLabel: "\(mapped.dataSource.fullDataSourceName) Map On")
            tester().waitForView(withAccessibilityLabel: "\(mapped.dataSource.fullDataSourceName) Map Off")
            // flip it back
            tester().tapView(withAccessibilityLabel: "\(mapped.dataSource.fullDataSourceName) Map Off")
            tester().waitForView(withAccessibilityLabel: "\(mapped.dataSource.fullDataSourceName) Map On")
        }
        
        for nonmapped in dataSourceList.allTabs.filter({ item in
            !item.showOnMap && item.dataSource.isMappable
        }) {
            // verify they are not checked
            tester().waitForView(withAccessibilityLabel: "\(nonmapped.dataSource.fullDataSourceName) Map Off")
            // flip it
            tester().tapView(withAccessibilityLabel: "\(nonmapped.dataSource.fullDataSourceName) Map Off")
            tester().waitForView(withAccessibilityLabel: "\(nonmapped.dataSource.fullDataSourceName) Map On")
            // flip it back
            tester().tapView(withAccessibilityLabel: "\(nonmapped.dataSource.fullDataSourceName) Map On")
            tester().waitForView(withAccessibilityLabel: "\(nonmapped.dataSource.fullDataSourceName) Map Off")
        }
        
        tester().waitForView(withAccessibilityLabel: "Take Me To Marlin")
        tester().tapView(withAccessibilityLabel: "Take Me To Marlin")
        
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "onboardingComplete"))
    }
    
    func testNotNowFlow() throws {
        UserDefaults.standard.set(false, forKey: "disclaimerAccepted")
        UserDefaults.standard.set(false, forKey: "onboardingComplete")
        UserDefaults.standard.set(true, forKey: "showOnMap\(Asam.key)")
        UserDefaults.standard.set(true, forKey: "showOnMap\(Modu.key)")
        UserDefaults.standard.set(true, forKey: "showOnMap\(Light.key)")
        UserDefaults.standard.set(true, forKey: "showOnMap\(Port.key)")
        UserDefaults.standard.set(true, forKey: "showOnMap\(RadioBeacon.key)")
        UserDefaults.standard.set(true, forKey: "showOnMap\(DifferentialGPSStation.key)")
        
        let initialTabs = 2
        UserDefaults.standard.set(initialTabs, forKey: "userTabs")
        
        let mockLocationManager = MockCLLocationManager()
        let locationManager = LocationManager.shared(locationManager: mockLocationManager)
        (locationManager.locationManager as? MockCLLocationManager)?.overriddenAuthStatus = .notDetermined
        locationManager.locationManager(mockLocationManager, didChangeAuthorization: .notDetermined)
        
        UNNotificationSettings.swizzleAuthorizationStatus()
        
        let mockUserNotificationCenter = UserNotificationCenterMock()
        
        class PassThrough {
            var dataSourceListAll: [DataSourceItem]?
            var dataSourceListTabs: [DataSourceItem]?
            var dataSourceListNonTabs: [DataSourceItem]?
            var dataSourceMapped: [DataSourceItem]?
        }
        
        struct Container: View {
            @StateObject var dataSourceList: DataSourceList = DataSourceList()
            
            var passThrough: PassThrough
            var userNotificationCenter: UserNotificationCenter
            
            init(passThrough: PassThrough, userNotificationCenter: UserNotificationCenter) {
                self.passThrough = passThrough
                self.userNotificationCenter = userNotificationCenter
            }
            
            var body: some View {
                OnboardingView(userNotificationCenter: userNotificationCenter)
                    .environmentObject(dataSourceList)
                    .onChange(of: dataSourceList.tabs) { newValue in
                        passThrough.dataSourceListTabs = newValue
                    }
                    .onChange(of: dataSourceList.nonTabs) { newValue in
                        passThrough.dataSourceListNonTabs = newValue
                    }
                    .onChange(of: dataSourceList.allTabs) { newValue in
                        passThrough.dataSourceListAll = newValue
                    }
                    .onChange(of: dataSourceList.mappedDataSources) { newValue in
                        passThrough.dataSourceMapped = newValue
                    }
                    .onAppear {
                        self.passThrough.dataSourceListAll = dataSourceList.allTabs
                        self.passThrough.dataSourceListTabs = dataSourceList.tabs
                        self.passThrough.dataSourceListNonTabs = dataSourceList.nonTabs
                        self.passThrough.dataSourceMapped = dataSourceList.mappedDataSources
                    }
            }
        }
        let passThrough = PassThrough()
        UNNotificationSettings.fakeAuthorizationStatus = .notDetermined
        let container = Container(passThrough: passThrough, userNotificationCenter: mockUserNotificationCenter)
            .environmentObject(locationManager)
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Set Sail")
        tester().tapView(withAccessibilityLabel: "Set Sail")
        tester().waitForView(withAccessibilityLabel: "Accept")
        tester().tapView(withAccessibilityLabel: "Accept")
        tester().waitForView(withAccessibilityLabel: "Not Now")
        tester().tapView(withAccessibilityLabel: "Not Now")
        
        XCTAssertFalse(mockLocationManager.requestAuthorizationCalled)
        
        tester().waitForView(withAccessibilityLabel: "Not Now")
        tester().tapView(withAccessibilityLabel: "Not Now")
        
        XCTAssertFalse(mockUserNotificationCenter.requestAuthorizationCalled)
        
        tester().waitForView(withAccessibilityLabel: "Marlin Tabs")
        for tab in passThrough.dataSourceListAll! {
            tester().waitForView(withAccessibilityLabel: "\(tab.dataSource.fullDataSourceName) Tab")
        }
        
        XCTAssertEqual(passThrough.dataSourceListTabs!.count, initialTabs)
        for tab in passThrough.dataSourceListTabs! {
            // verify they are checked
            tester().waitForView(withAccessibilityLabel: "\(tab.dataSource.fullDataSourceName) Tab On")
        }
        
        for nontab in passThrough.dataSourceListNonTabs! {
            // verify they are not checked
            tester().waitForView(withAccessibilityLabel: "\(nontab.dataSource.fullDataSourceName) Tab Off")
        }
        
        let firstNonTab = passThrough.dataSourceListNonTabs![0].dataSource.fullDataSourceName
        tester().tapView(withAccessibilityLabel: "\(firstNonTab) Tab Off")
        tester().waitForView(withAccessibilityLabel: "\(firstNonTab) Tab On")
        XCTAssertEqual(passThrough.dataSourceListTabs!.count, initialTabs + 1)
        
        let secondNonTab = passThrough.dataSourceListNonTabs![0].dataSource.fullDataSourceName
        tester().tapView(withAccessibilityLabel: "\(secondNonTab) Tab Off")
        tester().waitForView(withAccessibilityLabel: "\(secondNonTab) Tab On")
        XCTAssertEqual(passThrough.dataSourceListTabs!.count, initialTabs + 2)
        
        let thirdNonTab = passThrough.dataSourceListNonTabs![0].dataSource.fullDataSourceName
        tester().tapView(withAccessibilityLabel: "\(thirdNonTab) Tab Off")
        tester().waitForView(withAccessibilityLabel: "\(thirdNonTab) Tab On")
        XCTAssertEqual(passThrough.dataSourceListTabs!.count, DataSourceList.MAX_TABS)
        
        let fourthNonTab = passThrough.dataSourceListNonTabs![0].dataSource.fullDataSourceName
        tester().tapView(withAccessibilityLabel: "\(fourthNonTab) Tab Off")
        tester().waitForView(withAccessibilityLabel: "\(fourthNonTab) Tab On")
        XCTAssertEqual(passThrough.dataSourceListTabs!.count, DataSourceList.MAX_TABS)
        
        tester().waitForView(withAccessibilityLabel: "Next")
        tester().tapView(withAccessibilityLabel: "Next")
        
        // order should match the order the user chose
        XCTAssertEqual(passThrough.dataSourceListTabs![0].dataSource.fullDataSourceName, firstNonTab)
        XCTAssertEqual(passThrough.dataSourceListTabs![1].dataSource.fullDataSourceName, secondNonTab)
        XCTAssertEqual(passThrough.dataSourceListTabs![2].dataSource.fullDataSourceName, thirdNonTab)
        XCTAssertEqual(passThrough.dataSourceListTabs![3].dataSource.fullDataSourceName, fourthNonTab)
        
        
        tester().waitForView(withAccessibilityLabel: "Marlin Map")
        for tab in passThrough.dataSourceListAll!.filter({ item in
            item.dataSource.isMappable
        }) {
            tester().waitForView(withAccessibilityLabel: "\(tab.dataSource.fullDataSourceName) Map")
        }
        
        for mapped in passThrough.dataSourceMapped! {
            // verify they are checked
            tester().waitForView(withAccessibilityLabel: "\(mapped.dataSource.fullDataSourceName) Map On")
            // flip em
            tester().tapView(withAccessibilityLabel: "\(mapped.dataSource.fullDataSourceName) Map On")
            tester().waitForView(withAccessibilityLabel: "\(mapped.dataSource.fullDataSourceName) Map Off")
            // flip it back
            tester().tapView(withAccessibilityLabel: "\(mapped.dataSource.fullDataSourceName) Map Off")
            tester().waitForView(withAccessibilityLabel: "\(mapped.dataSource.fullDataSourceName) Map On")
        }
        
        for nonmapped in passThrough.dataSourceListAll!.filter({ item in
            !item.showOnMap && item.dataSource.isMappable
        }) {
            // verify they are not checked
            tester().waitForView(withAccessibilityLabel: "\(nonmapped.dataSource.fullDataSourceName) Map Off")
            // flip it
            tester().tapView(withAccessibilityLabel: "\(nonmapped.dataSource.fullDataSourceName) Map Off")
            tester().waitForView(withAccessibilityLabel: "\(nonmapped.dataSource.fullDataSourceName) Map On")
            // flip it back
            tester().tapView(withAccessibilityLabel: "\(nonmapped.dataSource.fullDataSourceName) Map On")
            tester().waitForView(withAccessibilityLabel: "\(nonmapped.dataSource.fullDataSourceName) Map Off")
        }
        
        tester().waitForView(withAccessibilityLabel: "Take Me To Marlin")
        tester().tapView(withAccessibilityLabel: "Take Me To Marlin")
        
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "onboardingComplete"))
    }
    
    func testFlowNotificationAccessGranted() throws {
        UserDefaults.standard.set(false, forKey: "disclaimerAccepted")
        UserDefaults.standard.set(false, forKey: "onboardingComplete")
        UserDefaults.standard.set(true, forKey: "showOnMap\(Asam.key)")
        UserDefaults.standard.set(true, forKey: "showOnMap\(Modu.key)")
        UserDefaults.standard.set(true, forKey: "showOnMap\(Light.key)")
        UserDefaults.standard.set(true, forKey: "showOnMap\(Port.key)")
        UserDefaults.standard.set(true, forKey: "showOnMap\(RadioBeacon.key)")
        UserDefaults.standard.set(true, forKey: "showOnMap\(DifferentialGPSStation.key)")
        
        let mockLocationManager = MockCLLocationManager()
        let locationManager = LocationManager.shared(locationManager: mockLocationManager)
        (locationManager.locationManager as? MockCLLocationManager)?.overriddenAuthStatus = .notDetermined
        locationManager.locationManager(mockLocationManager, didChangeAuthorization: .notDetermined)
        UNNotificationSettings.swizzleAuthorizationStatus()
        
        let mockUserNotificationCenter = UserNotificationCenterMock()
        
        struct Container: View {
            @StateObject var dataSourceList: DataSourceList = DataSourceList()
            
            var userNotificationCenter: UserNotificationCenter
            
            init(userNotificationCenter: UserNotificationCenter) {
                self.userNotificationCenter = userNotificationCenter
            }
            
            var body: some View {
                OnboardingView(userNotificationCenter: userNotificationCenter)
                    .environmentObject(dataSourceList)
            }
        }
        
        UNNotificationSettings.fakeAuthorizationStatus = .authorized
        
        let controller = UIHostingController(rootView: Container(userNotificationCenter: mockUserNotificationCenter)
            .environmentObject(locationManager))
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Set Sail")
        tester().tapView(withAccessibilityLabel: "Set Sail")
        tester().waitForView(withAccessibilityLabel: "Accept")
        tester().tapView(withAccessibilityLabel: "Accept")
        tester().waitForView(withAccessibilityLabel: "Yes, Enable My Location")
        tester().tapView(withAccessibilityLabel: "Yes, Enable My Location")
        
        XCTAssertTrue((locationManager.locationManager as? MockCLLocationManager)!.requestAuthorizationCalled)
        
        tester().waitForView(withAccessibilityLabel: "Marlin Tabs")
        
    }
    
    func testFlowDisclaimerAccepted() throws {
        UserDefaults.standard.set(true, forKey: "disclaimerAccepted")
        UserDefaults.standard.set(false, forKey: "onboardingComplete")
        UserDefaults.standard.set(true, forKey: "showOnMap\(Asam.key)")
        UserDefaults.standard.set(true, forKey: "showOnMap\(Modu.key)")
        UserDefaults.standard.set(true, forKey: "showOnMap\(Light.key)")
        UserDefaults.standard.set(true, forKey: "showOnMap\(Port.key)")
        UserDefaults.standard.set(true, forKey: "showOnMap\(RadioBeacon.key)")
        UserDefaults.standard.set(true, forKey: "showOnMap\(DifferentialGPSStation.key)")
        
        let mockLocationManager = MockCLLocationManager()
        let locationManager = LocationManager.shared(locationManager: mockLocationManager)
        (locationManager.locationManager as? MockCLLocationManager)?.overriddenAuthStatus = .notDetermined
        locationManager.locationManager(mockLocationManager, didChangeAuthorization: .notDetermined)
        
        UNNotificationSettings.swizzleAuthorizationStatus()
        
        let mockUserNotificationCenter = UserNotificationCenterMock()
        
        struct Container: View {
            @StateObject var dataSourceList: DataSourceList = DataSourceList()
            
            var userNotificationCenter: UserNotificationCenter
            
            init(userNotificationCenter: UserNotificationCenter) {
                self.userNotificationCenter = userNotificationCenter
            }
            
            var body: some View {
                OnboardingView(userNotificationCenter: userNotificationCenter)
                    .environmentObject(dataSourceList)
            }
        }
        
        UNNotificationSettings.fakeAuthorizationStatus = .authorized
        
        let controller = UIHostingController(rootView: Container(userNotificationCenter: mockUserNotificationCenter)
            .environmentObject(locationManager))
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Set Sail")
        tester().tapView(withAccessibilityLabel: "Set Sail")
        tester().waitForView(withAccessibilityLabel: "Yes, Enable My Location")
    }
    
    func testFlowDisclaimerAndLocationAccessGranted() throws {
        UserDefaults.standard.set(true, forKey: "disclaimerAccepted")
        UserDefaults.standard.set(false, forKey: "onboardingComplete")
        UserDefaults.standard.set(true, forKey: "showOnMap\(Asam.key)")
        UserDefaults.standard.set(true, forKey: "showOnMap\(Modu.key)")
        UserDefaults.standard.set(true, forKey: "showOnMap\(Light.key)")
        UserDefaults.standard.set(true, forKey: "showOnMap\(Port.key)")
        UserDefaults.standard.set(true, forKey: "showOnMap\(RadioBeacon.key)")
        UserDefaults.standard.set(true, forKey: "showOnMap\(DifferentialGPSStation.key)")
        
        let mockLocationManager = MockCLLocationManager()
        let locationManager = LocationManager.shared(locationManager: mockLocationManager)
        (locationManager.locationManager as? MockCLLocationManager)?.overriddenAuthStatus = .authorizedAlways
        locationManager.locationManager(mockLocationManager, didChangeAuthorization: .authorizedAlways)
        
        UNNotificationSettings.swizzleAuthorizationStatus()
        
        let mockUserNotificationCenter = UserNotificationCenterMock()
        
        struct Container: View {
            @StateObject var dataSourceList: DataSourceList = DataSourceList()
            
            var userNotificationCenter: UserNotificationCenter
            
            init(userNotificationCenter: UserNotificationCenter) {
                self.userNotificationCenter = userNotificationCenter
            }
            
            var body: some View {
                OnboardingView(userNotificationCenter: userNotificationCenter)
                    .environmentObject(dataSourceList)
            }
        }
        
        UNNotificationSettings.fakeAuthorizationStatus = .notDetermined
        
        let controller = UIHostingController(rootView: Container(userNotificationCenter: mockUserNotificationCenter)
            .environmentObject(locationManager))
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Set Sail")
        tester().tapView(withAccessibilityLabel: "Set Sail")
        tester().waitForView(withAccessibilityLabel: "Yes, Enable Notifications")
        
    }
    
    func testFlowDisclaimerAndLocationAccessGrantedAndNotificationAccessGranted() throws {
        UserDefaults.standard.set(true, forKey: "disclaimerAccepted")
        UserDefaults.standard.set(false, forKey: "onboardingComplete")
        UserDefaults.standard.set(true, forKey: "showOnMap\(Asam.key)")
        UserDefaults.standard.set(true, forKey: "showOnMap\(Modu.key)")
        UserDefaults.standard.set(true, forKey: "showOnMap\(Light.key)")
        UserDefaults.standard.set(true, forKey: "showOnMap\(Port.key)")
        UserDefaults.standard.set(true, forKey: "showOnMap\(RadioBeacon.key)")
        UserDefaults.standard.set(true, forKey: "showOnMap\(DifferentialGPSStation.key)")
        
        let mockLocationManager = MockCLLocationManager()
        let locationManager = LocationManager.shared(locationManager: mockLocationManager)
        (locationManager.locationManager as? MockCLLocationManager)?.overriddenAuthStatus = .authorizedAlways
        locationManager.locationManager(mockLocationManager, didChangeAuthorization: .authorizedAlways)
        
        UNNotificationSettings.swizzleAuthorizationStatus()
        
        let mockUserNotificationCenter = UserNotificationCenterMock()
        
        struct Container: View {
            @StateObject var dataSourceList: DataSourceList = DataSourceList()
            
            var userNotificationCenter: UserNotificationCenter
            
            init(userNotificationCenter: UserNotificationCenter) {
                self.userNotificationCenter = userNotificationCenter
            }
            
            var body: some View {
                OnboardingView(userNotificationCenter: userNotificationCenter)
                    .environmentObject(dataSourceList)
            }
        }
        
        UNNotificationSettings.fakeAuthorizationStatus = .authorized
        
        let controller = UIHostingController(rootView: Container(userNotificationCenter: mockUserNotificationCenter)
            .environmentObject(locationManager))
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Set Sail")
        tester().tapView(withAccessibilityLabel: "Set Sail")
        tester().waitForView(withAccessibilityLabel: "Marlin Tabs")
        
    }
    
    func testFlowLocationAccessGranted() throws {
        UserDefaults.standard.set(false, forKey: "disclaimerAccepted")
        UserDefaults.standard.set(false, forKey: "onboardingComplete")
        UserDefaults.standard.set(true, forKey: "showOnMap\(Asam.key)")
        UserDefaults.standard.set(true, forKey: "showOnMap\(Modu.key)")
        UserDefaults.standard.set(true, forKey: "showOnMap\(Light.key)")
        UserDefaults.standard.set(true, forKey: "showOnMap\(Port.key)")
        UserDefaults.standard.set(true, forKey: "showOnMap\(RadioBeacon.key)")
        UserDefaults.standard.set(true, forKey: "showOnMap\(DifferentialGPSStation.key)")
        
        let mockLocationManager = MockCLLocationManager()
        let locationManager = LocationManager.shared(locationManager: mockLocationManager)
        (locationManager.locationManager as? MockCLLocationManager)?.overriddenAuthStatus = .authorizedAlways
        locationManager.locationManager(mockLocationManager, didChangeAuthorization: .authorizedAlways)
        
        UNNotificationSettings.swizzleAuthorizationStatus()
        
        let mockUserNotificationCenter = UserNotificationCenterMock()
        
        struct Container: View {
            @StateObject var dataSourceList: DataSourceList = DataSourceList()
            
            var userNotificationCenter: UserNotificationCenter
            
            init(userNotificationCenter: UserNotificationCenter) {
                self.userNotificationCenter = userNotificationCenter
            }
            
            var body: some View {
                OnboardingView(userNotificationCenter: userNotificationCenter)
                    .environmentObject(dataSourceList)
            }
        }
        
        UNNotificationSettings.fakeAuthorizationStatus = .notDetermined
        
        let controller = UIHostingController(rootView: Container(userNotificationCenter: mockUserNotificationCenter)
            .environmentObject(locationManager))
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Set Sail")
        tester().tapView(withAccessibilityLabel: "Set Sail")
        tester().waitForView(withAccessibilityLabel: "Accept")
        tester().tapView(withAccessibilityLabel: "Accept")
        tester().waitForView(withAccessibilityLabel: "Yes, Enable Notifications")
        
    }
    
    func testFlowLocationAccessGrantedAndNotificationAccessGranted() throws {
        UserDefaults.standard.set(false, forKey: "disclaimerAccepted")
        UserDefaults.standard.set(false, forKey: "onboardingComplete")
        UserDefaults.standard.set(true, forKey: "showOnMap\(Asam.key)")
        UserDefaults.standard.set(true, forKey: "showOnMap\(Modu.key)")
        UserDefaults.standard.set(true, forKey: "showOnMap\(Light.key)")
        UserDefaults.standard.set(true, forKey: "showOnMap\(Port.key)")
        UserDefaults.standard.set(true, forKey: "showOnMap\(RadioBeacon.key)")
        UserDefaults.standard.set(true, forKey: "showOnMap\(DifferentialGPSStation.key)")
        
        let mockLocationManager = MockCLLocationManager()
        let locationManager = LocationManager.shared(locationManager: mockLocationManager)
        (locationManager.locationManager as? MockCLLocationManager)?.overriddenAuthStatus = .authorizedAlways
        locationManager.locationManager(mockLocationManager, didChangeAuthorization: .authorizedAlways)
        
        UNNotificationSettings.swizzleAuthorizationStatus()
        
        let mockUserNotificationCenter = UserNotificationCenterMock()
        
        struct Container: View {
            @StateObject var dataSourceList: DataSourceList = DataSourceList()
            
            var userNotificationCenter: UserNotificationCenter
            
            init(userNotificationCenter: UserNotificationCenter) {
                self.userNotificationCenter = userNotificationCenter
            }
            
            var body: some View {
                OnboardingView(userNotificationCenter: userNotificationCenter)
                    .environmentObject(dataSourceList)
            }
        }
        
        UNNotificationSettings.fakeAuthorizationStatus = .authorized
        
        let controller = UIHostingController(rootView: Container(userNotificationCenter: mockUserNotificationCenter)
            .environmentObject(locationManager))
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Set Sail")
        tester().tapView(withAccessibilityLabel: "Set Sail")
        tester().waitForView(withAccessibilityLabel: "Accept")
        tester().tapView(withAccessibilityLabel: "Accept")
        tester().waitForView(withAccessibilityLabel: "Marlin Tabs")
    }
}

extension UNNotificationSettings {
    static var fakeAuthorizationStatus: UNAuthorizationStatus = .authorized
    
    static func swizzleAuthorizationStatus() {
        let originalMethod = class_getInstanceMethod(self, #selector(getter: authorizationStatus))!
        let swizzledMethod = class_getInstanceMethod(self, #selector(getter: swizzledAuthorizationStatus))!
        
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
    
    @objc var swizzledAuthorizationStatus: UNAuthorizationStatus {
        return Self.fakeAuthorizationStatus
    }
}

class UserNotificationCenterMock: UserNotificationCenter {
    
    var pendingNotifications = [UNNotificationRequest]()
    var settingsCoder = MockNSCoder()
    public var requestAuthorizationCalled = false
    
    func getNotificationSettings(completionHandler: @escaping (UNNotificationSettings) -> Void) {
        print("getting notificaiton settings, the auth status is \(UNNotificationSettings.fakeAuthorizationStatus)")
        settingsCoder.authorizationStatus = UNNotificationSettings.fakeAuthorizationStatus.rawValue
        let settings = UNNotificationSettings(coder: settingsCoder)!
        completionHandler(settings)
    }
    
    func removeAllPendingNotificationRequests() {
        pendingNotifications.removeAll()
    }
    
    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?) {
        pendingNotifications.append(request)
        completionHandler?(nil)
    }
    
    func requestAuthorization(options: UNAuthorizationOptions = [], completionHandler: @escaping (Bool, Error?) -> Void) {
        requestAuthorizationCalled = true
        UNNotificationSettings.fakeAuthorizationStatus = .authorized
        completionHandler(true, nil)
    }
}

class MockNSCoder: NSCoder {
    var authorizationStatus = UNNotificationSettings.fakeAuthorizationStatus.rawValue
    
    override func decodeInt64(forKey key: String) -> Int64 {
        return Int64(authorizationStatus)
    }
    
    override func decodeBool(forKey key: String) -> Bool {
        return true
    }
}
