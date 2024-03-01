//
//  SortViewModelTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 12/5/22.
//

import XCTest

@testable import Marlin

final class SortViewModelTests: XCTestCase {
    
    override func setUp() {
        UserDefaults.standard.set(nil, forKey: "\(MockDataSource.key)Sort")
        UserDefaults.standard.set(nil, forKey: "\(MockDataSourceDefaultSort.key)Sort")
    }
    
    override class func tearDown() {
        UserDefaults.standard.set(nil, forKey: "\(MockDataSource.key)Sort")
        UserDefaults.standard.set(nil, forKey: "\(MockDataSourceDefaultSort.key)Sort")
    }

    func testSortProperties() {
        let sortViewModel = SortViewModel(dataSource: MockDataSource.self)
        XCTAssertEqual(sortViewModel.sort, [])
        XCTAssertFalse(sortViewModel.sections)
    }
    
    func testSortPropertiesWithDefault() {
        let sortViewModel = SortViewModel(dataSource: MockDataSourceDefaultSort.self)
        XCTAssertEqual(sortViewModel.sort.count, 1)
        XCTAssertFalse(sortViewModel.sections)
        XCTAssertEqual(sortViewModel.sort[0].property.key, MockDataSourceDefaultSort.defaultSort[0].property.key)
    }
    
    func testSortPropertiesUserDefaultOverride() {
        UserDefaults.standard.setSort(MockDataSource.key, sort: [
            DataSourceSortParameter(property: DataSourceProperty(name: "Int", key: "intProperty", type: .int), ascending: true)
        ])
        
        let sortViewModel = SortViewModel(dataSource: MockDataSource.self)
        XCTAssertEqual(sortViewModel.sort.count, 1)
        XCTAssertEqual(sortViewModel.sort[0].property.key, "intProperty")
        XCTAssertFalse(sortViewModel.sections)
    }
    
    func testSortPropertiesUserDefaultOverrideWithSections() {
        UserDefaults.standard.setSort(MockDataSource.key, sort: [
            DataSourceSortParameter(property: DataSourceProperty(name: "Int", key: "intProperty", type: .int), ascending: true, section: true)
        ])
        
        let sortViewModel = SortViewModel(dataSource: MockDataSource.self)
        XCTAssertEqual(sortViewModel.sort.count, 1)
        XCTAssertEqual(sortViewModel.sort[0].property.key, "intProperty")
        XCTAssertTrue(sortViewModel.sections)
    }
    
    func testSortPropertiesWithDefaultUserDefaultOverride() {
        UserDefaults.standard.setSort(MockDataSourceDefaultSort.key, sort: [
            DataSourceSortParameter(property: DataSourceProperty(name: "Int", key: "intProperty", type: .int), ascending: true)
        ])
        
        let sortViewModel = SortViewModel(dataSource: MockDataSourceDefaultSort.self)
        XCTAssertEqual(sortViewModel.sort.count, 1)
        XCTAssertEqual(sortViewModel.sort[0].property.key, "intProperty")
        XCTAssertFalse(sortViewModel.sections)
    }
    
    func testSortPropertiesWithDefaultUserDefaultOverrideWithSections() {
        UserDefaults.standard.setSort(MockDataSourceDefaultSort.key, sort: [
            DataSourceSortParameter(property: DataSourceProperty(name: "Int", key: "intProperty", type: .int), ascending: true, section: true)
        ])
        
        let sortViewModel = SortViewModel(dataSource: MockDataSourceDefaultSort.self)
        XCTAssertEqual(sortViewModel.sort.count, 1)
        XCTAssertEqual(sortViewModel.sort[0].property.key, "intProperty")
        XCTAssertTrue(sortViewModel.sections)
    }
    
    func testAddSections() {
        UserDefaults.standard.setSort(MockDataSource.key, sort: [
            DataSourceSortParameter(property: DataSourceProperty(name: "Int", key: "intProperty", type: .int), ascending: true)
        ])
        
        let sortViewModel = SortViewModel(dataSource: MockDataSource.self)
        XCTAssertEqual(sortViewModel.sort.count, 1)
        XCTAssertEqual(sortViewModel.sort[0].property.key, "intProperty")
        XCTAssertFalse(sortViewModel.sort[0].section)
        XCTAssertFalse(sortViewModel.sections)
        
        sortViewModel.sections = true
        XCTAssertTrue(sortViewModel.sort[0].section)
        XCTAssertTrue(sortViewModel.sections)
    }
    
