//
//  LatitudeLongitudeFilterTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/16/23.
//

import XCTest
import SwiftUI
import CoreLocation

@testable import Marlin

final class LatitudeLongitudeFilterTests: XCTestCase {
    
    func testLatitudeFilterChange() {
        class PassThrough: ObservableObject {
            var viewModel: DataSourcePropertyFilterViewModel?
            init() {
            }
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            
            @ObservedObject var filterViewModel = PersistedFilterViewModel(dataSource: MockDataSource.self)
            @ObservedObject var dataSourcePropertyFilterViewModel = DataSourcePropertyFilterViewModel(dataSourceProperty: DataSourceProperty(name: "Latitude", key: "latitudeProperty", type: .latitude))
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
                self.passThrough.viewModel = dataSourcePropertyFilterViewModel
            }
            
            var body: some View {
                NavigationView {
                    LatitudeLongitudeFilter(filterViewModel: filterViewModel, viewModel: dataSourcePropertyFilterViewModel)
                }
                .onAppear {
                    dataSourcePropertyFilterViewModel.selectedComparison = .closeTo
                }
            }
        }
        
        let passThrough = PassThrough()
        let view = Container(passThrough: passThrough)
        
        let controller = UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Latitude input")
        tester().tapView(withAccessibilityLabel: "Latitude input")
        tester().clearTextFromFirstResponder()
        tester().enterText("10.2", intoViewWithAccessibilityLabel: "Latitude input")
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "Done")
        tester().tapView(withAccessibilityLabel: "Done")
        XCTAssertEqual(passThrough.viewModel?.valueString, "10.2")
        XCTAssertTrue(passThrough.viewModel!.isValid)
    }
    
    func testLongitudeFilterChange() {
        class PassThrough: ObservableObject {
            var viewModel: DataSourcePropertyFilterViewModel?
            init() {
            }
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            
            @ObservedObject var filterViewModel = PersistedFilterViewModel(dataSource: MockDataSource.self)
            @ObservedObject var dataSourcePropertyFilterViewModel = DataSourcePropertyFilterViewModel(dataSourceProperty: DataSourceProperty(name: "Longitude", key: "longitudeProperty", type: .latitude))
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
                self.passThrough.viewModel = dataSourcePropertyFilterViewModel
            }
            
            var body: some View {
                NavigationView {
                    LatitudeLongitudeFilter(filterViewModel: filterViewModel, viewModel: dataSourcePropertyFilterViewModel)
                }
                .onAppear {
                    dataSourcePropertyFilterViewModel.selectedComparison = .closeTo
                }
            }
        }
        
        let passThrough = PassThrough()
        let view = Container(passThrough: passThrough)
        
        let controller = UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Longitude input")
        tester().tapView(withAccessibilityLabel: "Longitude input")
        tester().clearTextFromFirstResponder()
        tester().enterText("10.2", intoViewWithAccessibilityLabel: "Longitude input")
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "Done")
        tester().tapView(withAccessibilityLabel: "Done")
        XCTAssertEqual(passThrough.viewModel?.valueString, "10.2")
        XCTAssertTrue(passThrough.viewModel!.isValid)
    }
    
    func testInvalidLatitudeFilter() {
        class PassThrough: ObservableObject {
            var viewModel: DataSourcePropertyFilterViewModel?
            init() {
            }
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            
            @ObservedObject var filterViewModel = PersistedFilterViewModel(dataSource: MockDataSource.self)
            @ObservedObject var dataSourcePropertyFilterViewModel = DataSourcePropertyFilterViewModel(dataSourceProperty: DataSourceProperty(name: "Latitude", key: "latitudeProperty", type: .latitude))
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
                self.passThrough.viewModel = dataSourcePropertyFilterViewModel
            }
            
            var body: some View {
                NavigationView {
                    LatitudeLongitudeFilter(filterViewModel: filterViewModel, viewModel: dataSourcePropertyFilterViewModel)
                }
                .onAppear {
                    dataSourcePropertyFilterViewModel.selectedComparison = .closeTo
                }
            }
        }
        
        let passThrough = PassThrough()
        let view = Container(passThrough: passThrough)
        
        let controller = UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Latitude input")
        tester().tapView(withAccessibilityLabel: "Latitude input")
        tester().clearTextFromFirstResponder()
        tester().enterText("Turtle", intoViewWithAccessibilityLabel: "Latitude input")
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "Done")
        tester().tapView(withAccessibilityLabel: "Done")
        tester().waitForView(withAccessibilityLabel: "Invalid Latitude")
        XCTAssertEqual(passThrough.viewModel?.valueString, "Turtle")
        XCTAssertFalse(passThrough.viewModel!.isValid)
    }
    
    func testInvalidLongitudeFilterChange() {
        class PassThrough: ObservableObject {
            var viewModel: DataSourcePropertyFilterViewModel?
            init() {
            }
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            
            @ObservedObject var filterViewModel = PersistedFilterViewModel(dataSource: MockDataSource.self)
            @ObservedObject var dataSourcePropertyFilterViewModel = DataSourcePropertyFilterViewModel(dataSourceProperty: DataSourceProperty(name: "Longitude", key: "longitudeProperty", type: .latitude))
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
                self.passThrough.viewModel = dataSourcePropertyFilterViewModel
            }
            
            var body: some View {
                NavigationView {
                    LatitudeLongitudeFilter(filterViewModel: filterViewModel, viewModel: dataSourcePropertyFilterViewModel)
                }
                .onAppear {
                    dataSourcePropertyFilterViewModel.selectedComparison = .closeTo
                }
            }
        }
        
        let passThrough = PassThrough()
        let view = Container(passThrough: passThrough)
        
        let controller = UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Longitude input")
        tester().tapView(withAccessibilityLabel: "Longitude input")
        tester().clearTextFromFirstResponder()
        tester().enterText("Turtle", intoViewWithAccessibilityLabel: "Longitude input")
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "Done")
        tester().tapView(withAccessibilityLabel: "Done")
        XCTAssertEqual(passThrough.viewModel?.valueString, "Turtle")
        XCTAssertFalse(passThrough.viewModel!.isValid)
    }
}
