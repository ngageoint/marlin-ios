//
//  FilterViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 12/1/22.
//

import Foundation
import Combine
import CoreData

class FilterViewModel: ObservableObject, Identifiable {
    var id: String { dataSource.key }
    var dataSource: any DataSource.Type
    var commonFilters: [DataSourceFilterParameter]? {
        didSet {
            if let fetchRequest = dataSource.fetchRequest(filters: filters, commonFilters: commonFilters) {
                count = (try? PersistenceController.current.viewContext.count(for: fetchRequest)) ?? 0
            }
        }
    }
    @Published var filters: [DataSourceFilterParameter] {
        didSet {
            if let fetchRequest = dataSource.fetchRequest(filters: filters, commonFilters: commonFilters) {
                count = (try? PersistenceController.current.viewContext.count(for: fetchRequest)) ?? 0
            }
        }
    }
    @Published var selectedProperty: DataSourceProperty?
    @Published var filterParameter: DataSourceFilterParameter?
    @Published var count: Int = 0
    
    var requiredProperties: [DataSourceProperty] {
        dataSource.properties.filter({ property in
            property.requiredInFilter
        })
    }
    var requiredNotSet: [DataSourceProperty] {
        return requiredProperties.filter { property in
            !filters.contains { parameter in
                parameter.property.key == property.key
            }
        }
    }
    
    init(dataSource: any DataSource.Type, commonFilters: [DataSourceFilterParameter]? = nil) {
        self.dataSource = dataSource
        self.filters = []
        self.commonFilters = commonFilters
        if !dataSource.properties.isEmpty {
            selectedProperty = dataSource.properties[0]
        }
        if let fetchRequest = dataSource.fetchRequest(filters: filters, commonFilters: commonFilters) {
            count = (try? PersistenceController.current.viewContext.count(for: fetchRequest)) ?? 0
        }
    }
    
    func addFilterParameter(viewModel: DataSourcePropertyFilterViewModel) {
        filters.append(DataSourceFilterParameter(property: viewModel.dataSourceProperty, comparison: viewModel.selectedComparison, valueString: viewModel.valueString, valueDate: viewModel.valueDate, valueInt: viewModel.valueInt, valueDouble: viewModel.valueDouble, valueLatitude: viewModel.valueLatitude, valueLongitude: viewModel.valueLongitude, valueMinLatitude: viewModel.valueMinLatitude, valueMinLongitude: viewModel.valueMinLongitude, valueMaxLatitude: viewModel.valueMaxLatitude, valueMaxLongitude: viewModel.valueMaxLongitude, windowUnits: viewModel.windowUnits))
        viewModel.valueDate = Date()
        viewModel.valueString = ""
        viewModel.valueDouble = nil //0.0
        viewModel.valueInt = nil// 0
        viewModel.valueLongitude = nil
        viewModel.valueLatitude = nil
        viewModel.valueLatitudeString = ""
        viewModel.valueLongitudeString = ""
        viewModel.windowUnits = .last30Days
        viewModel.valueMinLatitude = nil
        viewModel.valueMinLongitude = nil
        viewModel.valueMaxLatitude = nil
        viewModel.valueMaxLongitude = nil
        viewModel.valueMinLatitudeString = ""
        viewModel.valueMinLongitudeString = ""
        viewModel.valueMaxLatitudeString = ""
        viewModel.valueMaxLongitudeString = ""
    }
}

class PersistedFilterViewModel: FilterViewModel {
    override var filters: [DataSourceFilterParameter] {
        didSet {
            UserDefaults.standard.setFilter(dataSource.key, filter: filters)
        }
    }
    
    init(dataSource: any DataSource.Type, useDefaultForEmptyFilter: Bool = false, commonFilters: [DataSourceFilterParameter]? = nil) {
        super.init(dataSource: dataSource, commonFilters: commonFilters)
        let savedFilter = UserDefaults.standard.filter(dataSource)
        if useDefaultForEmptyFilter && savedFilter.isEmpty {
            self.filters = dataSource.defaultFilter
        } else {
            self.filters = savedFilter
        }

    }
}

class TemporaryFilterViewModel: FilterViewModel {
    init(dataSource: any DataSource.Type, filters: [DataSourceFilterParameter]? = nil, commonFilters: [DataSourceFilterParameter]? = nil) {
        super.init(dataSource: dataSource, commonFilters: commonFilters)
        self.filters = filters ?? UserDefaults.standard.filter(dataSource)
    }
}
