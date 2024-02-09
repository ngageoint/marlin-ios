//
//  ElectronicPublicationFilterable.swift
//  Marlin
//
//  Created by Daniel Barela on 12/18/23.
//

import Foundation

struct ElectronicPublicationFilterable: Filterable {
    var definition: any DataSourceDefinition {
        DataSourceDefinitions.epub.definition
    }

    var properties: [DataSourceProperty] = [
        DataSourceProperty(
            name: "Type",
            key: #keyPath(ElectronicPublication.pubTypeId),
            type: .enumeration,
            enumerationValues: PublicationTypeEnum.keyValueMap),
        DataSourceProperty(
            name: "Display Name",
            key: #keyPath(ElectronicPublication.pubDownloadDisplayName),
            type: .string)
    ]

    var defaultSort: [DataSourceSortParameter] = [
        DataSourceSortParameter(
            property: DataSourceProperty(
                name: "Type",
                key: #keyPath(ElectronicPublication.pubTypeId),
                type: .int),
            ascending: true,
            section: true)
    ]

    var defaultFilter: [DataSourceFilterParameter] = []

}
