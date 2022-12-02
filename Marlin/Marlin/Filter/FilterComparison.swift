//
//  FilterComparison.swift
//  Marlin
//
//  Created by Daniel Barela on 12/1/22.
//

import SwiftUI

struct FilterComparison: View {
    @ObservedObject var dataSourcePropertyFilterViewModel: DataSourcePropertyFilterViewModel
//    var property: DataSourceProperty
//    var selectedComparison: DataSourceFilterComparison
    
    var body: some View {
        Group {
            if dataSourcePropertyFilterViewModel.dataSourceProperty.type == DataSourcePropertyType.string {
                Picker("Comparison", selection: $dataSourcePropertyFilterViewModel.selectedComparison) {
                    ForEach(DataSourceFilterComparison.stringSubset()) { comparison in
                        Text(comparison.rawValue).tag(comparison)
                    }
                }
                .scaledToFill()
                .labelsHidden()
                .tint(Color.primaryColorVariant)
            } else if dataSourcePropertyFilterViewModel.dataSourceProperty.type == DataSourcePropertyType.date {
                Picker("Comparison", selection: $dataSourcePropertyFilterViewModel.selectedComparison) {
                    ForEach(DataSourceFilterComparison.dateSubset()) { comparison in
                        Text(comparison.rawValue).tag(comparison)
                    }
                }
                .scaledToFill()
                .labelsHidden()
                .tint(Color.primaryColorVariant)
            } else if dataSourcePropertyFilterViewModel.dataSourceProperty.type == DataSourcePropertyType.enumeration {
                Picker("Comparison", selection: $dataSourcePropertyFilterViewModel.selectedComparison) {
                    ForEach(DataSourceFilterComparison.enumerationSubset()) { comparison in
                        Text(comparison.rawValue).tag(comparison)
                    }
                }
                .scaledToFill()
                .labelsHidden()
                .tint(Color.primaryColorVariant)
            } else if dataSourcePropertyFilterViewModel.dataSourceProperty.type == DataSourcePropertyType.location {
                Picker("Comparison", selection: $dataSourcePropertyFilterViewModel.selectedComparison) {
                    ForEach(DataSourceFilterComparison.locationSubset()) { comparison in
                        Text(comparison.rawValue).tag(comparison)
                    }
                }
                .scaledToFill()
                .labelsHidden()
                .tint(Color.primaryColorVariant)
            } else {
                Picker("Comparison", selection: $dataSourcePropertyFilterViewModel.selectedComparison) {
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
            print("xxx filter comparison appear")
            if dataSourcePropertyFilterViewModel.dataSourceProperty.type == DataSourcePropertyType.string {
                dataSourcePropertyFilterViewModel.selectedComparison = .equals
            } else if dataSourcePropertyFilterViewModel.dataSourceProperty.type == DataSourcePropertyType.date {
                dataSourcePropertyFilterViewModel.selectedComparison = .window
            } else if dataSourcePropertyFilterViewModel.dataSourceProperty.type == DataSourcePropertyType.enumeration {
                dataSourcePropertyFilterViewModel.selectedComparison = .equals
            } else if dataSourcePropertyFilterViewModel.dataSourceProperty.type == DataSourcePropertyType.location {
                dataSourcePropertyFilterViewModel.selectedComparison = .nearMe
            } else {
                dataSourcePropertyFilterViewModel.selectedComparison = .equals
            }
        }
        .onChange(of: dataSourcePropertyFilterViewModel.dataSourceProperty) { newValue in
            print("xxx filter comparison data source property change")
            if newValue.type == DataSourcePropertyType.string {
                dataSourcePropertyFilterViewModel.selectedComparison = .equals
            } else if newValue.type == DataSourcePropertyType.date {
                dataSourcePropertyFilterViewModel.selectedComparison = .window
            } else if newValue.type == DataSourcePropertyType.enumeration {
                dataSourcePropertyFilterViewModel.selectedComparison = .equals
            } else if newValue.type == DataSourcePropertyType.location {
                dataSourcePropertyFilterViewModel.selectedComparison = .nearMe
            } else {
                dataSourcePropertyFilterViewModel.selectedComparison = .equals
            }
        }
    }
}
