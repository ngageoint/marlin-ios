//
//  RadioBeaconFilterable.swift
//  Marlin
//
//  Created by Daniel Barela on 12/18/23.
//

import Foundation

struct RadioBeaconFilterable: Filterable {
    var definition: any DataSourceDefinition {
        DataSources.radioBeacon
    }

    var properties: [DataSourceProperty] = [
        DataSourceProperty(name: "Location", key: #keyPath(RadioBeacon.mgrs10km), type: .location),
        DataSourceProperty(name: "Latitude", key: #keyPath(RadioBeacon.latitude), type: .latitude),
        DataSourceProperty(name: "Longitude", key: #keyPath(RadioBeacon.longitude), type: .longitude),
        DataSourceProperty(name: "Feature Number", key: #keyPath(RadioBeacon.featureNumber), type: .int),
        DataSourceProperty(name: "Geopolitical Heading", key: #keyPath(RadioBeacon.geopoliticalHeading), type: .string),
        DataSourceProperty(name: "Name", key: #keyPath(RadioBeacon.name), type: .string),
        DataSourceProperty(name: "Range (nm)", key: #keyPath(RadioBeacon.range), type: .int),
        DataSourceProperty(name: "Frequency (kHz)", key: #keyPath(RadioBeacon.frequency), type: .string),
        DataSourceProperty(name: "Station Remark", key: #keyPath(RadioBeacon.stationRemark), type: .string),
        DataSourceProperty(name: "Characteristic", key: #keyPath(RadioBeacon.characteristic), type: .string),
        DataSourceProperty(name: "Sequence Text", key: #keyPath(RadioBeacon.sequenceText), type: .string),
        DataSourceProperty(name: "Notice Number", key: #keyPath(RadioBeacon.noticeNumber), type: .int),
        DataSourceProperty(name: "Notice Week", key: #keyPath(RadioBeacon.noticeWeek), type: .string),
        DataSourceProperty(name: "Notice Year", key: #keyPath(RadioBeacon.noticeYear), type: .string),
        DataSourceProperty(name: "Volume Number", key: #keyPath(RadioBeacon.volumeNumber), type: .string),
        DataSourceProperty(name: "Preceding Note", key: #keyPath(RadioBeacon.precedingNote), type: .string),
        DataSourceProperty(name: "Post Note", key: #keyPath(RadioBeacon.postNote), type: .string),
        DataSourceProperty(name: "Aid Type", key: #keyPath(RadioBeacon.aidType), type: .string),
        DataSourceProperty(name: "Region Heading", key: #keyPath(RadioBeacon.regionHeading), type: .string),
        DataSourceProperty(name: "Remove From List", key: #keyPath(RadioBeacon.removeFromList), type: .string),
        DataSourceProperty(name: "Delete Flag", key: #keyPath(RadioBeacon.deleteFlag), type: .string)
    ]

    var defaultFilter: [DataSourceFilterParameter] = []

//    var locatableClass: Locatable.Type? = RadioBeacon.self
}
