//
//  DoubleFilter.swift
//  Marlin
//
//  Created by Daniel Barela on 12/2/22.
//

import SwiftUI

struct DoubleFilter: View {
    @ObservedObject var filterViewModel: FilterViewModel
    @ObservedObject var viewModel: DataSourcePropertyFilterViewModel
    @FocusState var isInputActive: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                FilterPropertyName(filterViewModel: filterViewModel, viewModel: viewModel)
                FilterComparison(dataSourcePropertyFilterViewModel: viewModel)
            }
            VStack(alignment: .leading, spacing: 0) {
                TextField(
                    viewModel.dataSourceProperty.name,
                    value: $viewModel.valueDouble,
                    format: .number.grouping(.never)
                )
                .keyboardType(.decimalPad)
                .underlineTextField()
                .onTapGesture(perform: {
                    viewModel.startValidating = true
                })
                .focused($isInputActive)
                .toolbar {
                    ToolbarItem(placement: .keyboard) {
                        Spacer()
                    }
                    ToolbarItem(placement: .keyboard) {
                        Button("Done") {
                            isInputActive = false
                        }
                        .tint(Color.primaryColorVariant)
                    }
                }
                .accessibilityElement()
                .accessibilityLabel("\(viewModel.dataSourceProperty.name) input")
                
                if let validationText = viewModel.validationText {
                    Text(validationText)
                        .overline()
                        .padding(.leading, 8)
                        .accessibilityElement()
                        .accessibilityLabel(validationText)
                }
            }
        }
    }
}
