//
//  FilterComparison.swift
//  Marlin
//
//  Created by Daniel Barela on 12/1/22.
//

import SwiftUI

struct FilterComparison: View {
    @Binding var property: DataSourceProperty
    @Binding var selectedComparison: DataSourceFilterComparison
    
    var body: some View {
        Group {
            if property.type == DataSourcePropertyType.string {
                Picker("Comparison", selection: $selectedComparison) {
                    ForEach(DataSourceFilterComparison.stringSubset()) { comparison in
                        Text(comparison.rawValue).tag(comparison)
                    }
                }
                .scaledToFill()
                .labelsHidden()
                .tint(Color.primaryColorVariant)
            } else if property.type == DataSourcePropertyType.date {
                Picker("Comparison", selection: $selectedComparison) {
                    ForEach(DataSourceFilterComparison.dateSubset()) { comparison in
                        Text(comparison.rawValue).tag(comparison)
                    }
                }
                .scaledToFill()
                .labelsHidden()
                .tint(Color.primaryColorVariant)
            } else if property.type == DataSourcePropertyType.enumeration {
                Picker("Comparison", selection: $selectedComparison) {
                    ForEach(DataSourceFilterComparison.enumerationSubset()) { comparison in
                        Text(comparison.rawValue).tag(comparison)
                    }
                }
                .scaledToFill()
                .labelsHidden()
                .tint(Color.primaryColorVariant)
            } else if property.type == DataSourcePropertyType.location {
                Picker("Comparison", selection: $selectedComparison) {
                    ForEach(DataSourceFilterComparison.locationSubset()) { comparison in
                        Text(comparison.rawValue).tag(comparison)
                    }
                }
                .scaledToFill()
                .labelsHidden()
                .tint(Color.primaryColorVariant)
            } else {
                Picker("Comparison", selection: $selectedComparison) {
                    ForEach(DataSourceFilterComparison.numberSubset()) { comparison in
                        Text(comparison.rawValue).tag(comparison)
                    }
                }
                .scaledToFill()
                .labelsHidden()
                .tint(Color.primaryColorVariant)
            }
        }
        .onAppear {
            if property.type == DataSourcePropertyType.string {
                selectedComparison = .equals
            } else if property.type == DataSourcePropertyType.date {
                selectedComparison = .window
            } else if property.type == DataSourcePropertyType.enumeration {
                selectedComparison = .equals
            } else if property.type == DataSourcePropertyType.location {
                selectedComparison = .nearMe
            } else {
                selectedComparison = .equals
            }
        }
        .onChange(of: property) { newValue in
            if newValue.type == DataSourcePropertyType.string {
                selectedComparison = .equals
            } else if newValue.type == DataSourcePropertyType.date {
                selectedComparison = .window
            } else if newValue.type == DataSourcePropertyType.enumeration {
                selectedComparison = .equals
            } else if newValue.type == DataSourcePropertyType.location {
                selectedComparison = .nearMe
            } else {
                selectedComparison = .equals
            }
        }
    }
}
