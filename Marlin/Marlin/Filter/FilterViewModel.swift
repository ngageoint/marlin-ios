//
//  FilterViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 12/1/22.
//

import Foundation

class FilterViewModel: ObservableObject {
    let dataSource: any DataSource.Type
    @Published var filters: [DataSourceFilterParameter] {
        didSet {
            UserDefaults.standard.setFilter(dataSource.key, filter: filters)
        }
    }
    
    var requiredProperties: [DataSourceProperty] {
        dataSource.properties.filter({ property in
            property.requiredInFilter
        })
    }
    var requiredNotSet: [DataSourceProperty] {
        requiredProperties.filter { property in
            !filters.contains { parameter in
                parameter.property.key == property.key
            }
        }
    }
    
    @Published var selectedProperty: DataSourceProperty?
    @Published var filterParameter: DataSourceFilterParameter?
    
    init(dataSource: any DataSource.Type, useDefaultForEmptyFilter: Bool = false) {
        self.dataSource = dataSource
        let savedFilter = UserDefaults.standard.filter(dataSource)
        if useDefaultForEmptyFilter && savedFilter.isEmpty {
            self.filters = dataSource.defaultFilter
        } else {
            self.filters = savedFilter
        }
        if !dataSource.properties.isEmpty {
            selectedProperty = dataSource.properties[0]
        }
    }
    
    func addFilterParameter(viewModel: DataSourcePropertyFilterViewModel) {
        filters.append(DataSourceFilterParameter(property: viewModel.dataSourceProperty, comparison: viewModel.selectedComparison, valueString: viewModel.valueString, valueDate: viewModel.valueDate, valueInt: viewModel.valueInt, valueDouble: viewModel.valueDouble, valueLatitude: viewModel.valueLatitude, valueLongitude: viewModel.valueLongitude, windowUnits: viewModel.windowUnits))
        viewModel.valueDate = Date()
        viewModel.valueString = ""
        viewModel.valueDouble = nil //0.0
        viewModel.valueInt = nil// 0
        viewModel.valueLongitude = nil
        viewModel.valueLatitude = nil
        viewModel.valueLatitudeString = ""
        viewModel.valueLongitudeString = ""
        viewModel.windowUnits = .last30Days
    }
}
