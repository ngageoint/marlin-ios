//
//  FilterViewModelTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 12/6/22.
//

import XCTest

@testable import Marlin

final class FilterViewModelTests: XCTestCase {

    override func setUp() {
        UserDefaults.standard.setFilter(MockDataSource.key, filter: [])
        UserDefaults.standard.setFilter(MockDataSourceDefaultSort.key, filter: [])
    }
    
    override class func tearDown() {
        UserDefaults.standard.setFilter(MockDataSource.key, filter: [])
        UserDefaults.standard.setFilter(MockDataSourceDefaultSort.key, filter: [])
    }
    
    func testFilterProperties() {
        let filterViewModel = PersistedFilterViewModel(dataSource: MockDataSource.self)
        XCTAssertEqual(filterViewModel.filters, [])
    }
    
    func testFilterPropertiesWithoutUsingDefault() {
        let savedFilter = UserDefaults.standard.filter(MockDataSourceDefaultSort.self)
        XCTAssertEqual([], savedFilter)
        
        let filterViewModel = PersistedFilterViewModel(dataSource: MockDataSourceDefaultSort.self)
        XCTAssertEqual(filterViewModel.filters, [])
        
        let model = DataSourcePropertyFilterViewModel(dataSourceProperty: DataSourceProperty(name: "Date", key: #keyPath(MockDataSource.dateProperty), type: .date))
        model.startValidating = true
        model.selectedComparison = .equals
        model.valueDate = Date(timeIntervalSince1970: 0)
        
        filterViewModel.addFilterParameter(viewModel: model)
        XCTAssertEqual(filterViewModel.filters.count, 1)
    }
    
    func testFilterPropertiesUsingDefault() {
        let filterViewModel = PersistedFilterViewModel(dataSource: MockDataSourceDefaultSort.self, useDefaultForEmptyFilter: true)
        XCTAssertEqual(filterViewModel.filters.count, MockDataSourceDefaultSort.defaultFilter.count)
        
        let model = DataSourcePropertyFilterViewModel(dataSourceProperty: DataSourceProperty(name: "Date", key: #keyPath(MockDataSource.dateProperty), type: .date))
        model.startValidating = true
        model.selectedComparison = .equals
        model.valueDate = Date(timeIntervalSince1970: 0)
        
        filterViewModel.addFilterParameter(viewModel: model)
        XCTAssertEqual(filterViewModel.filters.count, MockDataSourceDefaultSort.defaultFilter.count + 1)
    }
    
    func testChartCorrectionModel() {
        let filterViewModel = PersistedFilterViewModel(dataSource: ChartCorrection.self, useDefaultForEmptyFilter: true)
        XCTAssertEqual(filterViewModel.requiredProperties.count, 1)
        XCTAssertEqual(filterViewModel.requiredNotSet.count, 0)
        
        filterViewModel.filters.remove(at: 0)
        XCTAssertEqual(filterViewModel.requiredProperties.count, 1)
        XCTAssertEqual(filterViewModel.requiredNotSet.count, 1)
    }
}
