//
//  DataSourceRailTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/11/23.
//

import XCTest

import SwiftUI

@testable import Marlin

final class DataSourceRailTests: XCTestCase {
    
    func testRail() {
        struct Container: View {
            @State var activeRailItem: DataSourceItem? = nil
            let dataSourceList = DataSourceList()
            
            public init() {
                dataSourceList.tabs = [
                    DataSourceItem(dataSource: MockDataSourceDefaultSort.self),
                    DataSourceItem(dataSource: MockDataSource.self),
                    DataSourceItem(dataSource: MockDataSourceNonMappable.self)
                ]
                activeRailItem = dataSourceList.tabs[0]
            }
            
            var body: some View {
                DataSourceRail(dataSourceList: dataSourceList, activeRailItem: $activeRailItem)
            }
        }
        
        let rail = Container()
        let controller = UIHostingController(rootView: rail)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "\(MockDataSourceNonMappable.fullDataSourceName) rail item")
        tester().waitForView(withAccessibilityLabel: "\(MockDataSourceDefaultSort.fullDataSourceName) rail item")
        tester().waitForView(withAccessibilityLabel: "\(MockDataSource.fullDataSourceName) rail item")
        
        tester().tapView(withAccessibilityLabel: "\(MockDataSourceNonMappable.fullDataSourceName) rail item")
        XCTAssertEqual(rail.activeRailItem?.key, MockDataSourceNonMappable.key)
        tester().tapView(withAccessibilityLabel: "\(MockDataSourceDefaultSort.fullDataSourceName) rail item")
        XCTAssertEqual(rail.activeRailItem?.key, MockDataSourceDefaultSort.key)
        tester().tapView(withAccessibilityLabel: "\(MockDataSource.fullDataSourceName) rail item")
        XCTAssertEqual(rail.activeRailItem?.key, MockDataSource.key)
    }
}
