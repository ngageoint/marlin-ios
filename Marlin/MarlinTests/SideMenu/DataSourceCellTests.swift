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
    
    func testNonLoadingNonMappableDataSource() throws {
        try XCTSkipIf(TestHelpers.DISABLE_UI_TESTS, "UI tests are disabled")
        let definition = MockDataSourceNonMappableDefinition()

        let item = DataSourceItem(dataSource: definition)

        expectation(forNotification: .SwitchTabs, object: nil) { notification in
            let dataSourceKey = try? XCTUnwrap(notification.object as? String)
            XCTAssertEqual(dataSourceKey, definition.key)
            return true
        }
        let appState = AppState()
        appState.loadingDataSource[definition.key] = false
        let cell = DataSourceCell(dataSourceItem: item).environmentObject(appState)
        
        let controller = UIHostingController(rootView: cell)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "\(definition.fullName)")
        tester().waitForView(withAccessibilityLabel: "\(definition.key) cell")
        tester().tapView(withAccessibilityLabel: "\(definition.key) cell")

        waitForExpectations(timeout: 10)
    }
    
    func testNonLoadingMappableDataSource() throws {
        try XCTSkipIf(TestHelpers.DISABLE_UI_TESTS, "UI tests are disabled")
        let definition = MockDataSourceDefinition()

        UserDefaults.standard.setValue(true, forKey: "showOnMap\(definition.key)")
        let item = DataSourceItem(dataSource: definition)

        expectation(forNotification: .SwitchTabs, object: nil) { notification in
            let dataSourceKey = try? XCTUnwrap(notification.object as? String)
            XCTAssertEqual(dataSourceKey, definition.key)
            return true
        }

        let appState = AppState()
        appState.loadingDataSource[MockDataSource.key] = false
        let cell = DataSourceCell(dataSourceItem: item).environmentObject(appState)
        
        let controller = UIHostingController(rootView: cell)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "\(definition.fullName)")
        tester().waitForView(withAccessibilityLabel: "\(definition.key) cell")
        tester().tapView(withAccessibilityLabel: "\(definition.key) cell")

        waitForExpectations(timeout: 10)
    }
    
    func testLoadingDataSource() throws {
        try XCTSkipIf(TestHelpers.DISABLE_UI_TESTS, "UI tests are disabled")
        let definition = MockDataSourceDefinition()
        UserDefaults.standard.setValue(true, forKey: "showOnMap\(definition.key)")
        let item = DataSourceItem(dataSource: MockDataSourceDefinition())

        expectation(forNotification: .SwitchTabs, object: nil) { notification in
            let dataSourceKey = try? XCTUnwrap(notification.object as? String)
            XCTAssertEqual(dataSourceKey, definition.key)
            return true
        }

        let appState = AppState()
        appState.loadingDataSource[definition.key] = true
        let cell = DataSourceCell(dataSourceItem: item).environmentObject(appState)
        
        let controller = UIHostingController(rootView: cell)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "\(definition.fullName)")
        tester().waitForView(withAccessibilityLabel: "\(definition.key) cell")
        tester().tapView(withAccessibilityLabel: "\(definition.key) cell")

        tester().waitForView(withAccessibilityLabel: "Loading \(definition.key)")

        waitForExpectations(timeout: 10)
    }
}
