//
//  DataSourceSortTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 12/5/22.
//

import XCTest

@testable import Marlin

final class DataSourceSortTests: XCTestCase {

    func testToNSSortDescriptorAscending() {
        let parameter = DataSourceSortParameter(property: DataSourceProperty(name: "String", key: "string", type: .string), ascending: true)
        XCTAssertEqual(parameter.property.key, "string")
        XCTAssertTrue(parameter.ascending)
        XCTAssertFalse(parameter.section)
        let sort = NSSortDescriptor(key: "string", ascending: true)
        XCTAssertEqual(parameter.toNSSortDescriptor(), sort)
    }
    
    func testToNSSortDescriptorDescending() {
        let parameter = DataSourceSortParameter(property: DataSourceProperty(name: "String", key: "string", type: .string), ascending: false)
        XCTAssertEqual(parameter.property.key, "string")
        XCTAssertFalse(parameter.ascending)
        XCTAssertFalse(parameter.section)
        let sort = NSSortDescriptor(key: "string", ascending: false)
        XCTAssertEqual(parameter.toNSSortDescriptor(), sort)
    }
    
    func testToNSSortDescriptorSectionAscending() {
        let parameter = DataSourceSortParameter(property: DataSourceProperty(name: "String", key: "string", type: .string), ascending: true, section: true)
        XCTAssertEqual(parameter.property.key, "string")
        XCTAssertTrue(parameter.ascending)
        XCTAssertTrue(parameter.section)
        let sort = NSSortDescriptor(key: "string", ascending: true)
        XCTAssertEqual(parameter.toNSSortDescriptor(), sort)
    }
    
    func testToNSSortDescriptorSectionDescending() {
        let parameter = DataSourceSortParameter(property: DataSourceProperty(name: "String", key: "string", type: .string), ascending: false, section: true)
        XCTAssertEqual(parameter.property.key, "string")
        XCTAssertFalse(parameter.ascending)
        XCTAssertTrue(parameter.section)
        let sort = NSSortDescriptor(key: "string", ascending: false)
        XCTAssertEqual(parameter.toNSSortDescriptor(), sort)
    }
}
