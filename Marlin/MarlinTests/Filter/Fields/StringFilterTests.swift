//
//  StringFilterTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 12/31/22.
//

import XCTest
import SwiftUI

@testable import Marlin

final class StringFilterTests: XCTestCase {
    
    func xtestFilterChange() {
        @ObservedObject var filterViewModel = FilterViewModel(dataSource: MockDataSource.self)
        @ObservedObject var dataSourcePropertyFilterViewModel = DataSourcePropertyFilterViewModel(dataSourceProperty: DataSourceProperty(name: "String", key: "stringProperty", type: .string))
        
        let filter = StringFilter(filterViewModel: filterViewModel, viewModel: dataSourcePropertyFilterViewModel)
        let controller = UIHostingController(rootView: filter)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "String input")
        window.printHierarchy()
        tester().tapView(withAccessibilityLabel: "String input")
        tester().enterText(intoCurrentFirstResponder: "hi")
        XCTAssertEqual(dataSourcePropertyFilterViewModel.valueString, "hello")
    }
}
