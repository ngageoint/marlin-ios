//
//  IntFilterTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/15/23.
//

import XCTest
import SwiftUI

@testable import Marlin

final class IntFilterTests: XCTestCase {
    
    func testFilterChange() {
        class PassThrough: ObservableObject {
            var viewModel: DataSourcePropertyFilterViewModel?
            init() {
            }
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            
            @ObservedObject var filterViewModel = PersistedFilterViewModel(dataSource: MockDataSource.self)
            @ObservedObject var dataSourcePropertyFilterViewModel = DataSourcePropertyFilterViewModel(dataSourceProperty: DataSourceProperty(name: "Int", key: "intProperty", type: .int))
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
                self.passThrough.viewModel = dataSourcePropertyFilterViewModel
            }
            
            var body: some View {
                NavigationView {
                    IntFilter(filterViewModel: filterViewModel, viewModel: dataSourcePropertyFilterViewModel)
                }
            }
        }
        
        let passThrough = PassThrough()
        let view = Container(passThrough: passThrough)
        
        let controller = UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Int input")
        tester().enterText("10", intoViewWithAccessibilityLabel: "Int input")
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "Done")
        tester().tapView(withAccessibilityLabel: "Done")
        XCTAssertEqual(passThrough.viewModel?.valueInt, 10)
        // can't choose anything else until we can pick from a picker
        XCTAssertEqual(passThrough.viewModel?.selectedComparison, .equals)
    }
    
    func testInvalidFilter() {
        class PassThrough: ObservableObject {
            var viewModel: DataSourcePropertyFilterViewModel?
            init() {
            }
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            
            @ObservedObject var filterViewModel = PersistedFilterViewModel(dataSource: MockDataSource.self)
            @ObservedObject var dataSourcePropertyFilterViewModel = DataSourcePropertyFilterViewModel(dataSourceProperty: DataSourceProperty(name: "Int", key: "intProperty", type: .int))
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
                self.passThrough.viewModel = dataSourcePropertyFilterViewModel
            }
            
            var body: some View {
                NavigationView {
                    IntFilter(filterViewModel: filterViewModel, viewModel: dataSourcePropertyFilterViewModel)
                }
            }
        }
        
        let passThrough = PassThrough()
        let view = Container(passThrough: passThrough)
        
        let controller = UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Int input")
        tester().enterText("hi", intoViewWithAccessibilityLabel: "Int input")
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "Done")
        tester().tapView(withAccessibilityLabel: "Done")
        XCTAssertEqual(passThrough.viewModel?.valueInt, nil)
        tester().waitForView(withAccessibilityLabel: "Invalid number")
    }
    
    func testDoubleCoercedToInt() {
        class PassThrough: ObservableObject {
            var viewModel: DataSourcePropertyFilterViewModel?
            init() {
            }
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            
            @ObservedObject var filterViewModel = PersistedFilterViewModel(dataSource: MockDataSource.self)
            @ObservedObject var dataSourcePropertyFilterViewModel = DataSourcePropertyFilterViewModel(dataSourceProperty: DataSourceProperty(name: "Int", key: "intProperty", type: .int))
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
                self.passThrough.viewModel = dataSourcePropertyFilterViewModel
            }
            
            var body: some View {
                NavigationView {
                    IntFilter(filterViewModel: filterViewModel, viewModel: dataSourcePropertyFilterViewModel)
                }
            }
        }
        
        let passThrough = PassThrough()
        let view = Container(passThrough: passThrough)
        
        let controller = UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Int input")
        tester().enterText("1.4", intoViewWithAccessibilityLabel: "Int input")
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "Done")
        tester().tapView(withAccessibilityLabel: "Done")
        XCTAssertEqual(passThrough.viewModel?.valueInt, 1)
    }
}
