//
//  FilterPropertyAndComparison.swift
//  Marlin
//
//  Created by Daniel Barela on 12/2/22.
//

import SwiftUI

struct FilterPropertyName: View {
    @ObservedObject var filterViewModel: FilterViewModel
    @ObservedObject var viewModel: DataSourcePropertyFilterViewModel
    
    var body: some View {
        if !viewModel.isStaticProperty, let dataSource = filterViewModel.dataSource, dataSource.properties.count > 1 {
            HStack {
                Picker("Property", selection: $viewModel.dataSourceProperty) {
                    let dataSourceProperties = dataSource.properties
                    ForEach(dataSourceProperties) { property in
                        Text(property.name).tag(property)
                    }
                }
                .scaledToFill()
                .labelsHidden()
                .tint(Color.primaryColorVariant)
            }
        } else {
            HStack {
                Text(viewModel.dataSourceProperty.name).primary()
                    .padding(.leading, 8)
            }
        }
    }
}
