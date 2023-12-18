//
//  CommonFilterable.swift
//  Marlin
//
//  Created by Daniel Barela on 12/18/23.
//

import Foundation

struct CommonFilterable: Filterable {
    var definition: any DataSourceDefinition {
        DataSourceDefinitions.common.definition
    }

    var properties: [DataSourceProperty] = [
        DataSourceProperty(name: "Location", key: #keyPath(CommonDataSource.coordinate), type: .location)
    ]

    var defaultFilter: [DataSourceFilterParameter] = []
}
