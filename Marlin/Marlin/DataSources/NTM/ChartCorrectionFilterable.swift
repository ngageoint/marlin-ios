//
//  ChartCorrectionFilterable.swift
//  Marlin
//
//  Created by Daniel Barela on 12/18/23.
//

import Foundation

struct ChartCorrectionFilterable: Filterable {
    var definition: any DataSourceDefinition {
        DataSourceDefinitions.chartCorrection.definition
    }

    var properties: [DataSourceProperty] {
        [
            DataSourceProperty(name: "Notice Number", key: "currNoticeNum", type: .int, requiredInFilter: false),
            DataSourceProperty(name: "Location", key: "location", type: .location, requiredInFilter: true)
        ]
    }

    var defaultFilter: [DataSourceFilterParameter] {
        if LocationManager.shared().lastLocation != nil {
            return [
                DataSourceFilterParameter(
                    property: DataSourceProperty(
                        name: "Location",
                        key: "location",
                        type: .location),
                    comparison: .nearMe,
                    valueInt: 2500)
            ]
        } else {
            return [
                DataSourceFilterParameter(
                    property: DataSourceProperty(
                        name: "Location",
                        key: "location",
                        type: .location),
                    comparison: .closeTo,
                    valueInt: 2500,
                    valueLatitude: 0.0,
                    valueLongitude: 0.0)
            ]
        }
    }
}
