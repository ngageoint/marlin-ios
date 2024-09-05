//
//  UserPlaceFilterable.swift
//  Marlin
//
//  Created by Daniel Barela on 2/26/24.
//

import Foundation

struct UserPlaceFilterable: Filterable {
    var definition: any DataSourceDefinition {
        DataSources.userPlace
    }

    var properties: [DataSourceProperty] = [
        DataSourceProperty(name: "Name", key: #keyPath(UserPlace.name), type: .string),
        DataSourceProperty(name: "Date", key: #keyPath(UserPlace.date), type: .date),

        DataSourceProperty(name: "Latitude", key: #keyPath(UserPlace.latitude), type: .latitude),
        DataSourceProperty(name: "Longitude", key: #keyPath(UserPlace.longitude), type: .longitude),
        DataSourceProperty(name: "Location", key: #keyPath(UserPlace.latitude), type: .location)
    ]

    var defaultFilter: [DataSourceFilterParameter] = []

    var defaultSort: [DataSourceSortParameter] = [
        DataSourceSortParameter(
            property: DataSourceProperty(
                name: "Date",
                key: #keyPath(UserPlace.date),
                type: .date),
            ascending: false)
    ]
}
