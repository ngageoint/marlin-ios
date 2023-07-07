//
//  FilterViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 12/1/22.
//

import Foundation
import Combine
import CoreData

class FilterViewModel: ObservableObject {
    var dataSource: any DataSource.Type
    @Published var filters: [DataSourceFilterParameter] {
        didSet {
            if let fetchRequest = fetchRequest() {
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
        requiredProperties.filter { property in
            !filters.contains { parameter in
                parameter.property.key == property.key
            }
        }
    }
    
    init(dataSource: any DataSource.Type) {
        self.dataSource = dataSource
        self.filters = []
        if !dataSource.properties.isEmpty {
            selectedProperty = dataSource.properties[0]
        }
        if let fetchRequest = fetchRequest() {
            count = (try? PersistenceController.current.viewContext.count(for: fetchRequest)) ?? 0
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
    
    func fetchRequest() -> NSFetchRequest<any NSFetchRequestResult>? {
        guard let dataSource = self.dataSource as? NSManagedObject.Type else {
            return nil
        }
        let fetchRequest = dataSource.fetchRequest()
        var predicates: [NSPredicate] = []
        for filter in filters {
            if let predicate = filter.toPredicate() {
                predicates.append(predicate)
            }
        }
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        fetchRequest.predicate = predicate
        return fetchRequest
    }
}

class PersistedFilterViewModel: FilterViewModel {
    override var filters: [DataSourceFilterParameter] {
        didSet {
            UserDefaults.standard.setFilter(dataSource.key, filter: filters)
        }
    }
    
    init(dataSource: any DataSource.Type, useDefaultForEmptyFilter: Bool = false) {
        super.init(dataSource: dataSource)
        let savedFilter = UserDefaults.standard.filter(dataSource)
        if useDefaultForEmptyFilter && savedFilter.isEmpty {
            self.filters = dataSource.defaultFilter
        } else {
            self.filters = savedFilter
        }

    }
}

class TemporaryFilterViewModel: FilterViewModel {
    init(dataSource: any DataSource.Type, filters: [DataSourceFilterParameter]) {
        super.init(dataSource: dataSource)
        self.filters = filters
    }
}
