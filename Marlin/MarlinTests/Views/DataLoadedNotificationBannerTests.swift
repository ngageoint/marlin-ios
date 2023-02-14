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
        UserDefaults.registerMarlinDefaults(withMetrics: false)
    }
    
    func testShowNotification() {
        let appState = AppState()
        appState.dataSourceBatchImportNotificationsPending = [
            Asam.key : [DataSourceUpdatedNotification(key: Asam.key, updates: 1, inserts: 3)]
        ]
        appState.loadingDataSource[MockDataSourceNonMappable.key] = false
        appState.consolidatedDataLoadedNotification = "3 new \(Asam.fullDataSourceName)"
        appState.lastNotificationRequestDate = Date()
        let banner = DataLoadedNotificationBanner().environmentObject(appState)
        
        let controller = UIHostingController(rootView: banner)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "3 new \(Asam.fullDataSourceName)")
    }
    
    func testExpandNotification() {
        let appState = AppState()
        appState.dataSourceBatchImportNotificationsPending = [
            Asam.key : [DataSourceUpdatedNotification(key: Asam.key, updates: 1, inserts: 3)],
            Modu.key : [DataSourceUpdatedNotification(key: Modu.key, updates: 1, inserts: 3)],
            Light.key : [DataSourceUpdatedNotification(key: Light.key, updates: 1, inserts: 3)],
            Port.key : [DataSourceUpdatedNotification(key: Port.key, updates: 1, inserts: 3)],
        ]
        appState.loadingDataSource[MockDataSourceNonMappable.key] = false
        appState.consolidatedDataLoadedNotification = "3 new \(Asam.fullDataSourceName)\n3 new \(Modu.fullDataSourceName)\n3 new \(Light.fullDataSourceName)\n3 new \(Port.fullDataSourceName)"
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
    
    func testClearNotification() {
        let appState = AppState()
        appState.dataSourceBatchImportNotificationsPending = [
            Asam.key : [DataSourceUpdatedNotification(key: Asam.key, updates: 1, inserts: 3)]
        ]
        appState.loadingDataSource[MockDataSourceNonMappable.key] = false
        appState.consolidatedDataLoadedNotification = "3 new \(Asam.fullDataSourceName)"
        appState.lastNotificationRequestDate = Date()
        let banner = DataLoadedNotificationBanner()
        let view = banner.environmentObject(appState)
        
        
        let controller = UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        XCTAssertFalse(appState.dataSourceBatchImportNotificationsPending.isEmpty)
        tester().waitForView(withAccessibilityLabel: "3 new \(Asam.fullDataSourceName)")
        tester().waitForView(withAccessibilityLabel: "Clear")
        let lastDate = appState.lastNotificationRequestDate
        appState.consolidatedDataLoadedNotification = ""
        tester().tapView(withAccessibilityLabel: "Clear")
        XCTAssertNotEqual(lastDate, appState.lastNotificationRequestDate)
        XCTAssertTrue(appState.dataSourceBatchImportNotificationsPending.isEmpty)
        tester().waitForAbsenceOfView(withAccessibilityLabel: "3 new \(Asam.fullDataSourceName)")
    }
    
    func testShowNotificationAddExtra() {
        let appState = AppState()
        appState.dataSourceBatchImportNotificationsPending = [
            Asam.key : [DataSourceUpdatedNotification(key: Asam.key, updates: 1, inserts: 3)]
        ]
        appState.consolidatedDataLoadedNotification = "3 new \(Asam.fullDataSourceName)"
        appState.lastNotificationRequestDate = Date()
        let banner = DataLoadedNotificationBanner().environmentObject(appState)
        
        let controller = UIHostingController(rootView: banner)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "3 new \(Asam.fullDataSourceName)")
        
        appState.dataSourceBatchImportNotificationsPending = [
            Asam.key : [DataSourceUpdatedNotification(key: Asam.key, updates: 1, inserts: 12)]
        ]
        appState.consolidatedDataLoadedNotification = "15 new \(Asam.fullDataSourceName)"
        appState.lastNotificationRequestDate = Date()
        tester().waitForView(withAccessibilityLabel: "15 new \(Asam.fullDataSourceName)")
    }
    
    func testOnlyShowDataSourcesWithInserts() {
        let appState = AppState()
        appState.dataSourceBatchImportNotificationsPending = [
            Asam.key : [DataSourceUpdatedNotification(key: Asam.key, updates: 1, inserts: 3)],
            Modu.key : [DataSourceUpdatedNotification(key: Modu.key, updates: 2, inserts: 0)]
        ]
        appState.consolidatedDataLoadedNotification = "3 new \(Asam.fullDataSourceName)"
        appState.lastNotificationRequestDate = Date()
        let banner = DataLoadedNotificationBanner().environmentObject(appState)
        
        let controller = UIHostingController(rootView: banner)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "3 new \(Asam.fullDataSourceName)")
    }
    
    func testShowPreviousInsertsIfNewWithOnlyUpdatesComesIn() {
        let appState = AppState()
        appState.dataSourceBatchImportNotificationsPending = [
            Asam.key : [DataSourceUpdatedNotification(key: Asam.key, updates: 1, inserts: 3)]
        ]
        appState.consolidatedDataLoadedNotification = "3 new \(Asam.fullDataSourceName)"
        appState.lastNotificationRequestDate = Date()
        let banner = DataLoadedNotificationBanner().environmentObject(appState)
        
        let controller = UIHostingController(rootView: banner)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "3 new \(Asam.fullDataSourceName)")
        
        appState.dataSourceBatchImportNotificationsPending = [
            Asam.key : [DataSourceUpdatedNotification(key: Asam.key, updates: 1, inserts: 0)]
        ]
        appState.consolidatedDataLoadedNotification = "3 new \(Asam.fullDataSourceName)"
        appState.lastNotificationRequestDate = Date()
        tester().waitForView(withAccessibilityLabel: "3 new \(Asam.fullDataSourceName)")
    }
}
