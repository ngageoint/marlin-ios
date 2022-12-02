//
//  DataSourceSort.swift
//  Marlin
//
//  Created by Daniel Barela on 12/2/22.
//

import Foundation

struct DataSourceSort: Identifiable, Hashable, Codable {
    static func == (lhs: DataSourceSort, rhs: DataSourceSort) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id = UUID()
    
    var sortProperties: [DataSourceSortParameter] = []
    
    func toNSSortDescriptors() -> [NSSortDescriptor] {
        var descriptors: [NSSortDescriptor] = []
        for sortProperty in sortProperties {
            descriptors.append(sortProperty.toNSSortDescriptor())
        }
        return descriptors
    }
}
