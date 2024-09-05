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
                        DataSourceItem(dataSource: MockDataSourceDefaultSortDefinition()),
                        DataSourceItem(dataSource: MockDataSourceDefinition()),
                        DataSourceItem(dataSource: MockDataSourceNonMappableDefinition())
                    ]
                }
            }
            @StateObject var dataSourceList: DataSourceList = MockDataSourceList()
            let passThrough: PassThrough
            public init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                DataSourceRail(activeRailItem: $activeRailItem)
                    .environmentObject(dataSourceList)
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
        
        tester().waitForView(withAccessibilityLabel: "\(MockDataSourceNonMappableDefinition().fullName) rail item")
        tester().waitForView(withAccessibilityLabel: "\(MockDataSourceDefaultSortDefinition().fullName) rail item")
        tester().waitForView(withAccessibilityLabel: "\(MockDataSourceDefinition().fullName) rail item")

        tester().tapView(withAccessibilityLabel: "\(MockDataSourceNonMappableDefinition().fullName) rail item")
        XCTAssertEqual(pt.currentItem?.key, MockDataSourceNonMappableDefinition().key)
        tester().tapView(withAccessibilityLabel: "\(MockDataSourceDefaultSortDefinition().fullName) rail item")
        XCTAssertEqual(pt.currentItem?.key, MockDataSourceDefaultSortDefinition().key)
        tester().tapView(withAccessibilityLabel: "\(MockDataSourceDefinition().fullName) rail item")
        XCTAssertEqual(pt.currentItem?.key, MockDataSourceDefinition().key)

        tester().tapView(withAccessibilityLabel: "\(MockDataSourceDefinition().fullName) rail item")
        XCTAssertEqual(pt.currentItem, nil)
    }
}
