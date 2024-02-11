//
//  DataSourceCellTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/11/23.
//

import XCTest
import SwiftUI

@testable import Marlin

final class DataSourceCellTests: XCTestCase {
    
    func testNonLoadingNonMappableDataSource() {
        XCTFail()
//        let item = DataSourceItem(dataSource: MockDataSourceNonMappable.self)
//        
//        expectation(forNotification: .SwitchTabs, object: nil) { notification in
//            let dataSourceKey = try? XCTUnwrap(notification.object as? String)
//            XCTAssertEqual(dataSourceKey, MockDataSourceNonMappable.key)
//            return true
//        }
//        let appState = AppState()
//        appState.loadingDataSource[MockDataSourceNonMappable.key] = false
//        let cell = DataSourceCell(dataSourceItem: item).environmentObject(appState)
//        
//        let controller = UIHostingController(rootView: cell)
//        let window = TestHelpers.getKeyWindowVisible()
//        window.rootViewController = controller
//        
//        tester().waitForView(withAccessibilityLabel: "\(MockDataSourceNonMappable.fullDataSourceName)")
//        tester().waitForView(withAccessibilityLabel: "\(MockDataSourceNonMappable.key) cell")
//        tester().tapView(withAccessibilityLabel: "\(MockDataSourceNonMappable.key) cell")
//        
//        waitForExpectations(timeout: 10)
    }
    
    func testNonLoadingMappableDataSource() {
        XCTFail()
//        UserDefaults.standard.setValue(true, forKey: "showOnMap\(MockDataSource.key)")
//        let item = DataSourceItem(dataSource: MockDataSource.self)
//        
//        expectation(forNotification: .SwitchTabs, object: nil) { notification in
//            let dataSourceKey = try? XCTUnwrap(notification.object as? String)
//            XCTAssertEqual(dataSourceKey, MockDataSource.key)
//            return true
//        }
//
//        let appState = AppState()
//        appState.loadingDataSource[MockDataSource.key] = false
//        let cell = DataSourceCell(dataSourceItem: item).environmentObject(appState)
//        
//        let controller = UIHostingController(rootView: cell)
//        let window = TestHelpers.getKeyWindowVisible()
//        window.rootViewController = controller
//        
//        tester().waitForView(withAccessibilityLabel: "\(MockDataSource.fullDataSourceName)")
//        tester().waitForView(withAccessibilityLabel: "\(MockDataSource.key) cell")
//        tester().tapView(withAccessibilityLabel: "\(MockDataSource.key) cell")
//        
//        waitForExpectations(timeout: 10)
    }
    
    func testLoadingDataSource() {
        XCTFail()
//        UserDefaults.standard.setValue(true, forKey: "showOnMap\(MockDataSource.key)")
//        let item = DataSourceItem(dataSource: MockDataSource.self)
//        
//        expectation(forNotification: .SwitchTabs, object: nil) { notification in
//            let dataSourceKey = try? XCTUnwrap(notification.object as? String)
//            XCTAssertEqual(dataSourceKey, MockDataSource.key)
//            return true
//        }
//
//        let appState = AppState()
//        appState.loadingDataSource[MockDataSource.key] = true
//        let cell = DataSourceCell(dataSourceItem: item).environmentObject(appState)
//        
//        let controller = UIHostingController(rootView: cell)
//        let window = TestHelpers.getKeyWindowVisible()
//        window.rootViewController = controller
//        
//        tester().waitForView(withAccessibilityLabel: "\(MockDataSource.fullDataSourceName)")
//        tester().waitForView(withAccessibilityLabel: "\(MockDataSource.key) cell")
//        tester().tapView(withAccessibilityLabel: "\(MockDataSource.key) cell")
//        
//        tester().waitForView(withAccessibilityLabel: "Loading \(MockDataSource.key)")
//        
//        waitForExpectations(timeout: 10)
    }
}
