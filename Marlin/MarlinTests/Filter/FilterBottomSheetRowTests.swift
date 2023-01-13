//
//  FilterBottomSheetRowTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/13/23.
//

import XCTest
import Combine
import SwiftUI

@testable import Marlin

final class FilterBottomSheetRowTests: XCTestCase {
    
    func testFilterBottomSheetRowNoFilters() {
        UserDefaults.standard.setFilter(MockDataSource.key, filter: [])
        
        struct Container: View {
            @State var dataSourceItem = DataSourceItem(dataSource: MockDataSource.self)
            
            var body: some View {
                FilterBottomSheetRow(dataSourceItem: $dataSourceItem)
            }
        }
        
        let view = Container()
        
        let controller = UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "0 \(MockDataSource.fullDataSourceName) filters")
        tester().waitForView(withAccessibilityLabel: "expand \(MockDataSource.fullDataSourceName) filters")
        tester().tapView(withAccessibilityLabel: "expand \(MockDataSource.fullDataSourceName) filters")
        
        tester().waitForView(withAccessibilityLabel: "\(MockDataSource.fullDataSourceName) filters")
        
        tester().wait(forTimeInterval: 5)
    }
    
    func testFilterBottomSheetRowWithFilters() {
        UserDefaults.standard.setFilter(MockDataSource.key, filter: [DataSourceFilterParameter(property: DataSourceProperty(name: "Date", key: #keyPath(MockDataSource.dateProperty), type: .date), comparison: .window, windowUnits: DataSourceWindowUnits.last365Days)])
        
        struct Container: View {
            @State var dataSourceItem = DataSourceItem(dataSource: MockDataSource.self)
            
            var body: some View {
                FilterBottomSheetRow(dataSourceItem: $dataSourceItem)
            }
        }
        
        let view = Container()
        
        let controller = UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().wait(forTimeInterval: 2)
        TestHelpers.printAllAccessibilityLabelsInWindows()
        tester().waitForView(withAccessibilityLabel: "1 \(MockDataSource.fullDataSourceName) filters")
        
        tester().waitForView(withAccessibilityLabel: "expand \(MockDataSource.fullDataSourceName) filters")
        tester().tapView(withAccessibilityLabel: "expand \(MockDataSource.fullDataSourceName) filters")
        
        tester().waitForView(withAccessibilityLabel: "\(MockDataSource.fullDataSourceName) filters")
        
        tester().wait(forTimeInterval: 5)
    }
}
