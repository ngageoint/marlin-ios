//
//  BooleanFilterTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 12/30/22.
//

import XCTest
import SwiftUI

@testable import Marlin

final class BooleanFilterTests: XCTestCase {

    func xtestFilterChange() {
        @ObservedObject var filterViewModel = FilterViewModel(dataSource: MockDataSource.self)
        @ObservedObject var dataSourcePropertyFilterViewModel = DataSourcePropertyFilterViewModel(dataSourceProperty: DataSourceProperty(name: "Boolean", key: "booleanProperty", type: .boolean))
        dataSourcePropertyFilterViewModel.valueInt = 0
        
        let filter = BooleanFilter(filterViewModel: filterViewModel, viewModel: dataSourcePropertyFilterViewModel)
        let controller = UIHostingController(rootView: filter)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "True")
        window.printHierarchy()
        tester().tapView(withAccessibilityLabel: "True")
        tester().waitForView(withAccessibilityLabel: "False")
        tester().tapView(withAccessibilityLabel: "False")
//        tester().selectPickerViewRow(withTitle: "True", inComponent: 0)
//        XCTAssertEqual(dataSourcePropertyFilterViewModel.valueInt, 1)
//        tester().selectPickerViewRow(withTitle: "False")
        tester().wait(forTimeInterval: 5)
        XCTAssertEqual(dataSourcePropertyFilterViewModel.valueInt, 0)
    }
}
