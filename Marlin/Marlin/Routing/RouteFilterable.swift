//
//  RouteFilterable.swift
//  Marlin
//
//  Created by Daniel Barela on 12/18/23.
//

import Foundation

struct RouteFilterable: Filterable {
    var definition: any DataSourceDefinition {
        DataSourceDefinitions.route.definition
    }

    var defaultFilter: [DataSourceFilterParameter] = []

    var properties: [DataSourceProperty] = []

    var locatableClass: Locatable.Type? = Route.self
}
