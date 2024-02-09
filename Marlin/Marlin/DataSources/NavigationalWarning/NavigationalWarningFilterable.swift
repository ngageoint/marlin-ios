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

    var defaultSort: [DataSourceSortParameter] = [
        DataSourceSortParameter(
            property: DataSourceProperty(
                name: "Navigational Area",
                key: "navArea",
                type: .string),
            ascending: false),
        DataSourceSortParameter(
            property: DataSourceProperty(
                name: "Issue Date",
                key: "issueDate",
                type: .date),
            ascending: false)
    ]

    var locatableClass: Locatable.Type? = NavigationalWarning.self
}
