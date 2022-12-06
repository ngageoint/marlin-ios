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
        let p = DataSourceSortParameter(property: DataSourceProperty(name: "String", key: "string", type: .string), ascending: true)
        XCTAssertEqual(p.property.key, "string")
        XCTAssertTrue(p.ascending)
        XCTAssertFalse(p.section)
        let sort = NSSortDescriptor(key: "string", ascending: true)
        XCTAssertEqual(p.toNSSortDescriptor(), sort)
    }
    
    func testToNSSortDescriptorDescending() {
        let p = DataSourceSortParameter(property: DataSourceProperty(name: "String", key: "string", type: .string), ascending: false)
        XCTAssertEqual(p.property.key, "string")
        XCTAssertFalse(p.ascending)
        XCTAssertFalse(p.section)
        let sort = NSSortDescriptor(key: "string", ascending: false)
        XCTAssertEqual(p.toNSSortDescriptor(), sort)
    }
    
    func testToNSSortDescriptorSectionAscending() {
        let p = DataSourceSortParameter(property: DataSourceProperty(name: "String", key: "string", type: .string), ascending: true, section: true)
        XCTAssertEqual(p.property.key, "string")
        XCTAssertTrue(p.ascending)
        XCTAssertTrue(p.section)
        let sort = NSSortDescriptor(key: "string", ascending: true)
        XCTAssertEqual(p.toNSSortDescriptor(), sort)
    }
    
    func testToNSSortDescriptorSectionDescending() {
        let p = DataSourceSortParameter(property: DataSourceProperty(name: "String", key: "string", type: .string), ascending: false, section: true)
        XCTAssertEqual(p.property.key, "string")
        XCTAssertFalse(p.ascending)
        XCTAssertTrue(p.section)
        let sort = NSSortDescriptor(key: "string", ascending: false)
        XCTAssertEqual(p.toNSSortDescriptor(), sort)
    }
}
