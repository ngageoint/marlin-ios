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

struct DataSourcePropertyFilterView: View {
    @ObservedObject var locationManager: LocationManager = LocationManager.shared
    
    @Binding var filterParameter: DataSourceFilterParameter?

    var dataSourceProperties: [DataSourceProperty]?
    @State var dataSourceProperty: DataSourceProperty
    @State var selectedComparison: DataSourceFilterComparison // = .equals
    @State var valueString: String = ""
    @State var valueDate: Date = Date()
    @State var valueInt: Int? = nil// = 0
    @State var valueDouble: Double? = nil// = 0.0
    @State var valueLatitude: Double? = nil// = 0.0
    @State var valueLongitude: Double? = nil// = 0.0
    @State var windowUnits: DataSourceWindowUnits = .last30Days

    init(dataSourceProperty: DataSourceProperty? = nil, dataSourceProperties: [DataSourceProperty]? = nil, filterParameter: Binding<DataSourceFilterParameter?>) {
        if let dataSourceProperty = dataSourceProperty {
            self._dataSourceProperty = State(initialValue: dataSourceProperty)
        } else if let dataSourceProperties = dataSourceProperties, !dataSourceProperties.isEmpty {
            self.dataSourceProperties = dataSourceProperties
            self._dataSourceProperty = State(initialValue: dataSourceProperties[0])
        } else {
            self._dataSourceProperty = State(initialValue: DataSourceProperty(name: "", key: "", type: .string))
        }
        self._filterParameter = filterParameter
        
        if let dataSourceProperty = dataSourceProperty {
            if dataSourceProperty.type == DataSourcePropertyType.string {
                _selectedComparison = State(initialValue: .equals)
            } else if dataSourceProperty.type == DataSourcePropertyType.date {
                _selectedComparison = State(initialValue: .window)
            } else if dataSourceProperty.type == DataSourcePropertyType.enumeration {
                _selectedComparison = State(initialValue: .equals)
            } else if dataSourceProperty.type == DataSourcePropertyType.location {
                _selectedComparison = State(initialValue: .nearMe)
            } else {
                _selectedComparison = State(initialValue: .equals)
            }
        } else {
            _selectedComparison = State(initialValue: .equals)
        }
    }

