////
////  StringFilterTests.swift
////  MarlinTests
////
////  Created by Daniel Barela on 12/31/22.
////
//
//import XCTest
//import SwiftUI
//
//@testable import Marlin
//
//final class StringFilterTests: XCTestCase {
//    
//    func testFilterChange() {
//        class PassThrough: ObservableObject {
//            var viewModel: DataSourcePropertyFilterViewModel?
//            init() {
//            }
//        }
//        
//        struct Container: View {
//            @ObservedObject var passThrough: PassThrough
//            
//            @ObservedObject var filterViewModel = PersistedFilterViewModel(dataSource: MockDataSource.self)
//            @ObservedObject var dataSourcePropertyFilterViewModel = DataSourcePropertyFilterViewModel(dataSourceProperty: DataSourceProperty(name: "String", key: "stringProperty", type: .string))
//            
//            init(passThrough: PassThrough) {
//                self.passThrough = passThrough
//                self.passThrough.viewModel = dataSourcePropertyFilterViewModel
//            }
//            
//            var body: some View {
//                NavigationView {
//                    StringFilter(filterViewModel: filterViewModel, viewModel: dataSourcePropertyFilterViewModel)
//                }
//            }
//        }
//        
//        let passThrough = PassThrough()
//        let view = Container(passThrough: passThrough)
//        
//        let controller = UIHostingController(rootView: view)
//        let window = TestHelpers.getKeyWindowVisible()
//        window.rootViewController = controller
//        tester().waitForView(withAccessibilityLabel: "String input")
//        tester().enterText("hello", intoViewWithAccessibilityLabel: "String input")
//        tester().waitForAnimationsToFinish()
//        tester().waitForView(withAccessibilityLabel: "Done")
//        tester().tapView(withAccessibilityLabel: "Done")
//        XCTAssertEqual(passThrough.viewModel?.valueString, "hello")
//    }
//}
