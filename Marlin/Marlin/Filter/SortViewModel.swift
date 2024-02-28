//
//  SortViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 12/5/22.
//

import Foundation

class SortViewModel: ObservableObject {
    let definition: any DataSourceDefinition
    let filterable: (any Filterable)?
    var dataSourceProperties: [DataSourceProperty]
    
    @Published var sort: [DataSourceSortParameter] {
        didSet {
            UserDefaults.standard.setSort(definition.key, sort: sort)
        }
    }
    
    @Published var selectedProperty: DataSourceProperty?
    @Published var ascending: Bool = true
    @Published var sections: Bool {
        didSet {
            if !sort.isEmpty {
                sort[0] = DataSourceSortParameter(
                    property: sort[0].property,
                    ascending: sort[0].ascending,
                    section: sections
                )
            }
        }
    }

    init(definition: any DataSourceDefinition) {
        self.definition = definition
        filterable = definition.filterable
        self.dataSourceProperties = filterable?.properties ?? []
//        self.dataSourceProperties = dataSource.properties
        
        var sort = UserDefaults.standard.sort(definition.key)
        if sort.isEmpty {
            sort = filterable?.defaultSort ?? []
        }
        self.sort = sort
        self.sections = !sort.isEmpty ? sort[0].section : false

        if possibleSortProperties.isEmpty {
            selectedProperty = nil
        } else {
            selectedProperty = possibleSortProperties[0]
        }
    }
    
    var firstSortProperty: DataSourceSortParameter? {
        if !sort.isEmpty {
            return sort[0]
        }
        return nil
    }
    
    func removeFirst() {
        let firstSort = sort.remove(at: 0)
        sections = firstSort.section
    }
    
    var secondSortProperty: DataSourceSortParameter? {
        if sort.count > 1 {
            return sort[1]
        }
        return nil
    }
    
    func removeSecond() {
        sort.remove(at: 1)
    }
    
    var possibleSortProperties: [DataSourceProperty] {
        // only allow sorting by two properties
        if sort.count >= 2 {
            return []
        }
        return dataSourceProperties.filter({ property in
            for sortProperty in sort where  property.key == sortProperty.property.key {
                return false
            }
            return true
        })
    }
    
    func addSortProperty() {
        if let selectedProperty = selectedProperty {
            sort.append(DataSourceSortParameter(
                property: selectedProperty,
                ascending: ascending,
                section: sections && sort.isEmpty)
            )
            if possibleSortProperties.isEmpty {
                self.selectedProperty = nil
            } else {
                self.selectedProperty = possibleSortProperties[0]
            }
        }
    }
}
