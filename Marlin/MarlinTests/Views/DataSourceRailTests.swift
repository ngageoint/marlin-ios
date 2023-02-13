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
        class PassThrough {
            var currentItem: DataSourceItem?
        }
        
        struct Container: View {
            @State var activeRailItem: DataSourceItem?
            
            class MockDataSourceList : DataSourceList {
                override var allTabs: [DataSourceItem] {
                    return [
                        DataSourceItem(dataSource: MockDataSourceDefaultSort.self),
                        DataSourceItem(dataSource: MockDataSource.self),
                        DataSourceItem(dataSource: MockDataSourceNonMappable.self)
                    ]
                }
            }
            let dataSourceList = MockDataSourceList()
            let passThrough: PassThrough
            public init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                DataSourceRail(dataSourceList: dataSourceList, activeRailItem: $activeRailItem)
                    .onAppear {
                        print("setting active rail item \(dataSourceList.allTabs[0])")
                        activeRailItem = dataSourceList.allTabs[0]
                    }
                    .onChange(of: activeRailItem) { newValue in
                        self.passThrough.currentItem = newValue
                    }
            }
        }
        let pt = PassThrough()
        
        let rail = Container(passThrough: pt)
        let controller = UIHostingController(rootView: rail)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "\(MockDataSourceNonMappable.fullDataSourceName) rail item")
        tester().waitForView(withAccessibilityLabel: "\(MockDataSourceDefaultSort.fullDataSourceName) rail item")
        tester().waitForView(withAccessibilityLabel: "\(MockDataSource.fullDataSourceName) rail item")
        
        tester().tapView(withAccessibilityLabel: "\(MockDataSourceNonMappable.fullDataSourceName) rail item")
        XCTAssertEqual(pt.currentItem?.key, MockDataSourceNonMappable.key)
        tester().tapView(withAccessibilityLabel: "\(MockDataSourceDefaultSort.fullDataSourceName) rail item")
        XCTAssertEqual(pt.currentItem?.key, MockDataSourceDefaultSort.key)
        tester().tapView(withAccessibilityLabel: "\(MockDataSource.fullDataSourceName) rail item")
        XCTAssertEqual(pt.currentItem?.key, MockDataSource.key)
        
        tester().tapView(withAccessibilityLabel: "\(MockDataSource.fullDataSourceName) rail item")
        XCTAssertEqual(pt.currentItem, nil)
    }
}
