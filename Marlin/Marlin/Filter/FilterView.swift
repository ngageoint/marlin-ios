//
//  FilterView.swift
//  Marlin
//
//  Created by Daniel Barela on 9/20/22.
//

import SwiftUI
import CoreLocation

extension View {
    func underlineTextField() -> some View {
        self
            .padding(.vertical, 10)
            .overlay(Rectangle().frame(height: 2).padding(.top, 35))
            .foregroundColor(Color.primaryColorVariant)
            .padding(10)
    }
}

struct FilterView: View {
    @ObservedObject var locationManager: LocationManager = LocationManager.shared
    
    @State var filters: [DataSourceFilterParameter] {
        didSet {
            UserDefaults.standard.setFilter(dataSource.key, filter: filters)
        }
    }
    
    var dataSourceProperties: [DataSourceProperty]
    var dataSource: any DataSource.Type
    
    @State private var selectedComparison: DataSourceFilterComparison = .equals
    @State private var selectedProperty: DataSourceProperty
    @State private var selectedEnumeration: String = ""
    @State private var valueString: String = ""
    @State private var valueDate: Date = Date()
    @State private var valueInt: Int = 0
    @State private var valueDouble: Double = 0.0
    @State private var valueLatitude: Double = 0.0
    @State private var valueLongitude: Double = 0.0
    @State private var windowUnits: DataSourceWindowUnits = .last30Days
    
    @State private var doubleFormatter: NumberFormatter = {
        var nf = NumberFormatter()
        nf.numberStyle = .decimal
        return nf
    }()
    
    @State private var intFormatter: NumberFormatter = {
        var nf = NumberFormatter()
        nf.numberStyle = .none
        return nf
    }()
    
