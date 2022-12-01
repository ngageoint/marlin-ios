//
//  DataSourcePropertyFilterView.swift
//  Marlin
//
//  Created by Daniel Barela on 12/1/22.
//

import SwiftUI

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
    @State var valueLongitudeString: String = ""
    @State var valueLatitudeString: String = ""
    @State var windowUnits: DataSourceWindowUnits = .last30Days
    @State var validationText: String?
    @State var validationLatitudeText: String?
    @State var validationLongitudeText: String?
    @State var isValid: Bool = false
    
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
                    VStack(alignment: .leading, spacing: 0) {
                        TextField(dataSourceProperty.name, value: $valueDouble, format: .number)
                            .keyboardType(.decimalPad)
                            .underlineTextField()
                            .onChange(of: valueDouble) { newValue in
                                if newValue != nil {
                                    isValid = true
                                } else {
                                    validationText = "Invalid number"
                                    isValid = false
                                }
                            }
                        if let validationText = validationText {
                            Text(validationText)
                                .overline()
                                .padding(.leading, 8)
                        }
                    }
                }
            } else if dataSourceProperty.type == .int {
                HStack(spacing: 0) {
                    propertyNameAndComparison()
                    FilterComparison(property: $dataSourceProperty, selectedComparison: $selectedComparison)
                    VStack(alignment: .leading, spacing: 0) {
                        TextField(dataSourceProperty.name, value: $valueInt, format: .number)
                            .keyboardType(.numberPad)
                            .underlineTextField()
                            .onChange(of: valueInt) { newValue in
                                if newValue != nil {
                                    isValid = true
                                } else {
                                    validationText = "Invalid number"
                                    isValid = false
                                }
                            }
                        if let validationText = validationText {
                            Text(validationText)
                                .overline()
                                .padding(.leading, 8)
                        }
                    }
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
                                    isValid = true
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
                                .onAppear {
                                    isValid = true
                                }
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
                            isValid = true
                        }
                    }
                }
            } else if dataSourceProperty.type == .location {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        propertyNameAndComparison()
                        FilterComparison(property: $dataSourceProperty, selectedComparison: $selectedComparison)
                            .onChange(of: selectedComparison) { newValue in
                                if newValue == .nearMe {
                                    isValid = locationManager.lastLocation != nil && valueInt != nil
                                } else {
                                    isValid = valueLatitude != nil && valueLongitude != nil && valueInt != nil
                                }
                            }
                    }
                    if selectedComparison == .closeTo {
                        HStack {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Latitude")
                                    .overline()
                                    .padding(.leading, 8)
                                    .padding(.bottom, -16)
                                TextField("Latitude", text: $valueLatitudeString)
                                    .underlineTextField()
                                    .onChange(of: valueLatitudeString) { newValue in
                                        if newValue.isEmpty {
                                            validationLatitudeText = nil
                                            isValid = false
                                        }
                                        if let parsed = Double(coordinateString: newValue) {
                                            validationLatitudeText = "\(parsed)"
                                            valueLatitude = parsed
                                            isValid = valueLongitude != nil && valueInt != nil
                                        } else {
                                            validationLatitudeText = "Invalid latitude"
                                            valueLatitude = nil
                                            isValid = false
                                        }
                                    }
                                if let validationLatitudeText = validationLatitudeText {
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
                                TextField("Longitude", text: $valueLongitudeString)
                                    .underlineTextField()
                                    .onChange(of: valueLongitudeString) { newValue in
                                        if newValue.isEmpty {
                                            validationLongitudeText = nil
                                            isValid = false
                                        }
                                        if let parsed = Double(coordinateString: newValue) {
                                            validationLongitudeText = "\(parsed)"
                                            valueLongitude = parsed
                                            isValid = valueLatitude != nil && valueInt != nil
                                        } else {
                                            validationLongitudeText = "Invalid longitude"
                                            valueLongitude = nil
                                            isValid = false
                                        }
                                    }
                                if let validationLongitudeText = validationLongitudeText {
                                    Text(validationLongitudeText)
                                        .overline()
                                        .padding(.leading, 8)
                                }
                            }
                        }
                        .padding(.leading, 4)
                        .onAppear {
                            // verify the validity of the inputs
                            isValid = valueLatitude != nil && valueLongitude != nil && valueInt != nil
                        }
                    } else if selectedComparison == .nearMe {
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
                            TextField("Nautical Miles", value: $valueInt, format: .number)
                                .keyboardType(.numberPad)
                                .underlineTextField()
                                .onChange(of: valueInt) { newValue in
                                    if selectedComparison == .closeTo {
                                        if valueLatitude == nil || valueLongitude == nil {
                                            isValid = false
                                            return
                                        }
                                    }
                                    guard let newValue = newValue else {
                                        isValid = false
                                        validationText = "Not a valid number"
                                        return
                                    }
                                    if newValue > 0 {
                                        isValid = true
                                    } else {
                                        isValid = false
                                        validationText = "Distance must be greater than zero"
                                    }
                                }
                            if let validationText = validationText {
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
            } else if dataSourceProperty.type == .latitude || dataSourceProperty.type == .longitude {
                HStack(spacing: 0) {
                    propertyNameAndComparison()
                    FilterComparison(property: $dataSourceProperty, selectedComparison: $selectedComparison)
                    VStack(alignment: .leading, spacing: 0) {
                        TextField(dataSourceProperty.name, text: $valueString)
                            .keyboardType(.default)
                            .underlineTextField()
                            .onChange(of: valueString) { newValue in
                                if newValue.isEmpty {
                                    validationText = nil
                                    isValid = false
                                }
                                if let parsed = Double(coordinateString: newValue) {
                                    validationText = "\(parsed)"
                                    if dataSourceProperty.type == .latitude {
                                        valueLatitude = parsed
                                    } else {
                                        valueLongitude = parsed
                                    }
                                    isValid = true
                                } else {
                                    valueLatitude = nil
                                    valueLongitude = nil
                                    isValid = false
                                }
                            }
                        if let validationText = validationText {
                            Text(validationText)
                                .overline()
                                .padding(.leading, 8)
                        }
                    }
                }
            } else {
                HStack(spacing: 0) {
                    propertyNameAndComparison()
                    FilterComparison(property: $dataSourceProperty, selectedComparison: $selectedComparison)
                    VStack(alignment: .leading, spacing: 0) {
                        TextField(dataSourceProperty.name, text: $valueString)
                            .keyboardType(.default)
                            .underlineTextField()
                            .onChange(of: valueString) { newValue in
                                isValid = !newValue.isEmpty
                            }
                        if let validationText = validationText {
                            Text(validationText)
                                .overline()
                                .padding(.leading, 8)
                        }
                    }
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
                valueLatitudeString = ""
                valueLongitudeString = ""
                windowUnits = .last30Days
                isValid = false
                validationText = nil
            } label: {
                Image(systemName: "plus.circle.fill")
                    .tint(Color.green)
            }
            .disabled(!isValid)
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
            valueDate = Date()
            valueString = ""
            valueDouble = nil //0.0
            valueInt = nil// 0
            valueLongitude = nil
            valueLatitude = nil
            valueLatitudeString = ""
            valueLongitudeString = ""
            windowUnits = .last30Days
            isValid = false
            validationText = nil
            
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
