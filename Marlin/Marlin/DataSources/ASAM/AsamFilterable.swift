//
//  AsamFilterable.swift
//  Marlin
//
//  Created by Daniel Barela on 12/18/23.
//

import Foundation

struct AsamFilterable: Filterable {
    var definition: any DataSourceDefinition {
        DataSourceDefinitions.asam.definition
    }

    var properties: [DataSourceProperty] = [
        DataSourceProperty(name: "Date", key: #keyPath(Asam.date), type: .date),
        DataSourceProperty(name: "Location", key: #keyPath(Asam.mgrs10km), type: .location),
        DataSourceProperty(name: "Reference", key: #keyPath(Asam.reference), type: .string),
        DataSourceProperty(name: "Latitude", key: #keyPath(Asam.latitude), type: .latitude),
        DataSourceProperty(name: "Longitude", key: #keyPath(Asam.longitude), type: .longitude),
        DataSourceProperty(name: "Navigation Area", key: #keyPath(Asam.navArea), type: .string),
        DataSourceProperty(name: "Subregion", key: #keyPath(Asam.subreg), type: .string),
        DataSourceProperty(name: "Description", key: #keyPath(Asam.asamDescription), type: .string),
        DataSourceProperty(name: "Hostility", key: #keyPath(Asam.hostility), type: .string),
        DataSourceProperty(name: "Victim", key: #keyPath(Asam.victim), type: .string)
    ]

    var defaultFilter: [DataSourceFilterParameter] = [
        DataSourceFilterParameter(
            property: DataSourceProperty(
                name: "Date",
                key: #keyPath(Asam.date),
                type: .date),
            comparison: .window,
            windowUnits: DataSourceWindowUnits.last365Days)
    ]

    var defaultSort: [DataSourceSortParameter] = [
        DataSourceSortParameter(
            property: DataSourceProperty(
                name: "Date",
                key: #keyPath(Asam.date),
                type: .date),
            ascending: false)
    ]
}
