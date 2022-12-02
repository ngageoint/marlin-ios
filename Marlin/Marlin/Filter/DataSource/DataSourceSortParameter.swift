//
//  DataSourceSortParameter.swift
//  Marlin
//
//  Created by Daniel Barela on 12/2/22.
//

import Foundation

struct DataSourceSortParameter: Identifiable, Hashable, Codable {
    static func == (lhs: DataSourceSortParameter, rhs: DataSourceSortParameter) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id = UUID()
    
    let property: DataSourceProperty
    let ascending: Bool
    let section: Bool
    
    init(property: DataSourceProperty, ascending: Bool) {
        self.property = property
        self.ascending = ascending
        self.section = false
    }
    
    init(property: DataSourceProperty, ascending: Bool, section: Bool) {
        self.property = property
        self.ascending = ascending
        self.section = section
    }
    
    func toNSSortDescriptor() -> NSSortDescriptor {
        return NSSortDescriptor(key: property.key, ascending: ascending)
    }
}
