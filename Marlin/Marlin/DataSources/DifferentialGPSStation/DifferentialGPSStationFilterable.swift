//
//  DifferentialGPSStationFilterable.swift
//  Marlin
//
//  Created by Daniel Barela on 12/18/23.
//

import Foundation

struct DifferentialGPSStationFilterable: Filterable {
    var definition: any DataSourceDefinition {
        DataSourceDefinitions.dgps.definition
    }

    var properties: [DataSourceProperty] = [
        DataSourceProperty(name: "Location", key: #keyPath(DifferentialGPSStation.mgrs10km), type: .location),
        DataSourceProperty(name: "Latitude", key: #keyPath(DifferentialGPSStation.latitude), type: .latitude),
        DataSourceProperty(name: "Longitude", key: #keyPath(DifferentialGPSStation.longitude), type: .longitude),
        DataSourceProperty(name: "Number", key: #keyPath(DifferentialGPSStation.featureNumber), type: .int),
        DataSourceProperty(name: "Name", key: #keyPath(DifferentialGPSStation.name), type: .string),
        DataSourceProperty(
            name: "Geopolitical Heading",
            key: #keyPath(DifferentialGPSStation.geopoliticalHeading),
            type: .string),
        DataSourceProperty(name: "Station ID", key: #keyPath(DifferentialGPSStation.stationID), type: .int),
        DataSourceProperty(name: "Range (nmi)", key: #keyPath(DifferentialGPSStation.range), type: .int),
        DataSourceProperty(name: "Frequency (kHz)", key: #keyPath(DifferentialGPSStation.frequency), type: .int),
        DataSourceProperty(name: "Transfer Rate", key: #keyPath(DifferentialGPSStation.transferRate), type: .int),
        DataSourceProperty(name: "Remarks", key: #keyPath(DifferentialGPSStation.remarks), type: .string),
        DataSourceProperty(name: "Notice Number", key: #keyPath(DifferentialGPSStation.noticeNumber), type: .int),
        DataSourceProperty(name: "Notice Week", key: #keyPath(DifferentialGPSStation.noticeWeek), type: .string),
        DataSourceProperty(name: "Notice Year", key: #keyPath(DifferentialGPSStation.noticeYear), type: .string),
        DataSourceProperty(name: "Volume Number", key: #keyPath(DifferentialGPSStation.volumeNumber), type: .string),
        DataSourceProperty(
            name: "Preceding Note",
            key: #keyPath(DifferentialGPSStation.precedingNote),
            type: .string),
        DataSourceProperty(name: "Post Note", key: #keyPath(DifferentialGPSStation.postNote), type: .string)
    ]

    var defaultFilter: [DataSourceFilterParameter] = []

    var locatableClass: Locatable.Type? = DifferentialGPSStation.self
}
