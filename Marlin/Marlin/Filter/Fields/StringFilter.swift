//
//  StringFilter.swift
//  Marlin
//
//  Created by Daniel Barela on 12/2/22.
//

import SwiftUI
import SwiftUIIntrospect

struct StringFilter: View {
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
                TextField(viewModel.dataSourceProperty.name, text: $viewModel.valueString)
                    .introspect(.textField, on: .iOS(.v16, .v17)) { field in
                        field.smartDashesType = .no
                    }
                    .keyboardType(.default)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
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
                }
            }
        }
    }
}
