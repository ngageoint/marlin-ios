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
}
