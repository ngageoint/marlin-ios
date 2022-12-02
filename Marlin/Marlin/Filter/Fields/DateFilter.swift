//
//  DateFilter.swift
//  Marlin
//
//  Created by Daniel Barela on 12/2/22.
//

import SwiftUI

struct DateFilter: View {
    @ObservedObject var filterViewModel: FilterViewModel
    @ObservedObject var viewModel: DataSourcePropertyFilterViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                FilterPropertyName(filterViewModel: filterViewModel, viewModel: viewModel)
                FilterComparison(dataSourcePropertyFilterViewModel: viewModel)
            }
            if viewModel.selectedComparison == .window {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Dynamic Date Window")
                            .overline()
                            .padding(.leading, 12)
                        Picker("Window", selection: $viewModel.windowUnits) {
                            ForEach(DataSourceWindowUnits.allCases) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                        .clipped()
                        .scaledToFill()
                        .labelsHidden()
                        .tint(Color.primaryColorVariant)
                        .onAppear {
                            viewModel.windowUnits = .last30Days
                        }
                    }
                }
            } else {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Date")
                            .overline()
                            .padding(.leading, 12)
                        DatePicker(
                            viewModel.dataSourceProperty.name,
                            selection: $viewModel.valueDate,
                            displayedComponents: [.date]
                        )
                        .accentColor(Color.primaryColorVariant)
                        .padding(.leading, 8)
                        .labelsHidden()
                    }
                }
            }
        }
    }
}
