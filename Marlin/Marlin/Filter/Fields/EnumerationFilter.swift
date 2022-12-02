//
//  EnumerationFilter.swift
//  Marlin
//
//  Created by Daniel Barela on 12/2/22.
//

import SwiftUI

struct EnumerationFilter: View {
    @ObservedObject var filterViewModel: FilterViewModel
    @ObservedObject var viewModel: DataSourcePropertyFilterViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                FilterPropertyName(filterViewModel: filterViewModel, viewModel: viewModel)
                FilterComparison(dataSourcePropertyFilterViewModel: viewModel)
            }
            if let enumerationValues = viewModel.dataSourceProperty.enumerationValues {
                Picker("Enumeration", selection: $viewModel.valueString) {
                    ForEach(enumerationValues.keys.sorted().map { String($0) }, id: \.self) { key in
                        Text(key).tag(key)
                    }
                }
                .scaledToFill()
                .labelsHidden()
                .tint(Color.primaryColorVariant)
                .onAppear {
                    let sorted = enumerationValues.keys.sorted()
                    viewModel.valueString = sorted.first ?? ""
                }
            }
        }
    }
}
