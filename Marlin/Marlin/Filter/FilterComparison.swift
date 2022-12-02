//
//  FilterComparison.swift
//  Marlin
//
//  Created by Daniel Barela on 12/1/22.
//

import SwiftUI

struct FilterComparison: View {
    @ObservedObject var dataSourcePropertyFilterViewModel: DataSourcePropertyFilterViewModel
    
    var body: some View {
        Group {
            Picker("Comparison", selection: $dataSourcePropertyFilterViewModel.selectedComparison) {
                ForEach(dataSourcePropertyFilterViewModel.dataSourceProperty.type.comparisons()) { comparison in
                    Text(comparison.rawValue).tag(comparison)
                }
            }
            .scaledToFill()
            .labelsHidden()
            .tint(Color.primaryColorVariant)
        }
        .onAppear {
            dataSourcePropertyFilterViewModel.selectedComparison = dataSourcePropertyFilterViewModel.dataSourceProperty.type.defaultComparison()
        }
        .onChange(of: dataSourcePropertyFilterViewModel.dataSourceProperty) { newValue in
            dataSourcePropertyFilterViewModel.selectedComparison = newValue.type.defaultComparison()
        }
    }
}
