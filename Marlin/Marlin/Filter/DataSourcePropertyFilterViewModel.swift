//
//  DataSourcePropertyFilterViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 12/2/22.
//

import Foundation
import SwiftUI

class DataSourcePropertyFilterViewModel: ObservableObject {
    @ObservedObject var locationManager: LocationManager = LocationManager.shared
    
    @Published var startValidating: Bool = false
    @Published var dataSourceProperty: DataSourceProperty {
        didSet {
            var comparison:DataSourceFilterComparison = .equals
            if dataSourceProperty.type == DataSourcePropertyType.string {
                comparison = .equals
            } else if dataSourceProperty.type == DataSourcePropertyType.date {
                comparison = .window
            } else if dataSourceProperty.type == DataSourcePropertyType.enumeration {
                comparison = .equals
            } else if dataSourceProperty.type == DataSourcePropertyType.location {
                comparison = .nearMe
            } else {
                comparison = .equals
            }
            selectedComparison = comparison
            valueDate = Date()
            valueString = ""
            valueDouble = nil //0.0
            valueInt = nil// 0
            valueLongitude = nil
            valueLatitude = nil
            valueLatitudeString = ""
            valueLongitudeString = ""
            windowUnits = .last30Days
        }
    }
    @Published var selectedComparison: DataSourceFilterComparison // = .equals
    @Published var valueString: String = ""
    @Published var valueDate: Date = Date()
    @Published var valueInt: Int? = nil// = 0
    @Published var valueDouble: Double? = nil
    var valueLatitude: Double? = nil// = 0.0
    var valueLongitude: Double? = nil// = 0.0
    @Published var valueLongitudeString: String = ""
    @Published var valueLatitudeString: String = ""
    @Published var windowUnits: DataSourceWindowUnits = .last30Days
    var validationText: String? {
        if !startValidating {
            return nil
        }
        switch dataSourceProperty.type {
        case .double:
            if valueDouble == nil {
                return "Invalid number"
            }
        case .int:
            if valueInt == nil {
                return "Invalid number"
            }
        case .latitude:
            if valueString.isEmpty {
                return ""
            }
            
            if let parsed = Double(coordinateString: valueString) {
                return "\(parsed)"
            } else {
                return "Invalid Latitude"
            }
        case .longitude:
            if valueString.isEmpty {
                return ""
            }
            
            if let parsed = Double(coordinateString: valueString) {
                return "\(parsed)"
            } else {
                return "Invalid Longitude"
            }
        default:
            return nil
        }
        return nil
    }
    var validationLatitudeText: String? {
        if valueLatitudeString.isEmpty {
            return nil
        }
        if let parsed = Double(coordinateString: valueLatitudeString) {
            return "\(parsed)"
        } else {
            return "Invalid latitude"
        }
    }
    var validationLongitudeText: String? {
        if valueLongitudeString.isEmpty {
            return nil
        }
        if let parsed = Double(coordinateString: valueLongitudeString) {
            return "\(parsed)"
        } else {
            return "Invalid longitude"
        }
    }
    var isValid: Bool {
        switch dataSourceProperty.type {
        case .double, .float:
            if valueDouble != nil {
                return true
            } else {
                return false
            }
        case .int:
            if valueInt != nil {
                return true
            } else {
                return false
            }
        case .string:
            return !valueString.isEmpty
        case .location:
            if selectedComparison == .nearMe {
                return locationManager.lastLocation != nil && valueInt != nil
            } else {
                if let parsed = Double(coordinateString: valueLongitudeString) {
                    valueLongitude = parsed
                } else {
                    valueLongitude = nil
                }
                if let parsed = Double(coordinateString: valueLatitudeString) {
                    valueLatitude = parsed
                } else {
                    valueLatitude = nil
                }
                
                return valueLatitude != nil && valueLongitude != nil && valueInt != nil
            }
        case .latitude:
            if valueString.isEmpty {
                return false
            }
            
            if let parsed = Double(coordinateString: valueString) {
                valueLatitude = parsed
                return true
            } else {
                valueLatitude = nil
                return false
            }
        case .longitude:
            if valueString.isEmpty {
                return false
            }
            
            if let parsed = Double(coordinateString: valueString) {
                valueLongitude = parsed
                return true
            } else {
                valueLongitude = nil
                return false
            }
        case .date, .enumeration, .boolean:
            return true
        }
    }
    
    init(dataSourceProperty: DataSourceProperty) {
        print("xxx init the data source property filter view model")
        self.dataSourceProperty = dataSourceProperty
        
        var comparison:DataSourceFilterComparison = .equals
        if dataSourceProperty.type == DataSourcePropertyType.string {
            comparison = .equals
        } else if dataSourceProperty.type == DataSourcePropertyType.date {
            comparison = .window
        } else if dataSourceProperty.type == DataSourcePropertyType.enumeration {
            comparison = .equals
        } else if dataSourceProperty.type == DataSourcePropertyType.location {
            comparison = .nearMe
        } else {
            comparison = .equals
        }
        
        self.selectedComparison = comparison
    }
}
