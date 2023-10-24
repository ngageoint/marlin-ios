////
////  BooleanFilterTests.swift
////  MarlinTests
////
////  Created by Daniel Barela on 12/30/22.
////
//
//import XCTest
//import SwiftUI
//
//@testable import Marlin
//
//final class BooleanFilterTests: XCTestCase {
//
//    // untestable until you can pick form a picker
//    func xtestFilterChange() {
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
//            @ObservedObject var dataSourcePropertyFilterViewModel = DataSourcePropertyFilterViewModel(dataSourceProperty: DataSourceProperty(name: "Boolean", key: "booleanProperty", type: .boolean))
//            
//            init(passThrough: PassThrough) {
//                self.passThrough = passThrough
//                self.passThrough.viewModel = dataSourcePropertyFilterViewModel
//            }
//            
//            var body: some View {
//                NavigationView {
//                    BooleanFilter(filterViewModel: filterViewModel, viewModel: dataSourcePropertyFilterViewModel)
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
//        tester().waitForView(withAccessibilityLabel: "Boolean input")
//        tester().tapView(withAccessibilityLabel: "True")
//        tester().waitForView(withAccessibilityLabel: "False")
//        tester().tapView(withAccessibilityLabel: "False")
//        
//        tester().waitForAnimationsToFinish()
//        tester().wait(forTimeInterval: 5)
//        // even though it looks like it is being tapped, it is not
//        XCTAssertEqual(passThrough.viewModel?.valueInt, 0)
//    }
//}
