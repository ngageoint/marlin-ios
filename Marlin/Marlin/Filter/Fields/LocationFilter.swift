//
//  LocationFilter.swift
//  Marlin
//
//  Created by Daniel Barela on 12/2/22.
//

import SwiftUI

struct LocationFilter: View {
    @ObservedObject var locationManager: LocationManager = LocationManager.shared

    @ObservedObject var filterViewModel: FilterViewModel
    @ObservedObject var viewModel: DataSourcePropertyFilterViewModel
    @FocusState var isInputActive: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                FilterPropertyName(filterViewModel: filterViewModel, viewModel: viewModel)
                FilterComparison(dataSourcePropertyFilterViewModel: viewModel)
            }
            if viewModel.selectedComparison == .closeTo {
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Latitude")
                            .overline()
                            .padding(.leading, 8)
                            .padding(.bottom, -16)
                        TextField("Latitude", text: $viewModel.valueLatitudeString)
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
                                }
                            }
                        if let validationLatitudeText = viewModel.validationLatitudeText {
                            Text(validationLatitudeText)
                                .overline()
                                .padding(.leading, 8)
                        }
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Longitude")
                            .overline()
                            .padding(.leading, 8)
                            .padding(.bottom, -16)
                        TextField("Longitude", text: $viewModel.valueLongitudeString)
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
                                }
                            }
                        if let validationLongitudeText = viewModel.validationLongitudeText {
                            Text(validationLongitudeText)
                                .overline()
                                .padding(.leading, 8)
                        }
                    }
                }
                .padding(.leading, 4)
            } else if viewModel.selectedComparison == .nearMe {
                if locationManager.lastLocation == nil {
                    Text("No current location")
                        .secondary()
                }
            }
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Distance")
                        .overline()
                        .padding(.leading, 8)
                        .padding(.bottom, -16)
                    TextField("Nautical Miles", value: $viewModel.valueInt, format: .number)
                        .keyboardType(.numberPad)
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
                            }
                        }
                    if let validationText = viewModel.validationText {
                        Text(validationText)
                            .overline()
                            .padding(.leading, 8)
                    }
                }
                Text("nm")
                    .overline()
                    .padding(.bottom, 16)
            }
            .padding(.leading, 4)
        }
    }
}
