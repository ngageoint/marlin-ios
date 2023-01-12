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
            let dataSourceList = DataSourceList()
            let passThrough: PassThrough
            public init(passThrough: PassThrough) {
                dataSourceList.tabs = [
                    DataSourceItem(dataSource: MockDataSourceDefaultSort.self),
                    DataSourceItem(dataSource: MockDataSource.self),
                    DataSourceItem(dataSource: MockDataSourceNonMappable.self)
                ]
                self.passThrough = passThrough
            }
            
            var body: some View {
                DataSourceRail(dataSourceList: dataSourceList, activeRailItem: $activeRailItem)
                    .onAppear {
                        print("setting active rail item \(dataSourceList.tabs[0])")
                        activeRailItem = dataSourceList.tabs[0]
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
