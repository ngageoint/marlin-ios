//
//  NoticeToMarinersFilterable.swift
//  Marlin
//
//  Created by Daniel Barela on 12/18/23.
//

import Foundation

struct NoticeToMarinersFilterable: Filterable {
    var definition: any DataSourceDefinition {
        DataSourceDefinitions.noticeToMariners.definition
    }

    var properties: [DataSourceProperty] {
        return []
    }

    var defaultFilter: [DataSourceFilterParameter] = []

    var defaultSort: [DataSourceSortParameter] = [
        DataSourceSortParameter(
            property: DataSourceProperty(
                name: "Notice Number",
                key: #keyPath(NoticeToMariners.noticeNumber),
                type: .int),
            ascending: false,
            section: true),
        DataSourceSortParameter(
            property: DataSourceProperty(
                name: "Full Publication",
                key: #keyPath(NoticeToMariners.isFullPublication),
                type: .int),
            ascending: false,
            section: false),
        DataSourceSortParameter(
            property: DataSourceProperty(
                name: "Section Order",
                key: #keyPath(NoticeToMariners.sectionOrder),
                type: .int),
            ascending: true,
            section: false)
    ]
}
