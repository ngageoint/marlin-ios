//
//  StringFilter.swift
//  Marlin
//
//  Created by Daniel Barela on 12/2/22.
//

import SwiftUI

struct StringFilter: View {
    @ObservedObject var filterViewModel: FilterViewModel
    @ObservedObject var viewModel: DataSourcePropertyFilterViewModel
    @FocusState var isInputActive: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            FilterPropertyName(filterViewModel: filterViewModel, viewModel: viewModel)
            FilterComparison(dataSourcePropertyFilterViewModel: viewModel)
            VStack(alignment: .leading, spacing: 0) {
                TextField(viewModel.dataSourceProperty.name, text: $viewModel.valueString)
                    .keyboardType(.default)
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
                if let validationText = viewModel.validationText {
                    Text(validationText)
                        .overline()
                        .padding(.leading, 8)
                }
            }
        }
    }
}
