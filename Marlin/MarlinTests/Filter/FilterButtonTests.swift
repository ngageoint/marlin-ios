//
//  FilterButtonTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/13/23.
//

import XCTest
import Combine
import SwiftUI

@testable import Marlin

final class FilterButtonTests: XCTestCase {
    
    func testFilterButton() {
        UserDefaults.standard.setFilter(MockDataSource.key, filter: [])
        
        class PassThrough {
            var filterOpen: Bool = false
            var sortOpen: Bool = false
        }
        
        struct Container: View {
            @State var filterOpen = false
            @State var sortOpen = false
            let passThrough: PassThrough
            
            var body: some View {
                Rectangle()
                    .background(Color.ngaGreen)
                    .modifier(FilterButton(filterOpen: $filterOpen, sortOpen: $sortOpen, allowSorting: false))
                    .onChange(of: filterOpen) { newValue in
                        self.passThrough.filterOpen = newValue
                    }
                    .onChange(of: sortOpen) { newValue in
                        self.passThrough.sortOpen = newValue
                    }
            }
            
            public init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
        }
        
        let passThrough = PassThrough()
        let view = Container(passThrough: passThrough)
        
        let nav = NavigationView {
            view
        }
        
        let controller = UIHostingController(rootView: nav)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "Filter")
        tester().tapView(withAccessibilityLabel: "Filter")
        XCTAssertTrue(passThrough.filterOpen)
        tester().tapView(withAccessibilityLabel: "Filter")
        XCTAssertFalse(passThrough.filterOpen)
        
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Sort")
    }
    
    func testSortButton() {
        UserDefaults.standard.setFilter(MockDataSource.key, filter: [])
        
        class PassThrough {
            var filterOpen: Bool = false
            var sortOpen: Bool = false
        }
        
        struct Container: View {
            @State var filterOpen = false
            @State var sortOpen = false
            let passThrough: PassThrough
            
            var body: some View {
                Rectangle()
                    .background(Color.ngaGreen)
                    .modifier(FilterButton(filterOpen: $filterOpen, sortOpen: $sortOpen, allowFiltering: false))
                    .onChange(of: filterOpen) { newValue in
                        self.passThrough.filterOpen = newValue
                    }
                    .onChange(of: sortOpen) { newValue in
                        self.passThrough.sortOpen = newValue
                    }
            }
            
            public init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
        }
        
        let passThrough = PassThrough()
        let view = Container(passThrough: passThrough)
        
        let nav = NavigationView {
            view
        }
        
        let controller = UIHostingController(rootView: nav)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "Sort")
        tester().tapView(withAccessibilityLabel: "Sort")
        XCTAssertTrue(passThrough.sortOpen)
        tester().tapView(withAccessibilityLabel: "Sort")
        XCTAssertFalse(passThrough.sortOpen)
        
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Filter")
    }
    
    func testFilterAndSortButton() {
        UserDefaults.standard.setFilter(MockDataSource.key, filter: [])
        
        class PassThrough {
            var filterOpen: Bool = false
            var sortOpen: Bool = false
        }
        
        struct Container: View {
            @State var filterOpen = false
            @State var sortOpen = false
            let passThrough: PassThrough
            
            var body: some View {
                Rectangle()
                    .background(Color.ngaGreen)
                    .modifier(FilterButton(filterOpen: $filterOpen, sortOpen: $sortOpen, allowSorting: true, allowFiltering: true))
            }
            
            public init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
        }
        
        let passThrough = PassThrough()
        let view = Container(passThrough: passThrough)
        
        let nav = NavigationView {
            view
        }
        
        let controller = UIHostingController(rootView: nav)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        // can't test tapping these b/c KIF fails to find the proper location of the view with two buttons
        tester().waitForView(withAccessibilityLabel: "Sort")
        tester().waitForView(withAccessibilityLabel: "Filter")
    }
    
    func testFilterCount() {
        UserDefaults.standard.setFilter(MockDataSourceDefinition().key,
                                        filter: [
                                            DataSourceFilterParameter(
                                                property: DataSourceProperty(
                                                    name: "Date",
                                                    key: #keyPath(MockDataSource.dateProperty), type: .date),
                                                comparison: .window,
                                                windowUnits: DataSourceWindowUnits.last365Days)
                                        ]
        )
        
        class PassThrough {
            var filterOpen: Bool = false
            var sortOpen: Bool = false
        }
        
        struct Container: View {
            @State var filterOpen = false
            @State var sortOpen = false
            @State var dataSources: [DataSourceItem] = [DataSourceItem(dataSource: MockDataSourceDefinition())]
            let passThrough: PassThrough
            
            var body: some View {
                Rectangle()
                    .background(Color.ngaGreen)
                    .modifier(FilterButton(filterOpen: $filterOpen, dataSources: $dataSources, allowSorting: false, allowFiltering: true))
            }
            
            public init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
        }
        
        let passThrough = PassThrough()
        let view = Container(passThrough: passThrough)
        
        let nav = NavigationView {
            view
        }
        
        let controller = UIHostingController(rootView: nav)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "1 filter")
    }
    
    func testFilterCountDataSourcesChange() {
        UserDefaults.standard.setFilter(MockDataSourceDefinition().key,
                                        filter: [
                                            DataSourceFilterParameter(
                                                property: DataSourceProperty(
                                                    name: "Date",
                                                    key: #keyPath(MockDataSource.dateProperty),
                                                    type: .date),
                                                comparison: .window,
                                                windowUnits: DataSourceWindowUnits.last365Days)
                                        ]
        )
        
        class PassThrough {
            var filterOpen: Bool = false
            var sortOpen: Bool = false
        }
        
        struct Container: View {
            @State var filterOpen = false
            @State var sortOpen = false
            @State var dataSources: [DataSourceItem] = []
            let passThrough: PassThrough
            
            var body: some View {
                Rectangle()
                    .background(Color.ngaGreen)
                    .modifier(FilterButton(filterOpen: $filterOpen, dataSources: $dataSources, allowSorting: false, allowFiltering: true))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            dataSources = [DataSourceItem(dataSource: MockDataSourceDefinition().self)]
                        }
                    }
            }
            
            public init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
        }
        
        let passThrough = PassThrough()
        let view = Container(passThrough: passThrough)
        
        let nav = NavigationView {
            view
        }
        
        let controller = UIHostingController(rootView: nav)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "1 filter")
    }
    
}

