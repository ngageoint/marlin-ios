//
//  LightFilterable.swift
//  Marlin
//
//  Created by Daniel Barela on 12/18/23.
//

import Foundation

struct LightFilterable: Filterable {
    var definition: any DataSourceDefinition {
        DataSourceDefinitions.light.definition
    }

    var properties: [DataSourceProperty] = [
        DataSourceProperty(name: "Location", key: #keyPath(Light.mgrs10km), type: .location),
        DataSourceProperty(name: "Latitude", key: #keyPath(Light.latitude), type: .latitude),
        DataSourceProperty(name: "Longitude", key: #keyPath(Light.longitude), type: .longitude),
        DataSourceProperty(name: "Feature Number", key: #keyPath(Light.featureNumber), type: .string),
        DataSourceProperty(
            name: "International Feature Number",
            key: #keyPath(Light.internationalFeature),
            type: .string
        ),
        DataSourceProperty(name: "Name", key: #keyPath(Light.name), type: .string),
        DataSourceProperty(name: "Structure", key: #keyPath(Light.structure), type: .string),
        DataSourceProperty(name: "Focal Plane Elevation (ft)", key: #keyPath(Light.heightFeet), type: .double),
        DataSourceProperty(name: "Focal Plane Elevation (m)", key: #keyPath(Light.heightMeters), type: .double),
        DataSourceProperty(
            name: "Range (nm)",
            key: #keyPath(Light.lightRange),
            type: .double,
            subEntityKey: #keyPath(LightRange.range)
        ),
        DataSourceProperty(name: "Remarks", key: #keyPath(Light.remarks), type: .string),
        DataSourceProperty(name: "Characteristic", key: #keyPath(Light.characteristic), type: .string),
        DataSourceProperty(name: "Signal", key: #keyPath(Light.characteristic), type: .string),
        DataSourceProperty(name: "Notice Number", key: #keyPath(Light.noticeNumber), type: .int),
        DataSourceProperty(name: "Notice Week", key: #keyPath(Light.noticeWeek), type: .string),
        DataSourceProperty(name: "Notice Year", key: #keyPath(Light.noticeYear), type: .string),
        DataSourceProperty(name: "Volume Number", key: #keyPath(Light.volumeNumber), type: .string),
        DataSourceProperty(name: "Preceding Note", key: #keyPath(Light.precedingNote), type: .string),
        DataSourceProperty(name: "Post Note", key: #keyPath(Light.postNote), type: .string),
        DataSourceProperty(name: "Region", key: #keyPath(Light.sectionHeader), type: .string),
        DataSourceProperty(name: "Geopolitical Heading", key: #keyPath(Light.geopoliticalHeading), type: .string),
        DataSourceProperty(name: "Region Heading", key: #keyPath(Light.regionHeading), type: .string),
        DataSourceProperty(name: "Subregion Heading", key: #keyPath(Light.subregionHeading), type: .string),
        DataSourceProperty(name: "Local Heading", key: #keyPath(Light.localHeading), type: .string)
    ]

    var defaultFilter: [DataSourceFilterParameter] = []

    var defaultSort: [DataSourceSortParameter] = [
        DataSourceSortParameter(
            property: DataSourceProperty(
                name: "Region",
                key: #keyPath(Light.sectionHeader),
                type: .string),
            ascending: true),
        DataSourceSortParameter(
            property: DataSourceProperty(
                name: "Feature Number",
                key: #keyPath(Light.featureNumber),
                type: .int),
            ascending: true)
    ]

}
