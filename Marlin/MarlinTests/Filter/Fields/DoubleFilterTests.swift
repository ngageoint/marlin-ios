//
//  DoubleFilterTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/15/23.
//

import XCTest
import SwiftUI

@testable import Marlin

final class DoubleFilterTests: XCTestCase {

    func testFilterChange() {
        class PassThrough: ObservableObject {
            var viewModel: DataSourcePropertyFilterViewModel?
            init() {
            }
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            
            @ObservedObject var filterViewModel = FilterViewModel(dataSource: MockDataSource.self)
            @ObservedObject var dataSourcePropertyFilterViewModel = DataSourcePropertyFilterViewModel(dataSourceProperty: DataSourceProperty(name: "Double", key: "doubleProperty", type: .double))
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
                self.passThrough.viewModel = dataSourcePropertyFilterViewModel
            }
            
            var body: some View {
                NavigationView {
                    DoubleFilter(filterViewModel: filterViewModel, viewModel: dataSourcePropertyFilterViewModel)
                }
            }
        }
        
        let passThrough = PassThrough()
        let view = Container(passThrough: passThrough)
        
        let controller = UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Double input")
        tester().enterText("1.4", intoViewWithAccessibilityLabel: "Double input")
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "Done")
        tester().tapView(withAccessibilityLabel: "Done")
        XCTAssertEqual(passThrough.viewModel?.valueDouble, 1.4)
    }
    
    func testInvalidFilter() {
        class PassThrough: ObservableObject {
            var viewModel: DataSourcePropertyFilterViewModel?
            init() {
            }
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            
            @ObservedObject var filterViewModel = FilterViewModel(dataSource: MockDataSource.self)
            @ObservedObject var dataSourcePropertyFilterViewModel = DataSourcePropertyFilterViewModel(dataSourceProperty: DataSourceProperty(name: "Double", key: "doubleProperty", type: .double))
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
                self.passThrough.viewModel = dataSourcePropertyFilterViewModel
            }
            
            var body: some View {
                NavigationView {
                    DoubleFilter(filterViewModel: filterViewModel, viewModel: dataSourcePropertyFilterViewModel)
                }
            }
        }
        
        let passThrough = PassThrough()
        let view = Container(passThrough: passThrough)
        
        let controller = UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Double input")
        tester().enterText("hi", intoViewWithAccessibilityLabel: "Double input")
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "Done")
        tester().tapView(withAccessibilityLabel: "Done")
        XCTAssertEqual(passThrough.viewModel?.valueDouble, nil)
        tester().waitForView(withAccessibilityLabel: "Invalid number")
    }
}
