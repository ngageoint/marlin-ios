//
//  NavigationalWarningFilterable.swift
//  Marlin
//
//  Created by Daniel Barela on 12/18/23.
//

import Foundation

struct NavigationalWarningFilterable: Filterable {
    var definition: any DataSourceDefinition {
        DataSourceDefinitions.navWarning.definition
    }

    var defaultFilter: [DataSourceFilterParameter] = []

    var properties: [DataSourceProperty] = []

    var locatableClass: Locatable.Type? = NavigationalWarning.self
}
