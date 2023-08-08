//
//  DataSourceFilterComparisonTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 12/5/22.
//

import XCTest

@testable import Marlin

final class DataSourceFilterComparisonTests: XCTestCase {

    func testDateComparison() {
        let comparisons = DataSourceFilterComparison.dateSubset()
        XCTAssertEqual(comparisons, [.window, .equals, .notEquals, .greaterThan, .greaterThanEqual, .lessThan, .lessThanEqual])
    }
    
    func testNumberComparison() {
        let comparisons = DataSourceFilterComparison.numberSubset()
        XCTAssertEqual(comparisons, [.equals, .notEquals, .greaterThan, .greaterThanEqual, .lessThan, .lessThanEqual])
    }
    
    func testStringComparison() {
        let comparisons = DataSourceFilterComparison.stringSubset()
        XCTAssertEqual(comparisons, [.equals, .notEquals, .contains, .notContains, .startsWith, .endsWith])
    }
    
    func testEnumerationComparison() {
        let comparisons = DataSourceFilterComparison.enumerationSubset()
        XCTAssertEqual(comparisons, [.equals, .notEquals])
    }
    
    func testLocationComparison() {
        let comparisons = DataSourceFilterComparison.locationSubset()
        XCTAssertEqual(comparisons, [.nearMe, .closeTo, .bounds])
    }
    
    func testLatitudeComparison() {
        let comparisons = DataSourceFilterComparison.latitudeSubset()
        XCTAssertEqual(comparisons, [.equals, .notEquals, .greaterThan, .greaterThanEqual, .lessThan, .lessThanEqual])
    }
    
    func testLongitudeComparison() {
        let comparisons = DataSourceFilterComparison.longitudeSubset()
        XCTAssertEqual(comparisons, [.equals, .notEquals, .greaterThan, .greaterThanEqual, .lessThan, .lessThanEqual])
    }
    
    func testBooleanComparison() {
        let comparisons = DataSourceFilterComparison.booleanSubset()
        XCTAssertEqual(comparisons, [.equals, .notEquals])
    }
    
    func testCoreDataComparisons() {
        XCTAssertEqual(DataSourceFilterComparison.equals.coreDataComparison(), "==")
        XCTAssertEqual(DataSourceFilterComparison.contains.coreDataComparison(), "contains[cd]")
        XCTAssertEqual(DataSourceFilterComparison.notContains.coreDataComparison(), "not contains[cd]")
        XCTAssertEqual(DataSourceFilterComparison.startsWith.coreDataComparison(), "beginswith[cd]")
        XCTAssertEqual(DataSourceFilterComparison.endsWith.coreDataComparison(), "endswith[cd]")
        XCTAssertEqual(DataSourceFilterComparison.window.coreDataComparison(), ">=")
        XCTAssertEqual(DataSourceFilterComparison.notEquals.coreDataComparison(), "!=")
        XCTAssertEqual(DataSourceFilterComparison.greaterThan.coreDataComparison(), ">")
        XCTAssertEqual(DataSourceFilterComparison.greaterThanEqual.coreDataComparison(), ">=")
        XCTAssertEqual(DataSourceFilterComparison.lessThan.coreDataComparison(), "<")
        XCTAssertEqual(DataSourceFilterComparison.lessThanEqual.coreDataComparison(), "<=")
    }
}