    init(dataSource: any DataSource.Type) {
        self.dataSource = dataSource
        self.dataSourceProperties = dataSource.properties
        self._filters = State(initialValue: UserDefaults.standard.filter(dataSource))
        self._selectedProperty = State(initialValue: dataSourceProperties[0])
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(Array(filters.enumerated()), id: \.element) { index, filter in
                HStack {
                    if filter.property.type == .date {
                        if filter.comparison == .window, let windowUnits = filter.windowUnits {
                            Text("**\(filter.property.name)** within the **\(windowUnits.rawValue)**")
                        }
                        if let dateValue = filter.valueDate {
                            Text("**\(filter.property.name)** \(filter.comparison.rawValue) **\(dataSource.dateFormatter.string(from: dateValue))**")
                                .primary()
                        }
                    } else if filter.property.type == .enumeration {
                        Text("**\(filter.property.name)** \(filter.comparison.rawValue) **\(filter.valueToString())**")
                            .primary()
                    }  else if filter.property.type == .location {
                        if filter.comparison == .nearMe {
                            Text("**\(filter.property.name)** within **\(filter.valueInt ?? 0)nm** of my location")
                                .primary()
                        } else {
                            Text("**\(filter.property.name)** within **\(filter.valueInt ?? 0)nm** of **\(filter.valueLatitude ?? 0.0), \(filter.valueLongitude ?? 0.0)**")
                                .primary()
                        }
                    } else {
                        Text("**\(filter.property.name)** \(filter.comparison.rawValue) **\(filter.valueToString())**")
                            .primary()
                    }
                    Spacer()
                    Button {
                        filters.remove(at: index)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .tint(Color.red)
                    }
                }
                .padding([.top, .bottom], 8)
                Divider()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    inputType(selectedProperty: selectedProperty)
                }
                Spacer()
                Button {
                    if selectedProperty.type == .date {
                        if selectedComparison == .window {
                            filters.append(DataSourceFilterParameter(property: selectedProperty, comparison: selectedComparison, windowUnits: windowUnits))
                        } else {
                            filters.append(DataSourceFilterParameter(property: selectedProperty, comparison: selectedComparison, valueDate: valueDate))
                        }
                    } else if selectedProperty.type == .int {
                        filters.append(DataSourceFilterParameter(property: selectedProperty, comparison: selectedComparison, valueInt: valueInt))
                    } else if selectedProperty.type == .float || selectedProperty.type == .double {
                        filters.append(DataSourceFilterParameter(property: selectedProperty, comparison: selectedComparison, valueDouble: valueDouble))
                    } else if selectedProperty.type == .enumeration {
                        filters.append(DataSourceFilterParameter(property: selectedProperty, comparison: selectedComparison, valueString: selectedEnumeration))
                    } else if selectedProperty.type == .location {
                        if selectedComparison == .nearMe {
                            filters.append(DataSourceFilterParameter(property: selectedProperty, comparison: selectedComparison, valueInt: valueInt))
                        } else if selectedComparison == .closeTo {
                            filters.append(DataSourceFilterParameter(property: selectedProperty, comparison: selectedComparison, valueInt: valueInt, valueLatitude: valueLatitude, valueLongitude: valueLongitude))
                        }
                    } else {
                        filters.append(DataSourceFilterParameter(property: selectedProperty, comparison: selectedComparison, valueString: valueString))
                    }
                    self.selectedProperty = dataSourceProperties[0]
                    valueDate = Date()
                    valueString = ""
                    valueDouble = 0.0
                    valueInt = 0
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .tint(Color.green)
                }

            }
            .padding(.top, 8)
            .padding(.leading, -8)
        }
        .padding([.leading, .bottom], 16)
        .padding(.trailing, 0)
        .onChange(of: selectedProperty) { newValue in
            selectedEnumeration = selectedProperty.enumerationValues?.first?.key ?? ""
            if selectedProperty.type == .date {
                selectedComparison = .window
            }
            if selectedProperty.type == .location {
                selectedComparison = .nearMe
            }
        }
        .onAppear {
            selectedEnumeration = selectedProperty.enumerationValues?.first?.key ?? ""
            if selectedProperty.type == .date {
                selectedComparison = .window
            }
            if selectedProperty.type == .location {
                selectedComparison = .nearMe
            }
        }
    }
    
    @ViewBuilder
    func propertyNameAndComparison() -> some View {
        HStack {
            Picker("Property", selection: $selectedProperty) {
                ForEach(dataSourceProperties) { property in
                    Text(property.name).tag(property)
                }
            }
            .scaledToFill()
            .labelsHidden()
            .tint(Color.primaryColorVariant)
            
            if selectedProperty.type == DataSourcePropertyType.string {
                Picker("Comparison", selection: $selectedComparison) {
                    ForEach(DataSourceFilterComparison.stringSubset()) { comparison in
                        Text(comparison.rawValue).tag(comparison)
                    }
                }
                .scaledToFill()
                .labelsHidden()
                .tint(Color.primaryColorVariant)
            } else if selectedProperty.type == DataSourcePropertyType.date {
                Picker("Comparison", selection: $selectedComparison) {
                    ForEach(DataSourceFilterComparison.dateSubset()) { comparison in
                        Text(comparison.rawValue).tag(comparison)
                    }
                }
                .scaledToFill()
                .labelsHidden()
                .tint(Color.primaryColorVariant)
            } else if selectedProperty.type == DataSourcePropertyType.enumeration {
                Picker("Comparison", selection: $selectedComparison) {
                    ForEach(DataSourceFilterComparison.enumerationSubset()) { comparison in
                        Text(comparison.rawValue).tag(comparison)
                    }
                }
                .scaledToFill()
                .labelsHidden()
                .tint(Color.primaryColorVariant)
            } else if selectedProperty.type == DataSourcePropertyType.location {
                Picker("Comparison", selection: $selectedComparison) {
                    ForEach(DataSourceFilterComparison.locationSubset()) { comparison in
                        Text(comparison.rawValue).tag(comparison)
                    }
                }
                .scaledToFill()
                .labelsHidden()
                .tint(Color.primaryColorVariant)
            } else {
                Picker("Comparison", selection: $selectedComparison) {
                    ForEach(DataSourceFilterComparison.numberSubset()) { comparison in
                        Text(comparison.rawValue).tag(comparison)
                    }
                }
                .scaledToFill()
                .labelsHidden()
                .tint(Color.primaryColorVariant)
            }
        }
    }
    
    @ViewBuilder
    func inputType(selectedProperty: DataSourceProperty) -> some View {
        if selectedProperty.type == .double || selectedProperty.type == .float {
            HStack(spacing: 0) {
                propertyNameAndComparison()
                TextField(selectedProperty.name, value: $valueDouble, formatter: doubleFormatter)
                .keyboardType(.decimalPad)
                .underlineTextField()
            }
        } else if selectedProperty.type == .int {
            HStack(spacing: 0) {
                propertyNameAndComparison()
                TextField(selectedProperty.name, value: $valueInt, formatter: intFormatter)
                .keyboardType(.numberPad)
                .underlineTextField()
            }
        } else if selectedProperty.type == .date {
            HStack(spacing: 0) {
                propertyNameAndComparison()
                if selectedComparison == .window {
                    Picker("Window", selection: $windowUnits) {
                        ForEach(DataSourceWindowUnits.allCases) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    .scaledToFill()
                    .labelsHidden()
                    .tint(Color.primaryColorVariant)
                } else {
                    DatePicker(
                        selectedProperty.name,
                        selection: $valueDate,
                        displayedComponents: [.date]
                    )
                    .accentColor(Color.primaryColorVariant)
                    .padding(.leading, 8)
                    .labelsHidden()
                }
            }
        } else if selectedProperty.type == .enumeration {
            HStack(spacing: 0) {
                propertyNameAndComparison()
                if let enumerationValues = selectedProperty.enumerationValues {
                    Picker("Enumeration", selection: $selectedEnumeration) {
                        
                        ForEach(enumerationValues.keys.sorted().map { String($0) }, id: \.self) { key in
                            Text(key).tag(key)
                        }
                    }
                    .scaledToFill()
                    .labelsHidden()
                    .tint(Color.primaryColorVariant)
                }
            }
        } else if selectedProperty.type == .location {
            VStack(alignment: .leading, spacing: 0) {
                propertyNameAndComparison()
                if selectedComparison == .closeTo {
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Latitude")
                                .overline()
                                .padding(.leading, 8)
                                .padding(.bottom, -16)
                            TextField("latitude", value: $valueLatitude, format: .number)
                                .keyboardType(.decimalPad)
                                .underlineTextField()
                        }
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Longitude")
                                .overline()
                                .padding(.leading, 8)
                                .padding(.bottom, -16)
                            TextField("longitude", value: $valueLongitude, format: .number)
                            .keyboardType(.decimalPad)
                            .underlineTextField()
                        }
                    }
                    .padding(.leading, 4)
                } else if selectedComparison == .nearMe {
                    if locationManager.lastLocation == nil {
                        Text("No current location")
                    }
                }
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Distance")
                            .overline()
                            .padding(.leading, 8)
                            .padding(.bottom, -16)
                        TextField("distance", value: $valueInt, format: .number)
                            .keyboardType(.numberPad)
                            .underlineTextField()
                    }
                    Text("nm")
                        .overline()
                        .padding(.bottom, 16)
                }
                .padding(.leading, 4)
            }
        } else {
            HStack {
                propertyNameAndComparison()
            }
            TextField(
                selectedProperty.name,
                text: $valueString
            )
            .keyboardType(.default)
            .underlineTextField()
        }
    }
}

