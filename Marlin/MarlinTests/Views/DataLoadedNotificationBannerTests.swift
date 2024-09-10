//
//  DataLoadedNotificationBannerTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/8/23.
//

import XCTest
import SwiftUI
import CoreLocation

@testable import Marlin

final class DataLoadedNotificationBannerTests: XCTestCase {
    
    override func setUp() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults()
    }
    
    func testShowNotification() {
        let appState = AppState()
        appState.dsBatchImportNotificationsPending = [
            DataSources.asam.key : [DataSourceUpdatedNotification(key: DataSources.asam.key, updates: 1, inserts: 3)]
        ]
        appState.loadingDataSource[MockDataSourceNonMappable.key] = false
        appState.consolidatedDataLoadedNotification = "3 new \(DataSources.asam.fullName)"
        appState.lastNotificationRequestDate = Date()
        let banner = DataLoadedNotificationBanner().environmentObject(appState)
        
        let controller = UIHostingController(rootView: banner)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "3 new \(DataSources.asam.fullName)")
    }
    
    func testExpandNotification() throws {
        try XCTSkipIf(TestHelpers.DISABLE_UI_TESTS, "UI tests are disabled")
        let appState = AppState()
        appState.dsBatchImportNotificationsPending = [
            DataSources.asam.key : [DataSourceUpdatedNotification(key: DataSources.asam.key, updates: 1, inserts: 3)],
            DataSources.modu.key : [DataSourceUpdatedNotification(key: DataSources.modu.key, updates: 1, inserts: 3)],
            DataSources.light.key : [DataSourceUpdatedNotification(key: DataSources.light.key, updates: 1, inserts: 3)],
            DataSources.port.key : [DataSourceUpdatedNotification(key: DataSources.port.key, updates: 1, inserts: 3)],
        ]
        appState.loadingDataSource[MockDataSourceNonMappable.key] = false
        appState.consolidatedDataLoadedNotification = "3 new \(DataSources.asam.fullName)\n3 new \(DataSources.modu.fullName)\n3 new \(DataSources.light.fullName)\n3 new \(DataSources.port.fullName)"
        appState.lastNotificationRequestDate = Date()
        let banner = DataLoadedNotificationBanner()
        let view = banner.environmentObject(appState)
        
        
        let controller = UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "New Data Loaded show more")
        tester().tapView(withAccessibilityLabel: "New Data Loaded show more")
        tester().waitForView(withAccessibilityLabel: "New Data Loaded")
        tester().tapView(withAccessibilityLabel: "New Data Loaded")
        tester().waitForView(withAccessibilityLabel: "New Data Loaded show more")
    }
    
    func testClearNotification() throws {
        try XCTSkipIf(TestHelpers.DISABLE_UI_TESTS, "UI tests are disabled")
        let appState = AppState()
        appState.dsBatchImportNotificationsPending = [
            DataSources.asam.key : [DataSourceUpdatedNotification(key: DataSources.asam.key, updates: 1, inserts: 3)]
        ]
        appState.loadingDataSource[MockDataSourceNonMappable.key] = false
        appState.consolidatedDataLoadedNotification = "3 new \(DataSources.asam.fullName)"
        appState.lastNotificationRequestDate = Date()
        let banner = DataLoadedNotificationBanner()
        let view = banner.environmentObject(appState)
        
        
        let controller = UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        XCTAssertFalse(appState.dsBatchImportNotificationsPending.isEmpty)
        tester().waitForView(withAccessibilityLabel: "3 new \(DataSources.asam.fullName)")
        tester().waitForView(withAccessibilityLabel: "Clear")
        let lastDate = appState.lastNotificationRequestDate
        appState.consolidatedDataLoadedNotification = ""
        tester().tapView(withAccessibilityLabel: "Clear")
        XCTAssertNotEqual(lastDate, appState.lastNotificationRequestDate)
        XCTAssertTrue(appState.dsBatchImportNotificationsPending.isEmpty)
        tester().waitForAbsenceOfView(withAccessibilityLabel: "3 new \(DataSources.asam.fullName)")
    }
    
    func testShowNotificationAddExtra() {
        let appState = AppState()
        appState.dsBatchImportNotificationsPending = [
            DataSources.asam.key : [DataSourceUpdatedNotification(key: DataSources.asam.key, updates: 1, inserts: 3)]
        ]
        appState.consolidatedDataLoadedNotification = "3 new \(DataSources.asam.fullName)"
        appState.lastNotificationRequestDate = Date()
        let banner = DataLoadedNotificationBanner().environmentObject(appState)
        
        let controller = UIHostingController(rootView: banner)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "3 new \(DataSources.asam.fullName)")

        appState.dsBatchImportNotificationsPending = [
            DataSources.asam.key : [DataSourceUpdatedNotification(key: DataSources.asam.key, updates: 1, inserts: 12)]
        ]
        appState.consolidatedDataLoadedNotification = "15 new \(DataSources.asam.fullName)"
        appState.lastNotificationRequestDate = Date()
        tester().waitForView(withAccessibilityLabel: "15 new \(DataSources.asam.fullName)")
    }
    
    func testOnlyShowDataSourcesWithInserts() {
        let appState = AppState()
        appState.dsBatchImportNotificationsPending = [
            DataSources.asam.key : [DataSourceUpdatedNotification(key: DataSources.asam.key, updates: 1, inserts: 3)],
            DataSources.modu.key : [DataSourceUpdatedNotification(key: DataSources.modu.key, updates: 2, inserts: 0)]
        ]
        appState.consolidatedDataLoadedNotification = "3 new \(DataSources.asam.fullName)"
        appState.lastNotificationRequestDate = Date()
        let banner = DataLoadedNotificationBanner().environmentObject(appState)
        
        let controller = UIHostingController(rootView: banner)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "3 new \(DataSources.asam.fullName)")
    }
    
    func testShowPreviousInsertsIfNewWithOnlyUpdatesComesIn() {
        let appState = AppState()
        appState.dsBatchImportNotificationsPending = [
            DataSources.asam.key : [DataSourceUpdatedNotification(key: DataSources.asam.key, updates: 1, inserts: 3)]
        ]
        appState.consolidatedDataLoadedNotification = "3 new \(DataSources.asam.fullName)"
        appState.lastNotificationRequestDate = Date()
        let banner = DataLoadedNotificationBanner().environmentObject(appState)
        
        let controller = UIHostingController(rootView: banner)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "3 new \(DataSources.asam.fullName)")

        appState.dsBatchImportNotificationsPending = [
            DataSources.asam.key : [DataSourceUpdatedNotification(key: DataSources.asam.key, updates: 1, inserts: 0)]
        ]
        appState.consolidatedDataLoadedNotification = "3 new \(DataSources.asam.fullName)"
        appState.lastNotificationRequestDate = Date()
        tester().waitForView(withAccessibilityLabel: "3 new \(DataSources.asam.fullName)")
    }
}
