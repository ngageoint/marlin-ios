//
//  BooleanFilter.swift
//  Marlin
//
//  Created by Daniel Barela on 12/2/22.
//

import SwiftUI

struct BooleanFilter: View {
    @ObservedObject var filterViewModel: FilterViewModel
    @ObservedObject var viewModel: DataSourcePropertyFilterViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            FilterPropertyName(filterViewModel: filterViewModel, viewModel: viewModel)
            FilterComparison(dataSourcePropertyFilterViewModel: viewModel)
            Picker("Boolean", selection: $viewModel.valueInt) {
                Text("True").tag(1)
                Text("False").tag(0)
            }
            .scaledToFill()
            .labelsHidden()
            .tint(Color.primaryColorVariant)
            .accessibilityElement()
            .accessibilityLabel("\(viewModel.dataSourceProperty.name) input")
        }
    }
}