    var body: some View {
        HStack {
            if dataSourceProperty.type == .double || dataSourceProperty.type == .float {
                HStack(spacing: 0) {
                    propertyNameAndComparison()
                    FilterComparison(property: $dataSourceProperty, selectedComparison: $selectedComparison)
                    TextField(dataSourceProperty.name, value: $valueDouble, format: .number)
                        .keyboardType(.decimalPad)
                        .underlineTextField()
                }
            } else if dataSourceProperty.type == .int {
                HStack(spacing: 0) {
                    propertyNameAndComparison()
                    FilterComparison(property: $dataSourceProperty, selectedComparison: $selectedComparison)
                    TextField(dataSourceProperty.name, value: $valueInt, format: .number)
                        .keyboardType(.numberPad)
                        .underlineTextField()
                }
            } else if dataSourceProperty.type == .date {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 0) {
                        propertyNameAndComparison()
                        FilterComparison(property: $dataSourceProperty, selectedComparison: $selectedComparison)
                    }
                    if selectedComparison == .window {
                        HStack(alignment: .bottom) {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Dynamic Date Window")
                                    .overline()
                                    .padding(.leading, 12)
                                Picker("Window", selection: $windowUnits) {
                                    ForEach(DataSourceWindowUnits.allCases) { unit in
                                        Text(unit.rawValue).tag(unit)
                                    }
                                }
                                .clipped()
                                .scaledToFill()
                                .labelsHidden()
                                .tint(Color.primaryColorVariant)
                                .onAppear {
                                    windowUnits = .last30Days
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
                                    dataSourceProperty.name,
                                    selection: $valueDate,
                                    displayedComponents: [.date]
                                )
                                .accentColor(Color.primaryColorVariant)
                                .padding(.leading, 8)
                                .labelsHidden()
                            }
                        }
                    }
                }
            } else if dataSourceProperty.type == .enumeration {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 0) {
                        propertyNameAndComparison()
                        FilterComparison(property: $dataSourceProperty, selectedComparison: $selectedComparison)
                    }
                    if let enumerationValues = dataSourceProperty.enumerationValues {
                        Picker("Enumeration", selection: $valueString) {
                            
                            ForEach(enumerationValues.keys.sorted().map { String($0) }, id: \.self) { key in
                                Text(key).tag(key)
                            }
                        }
                        .scaledToFill()
                        .labelsHidden()
                        .tint(Color.primaryColorVariant)
                        .onAppear {
                            let sorted = enumerationValues.keys.sorted()
                            valueString = sorted.first ?? ""
                        }
                    }
                }
            } else if dataSourceProperty.type == .location {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        propertyNameAndComparison()
                        FilterComparison(property: $dataSourceProperty, selectedComparison: $selectedComparison)
                    }
                    if selectedComparison == .closeTo {
                        HStack {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Latitude")
                                    .overline()
                                    .padding(.leading, 8)
                                    .padding(.bottom, -16)
                                TextField("Latitude", value: $valueLatitude, format: .number)
                                    .keyboardType(.decimalPad)
                                    .underlineTextField()
                            }
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Longitude")
                                    .overline()
                                    .padding(.leading, 8)
                                    .padding(.bottom, -16)
                                TextField("Longitude", value: $valueLongitude, format: .number)
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
                            TextField("Nautical Miles", value: $valueInt, format: .number)
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
                HStack(spacing: 0) {
                    propertyNameAndComparison()
                    FilterComparison(property: $dataSourceProperty, selectedComparison: $selectedComparison)
                    TextField(dataSourceProperty.name, text: $valueString)
                        .keyboardType(.default)
                        .underlineTextField()
                }
            }
            Spacer()
            Button {
                filterParameter = DataSourceFilterParameter(property: dataSourceProperty, comparison: selectedComparison, valueString: valueString, valueDate: valueDate, valueInt: valueInt, valueDouble: valueDouble, valueLatitude: valueLatitude, valueLongitude: valueLongitude, windowUnits: windowUnits)
                valueDate = Date()
                valueString = ""
                valueDouble = nil //0.0
                valueInt = nil// 0
                valueLongitude = nil
                valueLatitude = nil
                windowUnits = .last30Days
            } label: {
                Image(systemName: "plus.circle.fill")
                    .tint(Color.green)
            }
        }
        .onChange(of: dataSourceProperty) { newValue in
            if newValue.type == DataSourcePropertyType.string {
                selectedComparison = .equals
            } else if newValue.type == DataSourcePropertyType.date {
                selectedComparison = .window
                windowUnits = .last30Days
            } else if newValue.type == DataSourcePropertyType.enumeration {
                selectedComparison = .equals
            } else if newValue.type == DataSourcePropertyType.location {
                selectedComparison = .nearMe
            } else {
                selectedComparison = .equals
            }
        }
    }
    
    @ViewBuilder
    func propertyNameAndComparison() -> some View {
        if let dataSourceProperties = dataSourceProperties, dataSourceProperties.count > 1 {
            HStack {
                Picker("Property", selection: $dataSourceProperty) {
                    if let dataSourceProperties = dataSourceProperties {
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
                Text(dataSourceProperty.name).primary()
                    .padding(.leading, 8)
            }
        }
    }
}

struct FilterComparison: View {
    @Binding var property: DataSourceProperty
    @Binding var selectedComparison: DataSourceFilterComparison

    var body: some View {
        Group {
            if property.type == DataSourcePropertyType.string {
                Picker("Comparison", selection: $selectedComparison) {
                    ForEach(DataSourceFilterComparison.stringSubset()) { comparison in
                        Text(comparison.rawValue).tag(comparison)
                    }
                }
                .scaledToFill()
                .labelsHidden()
                .tint(Color.primaryColorVariant)
            } else if property.type == DataSourcePropertyType.date {
                Picker("Comparison", selection: $selectedComparison) {
                    ForEach(DataSourceFilterComparison.dateSubset()) { comparison in
                        Text(comparison.rawValue).tag(comparison)
                    }
                }
                .scaledToFill()
                .labelsHidden()
                .tint(Color.primaryColorVariant)
            } else if property.type == DataSourcePropertyType.enumeration {
                Picker("Comparison", selection: $selectedComparison) {
                    ForEach(DataSourceFilterComparison.enumerationSubset()) { comparison in
                        Text(comparison.rawValue).tag(comparison)
                    }
                }
                .scaledToFill()
                .labelsHidden()
                .tint(Color.primaryColorVariant)
            } else if property.type == DataSourcePropertyType.location {
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
        .onAppear {
            if property.type == DataSourcePropertyType.string {
                selectedComparison = .equals
            } else if property.type == DataSourcePropertyType.date {
                selectedComparison = .window
            } else if property.type == DataSourcePropertyType.enumeration {
                selectedComparison = .equals
            } else if property.type == DataSourcePropertyType.location {
                selectedComparison = .nearMe
            } else {
                selectedComparison = .equals
            }
        }
        .onChange(of: property) { newValue in
            if newValue.type == DataSourcePropertyType.string {
                selectedComparison = .equals
            } else if newValue.type == DataSourcePropertyType.date {
                selectedComparison = .window
            } else if newValue.type == DataSourcePropertyType.enumeration {
                selectedComparison = .equals
            } else if newValue.type == DataSourcePropertyType.location {
                selectedComparison = .nearMe
            } else {
                selectedComparison = .equals
            }
        }
    }
}

struct FilterParameterSummaryView: View {
    var filter: DataSourceFilterParameter
    var dataSource: DataSource.Type
    
    var body: some View {
        if filter.property.type == .date {
            if filter.comparison == .window, let windowUnits = filter.windowUnits {
                Text("**\(filter.property.name)** within the **\(windowUnits.rawValue)**")
                    .primary()
            } else if let dateValue = filter.valueDate {
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
    
    @State private var selectedProperty: DataSourceProperty
    
    @State private var filterParameter: DataSourceFilterParameter?
        
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
    
    init(dataSource: any DataSource.Type, useDefaultForEmptyFilter: Bool = false) {
        self.dataSource = dataSource
        self.dataSourceProperties = dataSource.properties
        let savedFilter = UserDefaults.standard.filter(dataSource)
        if useDefaultForEmptyFilter && savedFilter.isEmpty {
            self._filters = State(initialValue: dataSource.defaultFilter)
        } else {
            self._filters = State(initialValue: savedFilter)
        }
        self._selectedProperty = State(initialValue: dataSourceProperties[0])
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !filters.isEmpty {
                Text("Current Filter")
                    .secondary()
            }
            ForEach(Array(filters.enumerated()), id: \.element) { index, filter in
                HStack {
                    FilterParameterSummaryView(filter: filter, dataSource: dataSource)
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
            let requiredProperties = dataSourceProperties.filter({ property in
                property.requiredInFilter
            })
            let requiredNotSet = requiredProperties.filter { property in
                !filters.contains { parameter in
                    parameter.property.key == property.key
                }
            }
            
            if !requiredProperties.isEmpty {
                if !requiredNotSet.isEmpty {

                    ForEach(requiredNotSet) { property in
                        Text("Add Required Filter Parameters")
                            .secondary()
                        DataSourcePropertyFilterView(dataSourceProperty: property, filterParameter: $filterParameter)
                    }
                    Divider()
                } else {
                    Text("Add Additional Filter Parameters")
                        .secondary()
                }
            }
            if requiredNotSet.isEmpty {
                DataSourcePropertyFilterView(dataSourceProperties: dataSourceProperties, filterParameter: $filterParameter)
                .padding(.top, 8)
                .padding(.leading, -8)
            }
        }
        .padding([.leading, .bottom], 16)
        .padding(.trailing, 0)
        .onAppear {
            UserDefaults.standard.setFilter(dataSource.key, filter: filters)
        }
        .onChange(of: filterParameter, perform: { newValue in
            if let newValue = newValue {
                print("filter parameter changed \(newValue)")
                filters.append(newValue)
            }
        })
    }
}