    func testAddAdditionalSortProperty() throws {
        UserDefaults.standard.setSort(MockDataSource.key, sort: [
            DataSourceSortParameter(property: DataSourceProperty(name: "Int", key: "intProperty", type: .int), ascending: true)
        ])
        
        let sortViewModel = SortViewModel(dataSource: MockDataSource.self)
        XCTAssertEqual(sortViewModel.sort.count, 1)
        XCTAssertEqual(sortViewModel.sort[0].property.key, "intProperty")
        XCTAssertFalse(sortViewModel.sections)
        
        sortViewModel.selectedProperty = DataSourceProperty(name: "String", key: "stringProperty", type: .string)
        sortViewModel.ascending = false
        
        XCTAssertNil(sortViewModel.secondSortProperty)
        
        sortViewModel.addSortProperty()
        XCTAssertEqual(sortViewModel.sort.count, 2)
        XCTAssertEqual(sortViewModel.sort[0].property.key, "intProperty")
        let secondSort = try XCTUnwrap(sortViewModel.secondSortProperty)
        XCTAssertEqual(secondSort.property.key, "stringProperty")
        XCTAssertFalse(secondSort.ascending)
        XCTAssertFalse(sortViewModel.sections)
        
        // since we only allow two
        let possibleSort = sortViewModel.possibleSortProperties
        XCTAssertEqual(possibleSort.count, 0)
    }
    
    func testAddFirstSortProperty() {
        let sortViewModel = SortViewModel(dataSource: MockDataSource.self)
        XCTAssertEqual(sortViewModel.sort.count, 0)
        XCTAssertFalse(sortViewModel.sections)
        
        sortViewModel.selectedProperty = DataSourceProperty(name: "String", key: "stringProperty", type: .string)
        sortViewModel.ascending = false
        sortViewModel.sections = false
        
        sortViewModel.addSortProperty()
        XCTAssertEqual(sortViewModel.sort.count, 1)
        XCTAssertEqual(sortViewModel.sort[0].property.key, "stringProperty")
        XCTAssertFalse(sortViewModel.sort[0].ascending)
        XCTAssertFalse(sortViewModel.sections)
    }
    
    func testAddFirstSortPropertyWithSections() {
        let sortViewModel = SortViewModel(dataSource: MockDataSource.self)
        XCTAssertNil(sortViewModel.firstSortProperty)
        XCTAssertEqual(sortViewModel.sort.count, 0)
        XCTAssertFalse(sortViewModel.sections)
        
        sortViewModel.selectedProperty = DataSourceProperty(name: "String", key: "stringProperty", type: .string)
        sortViewModel.ascending = false
        sortViewModel.sections = true
        
        sortViewModel.addSortProperty()
        XCTAssertEqual(sortViewModel.sort.count, 1)
        let firstSort = sortViewModel.firstSortProperty!
        XCTAssertEqual(firstSort.property.key, "stringProperty")
        XCTAssertFalse(firstSort.ascending)
        XCTAssertTrue(sortViewModel.sections)
    }
    
    func testRemoveFirstSortProperties() throws {
        UserDefaults.standard.setSort(MockDataSource.key, sort: [
            DataSourceSortParameter(property: DataSourceProperty(name: "Int", key: "intProperty", type: .int), ascending: true, section: true),
            DataSourceSortParameter(property: DataSourceProperty(name: "String", key: "stringProperty", type: .string), ascending: true)
        ])
        
        let sortViewModel = SortViewModel(dataSource: MockDataSource.self)
        XCTAssertEqual(sortViewModel.sort.count, 2)
        XCTAssertEqual(sortViewModel.sort[0].property.key, "intProperty")
        XCTAssertTrue(sortViewModel.sections)
        
        sortViewModel.removeFirst()
        XCTAssertEqual(sortViewModel.sort.count, 1)
        XCTAssertEqual(sortViewModel.sort[0].property.key, "stringProperty")
        XCTAssertTrue(sortViewModel.sections)
    }
    
    func testRemoveSecondtSortProperties() throws {
        UserDefaults.standard.setSort(MockDataSource.key, sort: [
            DataSourceSortParameter(property: DataSourceProperty(name: "Int", key: "intProperty", type: .int), ascending: true, section: true),
            DataSourceSortParameter(property: DataSourceProperty(name: "String", key: "stringProperty", type: .string), ascending: true)
        ])
        
        let sortViewModel = SortViewModel(dataSource: MockDataSource.self)
        XCTAssertEqual(sortViewModel.sort.count, 2)
        XCTAssertEqual(sortViewModel.sort[0].property.key, "intProperty")
        XCTAssertTrue(sortViewModel.sections)
        
        sortViewModel.removeSecond()
        XCTAssertEqual(sortViewModel.sort.count, 1)
        XCTAssertEqual(sortViewModel.sort[0].property.key, "intProperty")
        XCTAssertTrue(sortViewModel.sections)
    }
}
