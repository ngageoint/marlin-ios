//
//  FilterParameterSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 12/1/22.
//

import SwiftUI

struct FilterParameterSummaryView: View {
    var filter: DataSourceFilterParameter
    var dataSource: DataSource.Type
    
    var body: some View {
        if filter.property.type == .date {
            if filter.comparison == .window, let windowUnits = filter.windowUnits {
                Text("**\(filter.property.name)** within the **\(windowUnits.rawValue)**")
                    .primary()
            } else if let dateValue = filter.valueDate {
                Text("**\(filter.property.name)** \(filter.comparison.rawValue) **\(dataSource.dateFormatter.string(from: dateValue))**")
                    .primary()
            }
        } else if filter.property.type == .enumeration {
            Text("**\(filter.property.name)** \(filter.comparison.rawValue) **\(filter.valueToString())**")
                .primary()
        }  else if filter.property.type == .location {
            if filter.comparison == .nearMe {
                Text("**\(filter.property.name)** within **\(filter.valueInt ?? 0)nm** of my location")
                    .primary()
            } else {
                Text("**\(filter.property.name)** within **\(filter.valueInt ?? 0)nm** of **\(filter.valueLatitude ?? 0.0)°, \(filter.valueLongitude ?? 0.0)°**")
                    .primary()
            }
        } else if filter.property.type == .latitude {
            Text("**\(filter.property.name)** \(filter.comparison.rawValue) **\(filter.valueString ?? "")**")
                .primary()
        } else if filter.property.type == .longitude {
            Text("**\(filter.property.name)** \(filter.comparison.rawValue) **\(filter.valueString ?? "")°**")
                .primary()
        }  else {
            Text("**\(filter.property.name)** \(filter.comparison.rawValue) **\(filter.valueToString())**")
                .primary()
        }
    }
}
