//
//  SideMenuContentTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/2/23.
//

import XCTest
import SwiftUI

@testable import Marlin

final class SideMenuContentTests: XCTestCase {
    
    override func setUp() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults()
    }
    
    func testSideMenuDataSources() {
        class PassThrough {
            var dataSourceList: DataSourceList?
        }
        
        struct Container: View {
            @State var activeRailItem: DataSourceItem?
            @StateObject var dataSourceList: DataSourceList = DataSourceList()
            let appState = AppState()
            
            let passThrough: PassThrough
            public init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                SideMenuContent(model: SideMenuViewModel(dataSourceList: dataSourceList))
                    .environmentObject(appState)
                    .onAppear {
                        self.passThrough.dataSourceList = self.dataSourceList
                    }
                    .onChange(of: dataSourceList.tabs.count) { newValue in
                        self.passThrough.dataSourceList = dataSourceList
                    }
            }
        }
        let pt = PassThrough()
        
        let rail = Container(passThrough: pt)
        let controller = UIHostingController(rootView: rail)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "Data Source Tabs (Drag to reorder)")
        
        XCTAssertEqual(pt.dataSourceList?.tabs.count, UserDefaults.standard.integer(forKey: "userTabs"))
        if let tabs = pt.dataSourceList?.tabs {
            for tab in tabs {
                tester().waitForView(withAccessibilityLabel: "\(tab.dataSource.fullDataSourceName) tab cell")
            }
        }
        if let nontabs = pt.dataSourceList?.nonTabs {
            for tab in nontabs {
                tester().waitForView(withAccessibilityLabel: "\(tab.dataSource.fullDataSourceName) nontab cell")
            }
        }
    }
    
    func testSubmitReport() {
        class PassThrough {
            var dataSourceList: DataSourceList?
        }
        
        struct Container: View {
            @State var activeRailItem: DataSourceItem?
            @StateObject var dataSourceList: DataSourceList = DataSourceList()
            let appState = AppState()
            
            let passThrough: PassThrough
            public init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                SideMenuContent(model: SideMenuViewModel(dataSourceList: dataSourceList))
                    .environmentObject(appState)
            }
        }
        let pt = PassThrough()
        
        let rail = Container(passThrough: pt)
        let controller = UIHostingController(rootView: rail)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "Submit Report to NGA")
        
        expectation(forNotification: .SwitchTabs, object: nil) { notification in
            XCTAssertEqual(notification.object as? String, "submitReport")
            return true
        }
        
        tester().tapView(withAccessibilityLabel: "Submit Report to NGA")
        waitForExpectations(timeout: 10)
    }
    
    func testAbout() {
        class PassThrough {
            var dataSourceList: DataSourceList?
        }
        
        struct Container: View {
            @State var activeRailItem: DataSourceItem?
            @StateObject var dataSourceList: DataSourceList = DataSourceList()
            let appState = AppState()
            
            let passThrough: PassThrough
            public init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                SideMenuContent(model: SideMenuViewModel(dataSourceList: dataSourceList))
                    .environmentObject(appState)
            }
        }
        let pt = PassThrough()
        
        let rail = Container(passThrough: pt)
        let controller = UIHostingController(rootView: rail)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "About")
    }
    
    func testSideMenuDataSourcesDragWithoutReallyDragging() {
        class PassThrough {
            var model: SideMenuViewModel?
        }
        
        struct Container: View {
            @State var activeRailItem: DataSourceItem?
            @StateObject var model: SideMenuViewModel = SideMenuViewModel(dataSourceList: DataSourceList())
            let appState = AppState()
            
            let passThrough: PassThrough
            public init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                SideMenuContent(model: model)
                    .environmentObject(appState)
                    .onAppear {
                        self.passThrough.model = self.model
                    }
                    .onChange(of: model.dataSourceList.tabs.count) { newValue in
                        self.passThrough.model = model
                    }
            }
        }
        let pt = PassThrough()
        
        let rail = Container(passThrough: pt)
        let controller = UIHostingController(rootView: rail)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "Data Source Tabs (Drag to reorder)")
        
        XCTAssertEqual(pt.model?.dataSourceList.tabs.count, UserDefaults.standard.integer(forKey: "userTabs"))
        if let tabs = pt.model?.dataSourceList.tabs {
            for tab in tabs {
                tester().waitForView(withAccessibilityLabel: "\(tab.dataSource.fullDataSourceName) tab cell")
            }
        }
        if let nontabs = pt.model?.dataSourceList.nonTabs {
            for tab in nontabs {
                tester().waitForView(withAccessibilityLabel: "\(tab.dataSource.fullDataSourceName) nontab cell")
            }
        }
        var tabCount = pt.model!.dataSourceList.tabs.count
        var nonTabCount = pt.model!.dataSourceList.nonTabs.count
        XCTAssertEqual(3, tabCount)
        var itemDroppedOn = pt.model!.dataSourceList.tabs.first!
        var itemDragged = pt.model!.dataSourceList.tabs.last!
        
        _ = pt.model!.onDrag(dataSource: itemDragged)
        pt.model!.dropEntered(item: itemDroppedOn)
        _ = pt.model!.performDrop()
        tester().wait(forTimeInterval: 0.25)
        
        XCTAssertEqual(pt.model!.dataSourceList.tabs.first, itemDragged)
        XCTAssertEqual(pt.model!.dataSourceList.tabs.item(after: pt.model!.dataSourceList.tabs.first!), itemDroppedOn)
        XCTAssertEqual(3, pt.model!.dataSourceList.tabs.count)
        XCTAssertEqual(nonTabCount, pt.model!.dataSourceList.nonTabs.count)
        
        tabCount = pt.model!.dataSourceList.tabs.count
        nonTabCount = pt.model!.dataSourceList.nonTabs.count
        itemDragged = pt.model!.dataSourceList.nonTabs.first!
        itemDroppedOn = pt.model!.dataSourceList.tabs.first!
        
        _ = pt.model!.onDrag(dataSource: itemDragged)
        pt.model!.dropEntered(item: itemDroppedOn)
        _ = pt.model!.performDrop()
        tester().wait(forTimeInterval: 0.25)
        
        XCTAssertEqual(pt.model!.dataSourceList.tabs.first, itemDragged)
        XCTAssertEqual(pt.model!.dataSourceList.tabs.item(after: pt.model!.dataSourceList.tabs.first!), itemDroppedOn)
        XCTAssertEqual(4, pt.model!.dataSourceList.tabs.count)
        XCTAssertEqual(nonTabCount - 1, pt.model!.dataSourceList.nonTabs.count)
        
        // should be at max tabs now (4) so moving a non tab should kick out the last tab
        tabCount = pt.model!.dataSourceList.tabs.count
        nonTabCount = pt.model!.dataSourceList.nonTabs.count
        itemDragged = pt.model!.dataSourceList.nonTabs.first!
        itemDroppedOn = pt.model!.dataSourceList.tabs.first!
        var lastTab = pt.model!.dataSourceList.tabs.last!
        
        _ = pt.model!.onDrag(dataSource: itemDragged)
        pt.model!.dropEntered(item: itemDroppedOn)
        _ = pt.model!.performDrop()
        tester().wait(forTimeInterval: 0.25)
        
        XCTAssertEqual(pt.model!.dataSourceList.tabs.first, itemDragged)
        XCTAssertEqual(pt.model!.dataSourceList.tabs.item(after: pt.model!.dataSourceList.tabs.first!), itemDroppedOn)
        XCTAssertEqual(4, pt.model!.dataSourceList.tabs.count)
        XCTAssertEqual(nonTabCount, pt.model!.dataSourceList.nonTabs.count)
        XCTAssertEqual(pt.model!.dataSourceList.nonTabs.first, lastTab)
        XCTAssertNotEqual(pt.model!.dataSourceList.tabs.last, lastTab)
        
        tabCount = pt.model!.dataSourceList.tabs.count
        nonTabCount = pt.model!.dataSourceList.nonTabs.count
        itemDragged = pt.model!.dataSourceList.tabs.first!
        itemDroppedOn = pt.model!.dataSourceList.nonTabs.first!
        lastTab = pt.model!.dataSourceList.tabs.last!
        
        // now drag a non tab into the tab list, don't drop it, and then put it back in the non tab list
        tabCount = pt.model!.dataSourceList.tabs.count
        nonTabCount = pt.model!.dataSourceList.nonTabs.count
        itemDragged = pt.model!.dataSourceList.nonTabs.last!
        itemDroppedOn = pt.model!.dataSourceList.tabs.first!
        lastTab = pt.model!.dataSourceList.tabs.last!
        
        print("tab list")
        for tab in pt.model!.dataSourceList.tabs {
            print("tab name \(tab.key)")
        }
        print("nontab list")
        for tab in pt.model!.dataSourceList.nonTabs {
            print("nontab name \(tab.key)")
        }
        
        _ = pt.model!.onDrag(dataSource: itemDragged)
        pt.model!.dropEntered(item: itemDroppedOn)
        
        print("after drop entered tab list")
        for tab in pt.model!.dataSourceList.tabs {
            print("tab name \(tab.key)")
        }
        print("after drop entered nontab list")
        for tab in pt.model!.dataSourceList.nonTabs {
            print("nontab name \(tab.key)")
        }
        XCTAssertEqual(pt.model!.dataSourceList.tabs.first, itemDragged)
        XCTAssertEqual(pt.model!.dataSourceList.tabs.item(after: pt.model!.dataSourceList.tabs.first!), itemDroppedOn)
        XCTAssertEqual(4, pt.model!.dataSourceList.tabs.count)
        XCTAssertEqual(nonTabCount, pt.model!.dataSourceList.nonTabs.count)
        XCTAssertEqual(pt.model!.dataSourceList.nonTabs.first, lastTab)
        XCTAssertNotEqual(pt.model!.dataSourceList.tabs.last, lastTab)
        var firstNonTab = pt.model!.dataSourceList.nonTabs.first!
        pt.model!.dropEntered(item: firstNonTab)
        _ = pt.model!.performDrop()
        tester().wait(forTimeInterval: 0.25)
        
        print("after drop tab list")
        for tab in pt.model!.dataSourceList.tabs {
            print("tab name \(tab.key)")
        }
        print("after drop nontab list")
        for tab in pt.model!.dataSourceList.nonTabs {
            print("nontab name \(tab.key)")
        }
        
        XCTAssertEqual(pt.model!.dataSourceList.nonTabs.first, itemDragged)
        XCTAssertEqual(4, pt.model!.dataSourceList.tabs.count)
        XCTAssertEqual(nonTabCount, pt.model!.dataSourceList.nonTabs.count)
        XCTAssertNotEqual(pt.model!.dataSourceList.nonTabs.first!.key, firstNonTab.key)
        XCTAssertEqual(firstNonTab.key, pt.model!.dataSourceList.tabs.last!.key)
        tester().wait(forTimeInterval: 0.25)
        
        // drag all the tabs to the non tabs
        tabCount = pt.model!.dataSourceList.tabs.count
        nonTabCount = pt.model!.dataSourceList.nonTabs.count
        itemDragged = pt.model!.dataSourceList.tabs.first!
        itemDroppedOn = pt.model!.dataSourceList.nonTabs.first!
        lastTab = pt.model!.dataSourceList.tabs.last!
        
        _ = pt.model!.onDrag(dataSource: itemDragged)
        pt.model!.dropEntered(item: itemDroppedOn)
        _ = pt.model!.performDrop()
        tester().wait(forTimeInterval: 0.25)
        
        XCTAssertEqual(pt.model!.dataSourceList.nonTabs.first, itemDragged)
        XCTAssertEqual(pt.model!.dataSourceList.nonTabs.item(after: pt.model!.dataSourceList.nonTabs.first!), itemDroppedOn)
        XCTAssertEqual(3, pt.model!.dataSourceList.tabs.count)
        XCTAssertEqual(nonTabCount + 1, pt.model!.dataSourceList.nonTabs.count)
        XCTAssertEqual(pt.model!.dataSourceList.nonTabs.first, itemDragged)
        XCTAssertEqual(pt.model!.dataSourceList.tabs.last, lastTab)
        
        tabCount = pt.model!.dataSourceList.tabs.count
        nonTabCount = pt.model!.dataSourceList.nonTabs.count
        itemDragged = pt.model!.dataSourceList.tabs.first!
        itemDroppedOn = pt.model!.dataSourceList.nonTabs.first!
        lastTab = pt.model!.dataSourceList.tabs.last!
        
        _ = pt.model!.onDrag(dataSource: itemDragged)
        pt.model!.dropEntered(item: itemDroppedOn)
        _ = pt.model!.performDrop()
        tester().wait(forTimeInterval: 0.25)
        
        XCTAssertEqual(pt.model!.dataSourceList.nonTabs.first, itemDragged)
        XCTAssertEqual(pt.model!.dataSourceList.nonTabs.item(after: pt.model!.dataSourceList.nonTabs.first!), itemDroppedOn)
        XCTAssertEqual(2, pt.model!.dataSourceList.tabs.count)
        XCTAssertEqual(nonTabCount + 1, pt.model!.dataSourceList.nonTabs.count)
        XCTAssertEqual(pt.model!.dataSourceList.nonTabs.first, itemDragged)
        XCTAssertEqual(pt.model!.dataSourceList.tabs.last, lastTab)
        
        tabCount = pt.model!.dataSourceList.tabs.count
        nonTabCount = pt.model!.dataSourceList.nonTabs.count
        itemDragged = pt.model!.dataSourceList.tabs.first!
        itemDroppedOn = pt.model!.dataSourceList.nonTabs.first!
        lastTab = pt.model!.dataSourceList.tabs.last!
        
        _ = pt.model!.onDrag(dataSource: itemDragged)
        pt.model!.dropEntered(item: itemDroppedOn)
        _ = pt.model!.performDrop()
        tester().wait(forTimeInterval: 0.25)
        
        XCTAssertEqual(pt.model!.dataSourceList.nonTabs.first, itemDragged)
        XCTAssertEqual(pt.model!.dataSourceList.nonTabs.item(after: pt.model!.dataSourceList.nonTabs.first!), itemDroppedOn)
        XCTAssertEqual(1, pt.model!.dataSourceList.tabs.count)
        XCTAssertEqual(nonTabCount + 1, pt.model!.dataSourceList.nonTabs.count)
        XCTAssertEqual(pt.model!.dataSourceList.nonTabs.first, itemDragged)
        XCTAssertEqual(pt.model!.dataSourceList.tabs.last, lastTab)
        
        tabCount = pt.model!.dataSourceList.tabs.count
        nonTabCount = pt.model!.dataSourceList.nonTabs.count
        itemDragged = pt.model!.dataSourceList.tabs.first!
        itemDroppedOn = pt.model!.dataSourceList.nonTabs.first!
        lastTab = pt.model!.dataSourceList.tabs.last!
        
        _ = pt.model!.onDrag(dataSource: itemDragged)
        pt.model!.dropEntered(item: itemDroppedOn)
        _ = pt.model!.performDrop()
        tester().wait(forTimeInterval: 0.25)
        
        XCTAssertEqual(pt.model!.dataSourceList.nonTabs.first, itemDragged)
        XCTAssertEqual(pt.model!.dataSourceList.nonTabs.item(after: pt.model!.dataSourceList.nonTabs.first!), itemDroppedOn)
        XCTAssertEqual(0, pt.model!.dataSourceList.tabs.count)
        XCTAssertEqual(nonTabCount + 1, pt.model!.dataSourceList.nonTabs.count)
        XCTAssertEqual(pt.model!.dataSourceList.nonTabs.first, itemDragged)
        
        tabCount = pt.model!.dataSourceList.tabs.count
        nonTabCount = pt.model!.dataSourceList.nonTabs.count
        itemDragged = pt.model!.dataSourceList.nonTabs.last!
        itemDroppedOn = pt.model!.dataSourceList.nonTabs.first!
        
        _ = pt.model!.onDrag(dataSource: itemDragged)
        pt.model!.dropEntered(item: itemDroppedOn)
        _ = pt.model!.performDrop()
        tester().wait(forTimeInterval: 0.25)
        
        XCTAssertEqual(pt.model!.dataSourceList.nonTabs.first, itemDragged)
        XCTAssertEqual(pt.model!.dataSourceList.nonTabs.item(after: pt.model!.dataSourceList.nonTabs.first!), itemDroppedOn)
        XCTAssertEqual(0, pt.model!.dataSourceList.tabs.count)
        XCTAssertEqual(nonTabCount, pt.model!.dataSourceList.nonTabs.count)
        
        tabCount = pt.model!.dataSourceList.tabs.count
        nonTabCount = pt.model!.dataSourceList.nonTabs.count
        itemDragged = pt.model!.dataSourceList.nonTabs.first!
//        itemDroppedOn = pt.model!.dataSourceList.nonTabs.first!
//        lastTab = pt.model!.dataSourceList.tabs.last!
        
        let itemProvider = pt.model!.onDrag(dataSource: itemDragged)
        _ = pt.model!.dropOnEmptyTabFirst(items: [itemProvider])
        tester().wait(forTimeInterval: 0.25)
        
        XCTAssertEqual(pt.model!.dataSourceList.tabs.first, itemDragged)
        XCTAssertNotEqual(pt.model!.dataSourceList.nonTabs.first, itemDragged)
        XCTAssertEqual(1, pt.model!.dataSourceList.tabs.count)
        XCTAssertEqual(nonTabCount - 1, pt.model!.dataSourceList.nonTabs.count)
        
        tester().wait(forTimeInterval: 5)
    }
}
