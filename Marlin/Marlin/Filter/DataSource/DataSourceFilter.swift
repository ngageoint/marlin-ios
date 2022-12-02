//
//  DataSourceFilter.swift
//  Marlin
//
//  Created by Daniel Barela on 12/2/22.
//

import Foundation

class DataSourceFilter: Identifiable {
    let id = UUID()
    let dataSource: any DataSource.Type
    var filters: [DataSourceFilterParameter] = []
    
    init(dataSource: any DataSource.Type, filters: [DataSourceFilterParameter] = []) {
        self.dataSource = dataSource
        self.filters = filters
    }
    
    func addFilter(_ filter: DataSourceFilterParameter) {
        self.filters.append(filter)
        print("there are now this many filters \(self.filters)")
    }
}
