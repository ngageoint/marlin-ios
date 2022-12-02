//
//  DataSourcePropertyFilterView.swift
//  Marlin
//
//  Created by Daniel Barela on 12/1/22.
//

import SwiftUI
import Combine

struct DataSourcePropertyFilterView: View {
    @ObservedObject var locationManager: LocationManager = LocationManager.shared
    
    var filterViewModel: FilterViewModel
    var staticProperty: DataSourceProperty?
    @ObservedObject var viewModel: DataSourcePropertyFilterViewModel
    
    init(dataSourceProperty: DataSourceProperty? = nil, filterViewModel: FilterViewModel) {
        self.staticProperty = dataSourceProperty
        var prop = dataSourceProperty ?? DataSourceProperty(name: "", key: "", type: .string)
        if dataSourceProperty == nil && !filterViewModel.dataSource.properties.isEmpty {
            prop = filterViewModel.dataSource.properties[0]
        }
        self.filterViewModel = filterViewModel

        viewModel = DataSourcePropertyFilterViewModel(dataSourceProperty: prop)
    }
    
    var body: some View {
        HStack {
            if viewModel.dataSourceProperty.type == .double || viewModel.dataSourceProperty.type == .float {
                HStack(spacing: 0) {
                    propertyNameAndComparison()
                    FilterComparison(dataSourcePropertyFilterViewModel: viewModel)
                    VStack(alignment: .leading, spacing: 0) {
                        TextField(viewModel.dataSourceProperty.name, value: $viewModel.valueDouble, format: .number)
                            .keyboardType(.decimalPad)
                            .underlineTextField()
                            .onTapGesture(perform: {
                                viewModel.startValidating = true
                            })
                        if let validationText = viewModel.validationText {
                            Text(validationText)
                                .overline()
                                .padding(.leading, 8)
                        }
                    }
                }
            } else if viewModel.dataSourceProperty.type == .int {
                HStack(spacing: 0) {
                    propertyNameAndComparison()
                    FilterComparison(dataSourcePropertyFilterViewModel: viewModel)
                    VStack(alignment: .leading, spacing: 0) {
                        TextField(viewModel.dataSourceProperty.name, value: $viewModel.valueInt, format: .number)
                            .keyboardType(.numberPad)
                            .underlineTextField()
                            .onTapGesture(perform: {
                                viewModel.startValidating = true
                            })
                        if let validationText = viewModel.validationText {
                            Text(validationText)
                                .overline()
                                .padding(.leading, 8)
                        }
                    }
                }
            } else if viewModel.dataSourceProperty.type == .date {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 0) {
                        propertyNameAndComparison()
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
            } else if viewModel.dataSourceProperty.type == .enumeration {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 0) {
                        propertyNameAndComparison()
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
            } else if viewModel.dataSourceProperty.type == .location {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        propertyNameAndComparison()
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
            } else if viewModel.dataSourceProperty.type == .latitude || viewModel.dataSourceProperty.type == .longitude {
                HStack(spacing: 0) {
                    propertyNameAndComparison()
                    FilterComparison(dataSourcePropertyFilterViewModel: viewModel)
                    VStack(alignment: .leading, spacing: 0) {
                        TextField(viewModel.dataSourceProperty.name, text: $viewModel.valueString)
                            .keyboardType(.default)
                            .underlineTextField()
                            .onTapGesture(perform: {
                                viewModel.startValidating = true
                            })
                        if let validationText = viewModel.validationText {
                            Text(validationText)
                                .overline()
                                .padding(.leading, 8)
                        }
                    }
                }
            } else {
                HStack(spacing: 0) {
                    propertyNameAndComparison()
                    FilterComparison(dataSourcePropertyFilterViewModel: viewModel)
                    VStack(alignment: .leading, spacing: 0) {
                        TextField(viewModel.dataSourceProperty.name, text: $viewModel.valueString)
                            .keyboardType(.default)
                            .underlineTextField()
                            .onTapGesture(perform: {
                                viewModel.startValidating = true
                            })
                        if let validationText = viewModel.validationText {
                            Text(validationText)
                                .overline()
                                .padding(.leading, 8)
                        }
                    }
                }
            }
            Spacer()
            Button {
                filterViewModel.addFilterParameter(viewModel: viewModel)
            } label: {
                Image(systemName: "plus.circle.fill")
                    .tint(Color.green)
            }
            .disabled(!viewModel.isValid)
        }
    }
    
    @ViewBuilder
    func propertyNameAndComparison() -> some View {
        if staticProperty == nil, filterViewModel.dataSource.properties.count > 1 {
            HStack {
                Picker("Property", selection: $viewModel.dataSourceProperty) {
                    if let dataSourceProperties = filterViewModel.dataSource.properties {
                        ForEach(dataSourceProperties) { property in
                            Text(property.name).tag(property)
                        }
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
