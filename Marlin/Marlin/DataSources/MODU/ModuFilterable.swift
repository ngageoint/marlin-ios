//
//  ModuFilterable.swift
//  Marlin
//
//  Created by Daniel Barela on 12/18/23.
//

import Foundation

struct ModuFilterable: Filterable {
    var definition: any DataSourceDefinition {
        DataSourceDefinitions.modu.definition
    }

    var properties: [DataSourceProperty] = [
        DataSourceProperty(name: "Location", key: #keyPath(Modu.mgrs10km), type: .location),
        DataSourceProperty(name: "Subregion", key: #keyPath(Modu.subregion), type: .int),
        DataSourceProperty(name: "Region", key: #keyPath(Modu.region), type: .int),
        DataSourceProperty(name: "Longitude", key: #keyPath(Modu.longitude), type: .longitude),
        DataSourceProperty(name: "Latitude", key: #keyPath(Modu.latitude), type: .latitude),
        DataSourceProperty(name: "Distance", key: #keyPath(Modu.distance), type: .double),
        DataSourceProperty(name: "Special Status", key: #keyPath(Modu.specialStatus), type: .string),
        DataSourceProperty(name: "Rig Status", key: #keyPath(Modu.rigStatus), type: .string),
        DataSourceProperty(name: "Nav Area", key: #keyPath(Modu.navArea), type: .string),
        DataSourceProperty(name: "Name", key: #keyPath(Modu.name), type: .string),
        DataSourceProperty(name: "Date", key: #keyPath(Modu.date), type: .date)
    ]

    var defaultFilter: [DataSourceFilterParameter] = []

    var locatableClass: Locatable.Type? = Modu.self
}
