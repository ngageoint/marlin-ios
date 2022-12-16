//
//  DataSourcePropertyFilterViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 12/2/22.
//

import Foundation
import SwiftUI
import MapKit

class DataSourcePropertyFilterViewModel: ObservableObject {
    @ObservedObject var locationManager: LocationManager = LocationManager.shared
    
    @Published var startValidating: Bool = false
    @Published var dataSourceProperty: DataSourceProperty {
        didSet {
            selectedComparison = dataSourceProperty.type.defaultComparison()
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
    var isStaticProperty: Bool = false
    @Published var selectedComparison: DataSourceFilterComparison
    @Published var valueString: String = ""
    @Published var valueDate: Date = Date()
    @Published var valueInt: Int? = nil// = 0
    @Published var valueDouble: Double? = nil
    var valueLatitude: Double? = nil// = 0.0
    var valueLongitude: Double? = nil// = 0.0
    @Published var valueLongitudeString: String = "" {
        didSet {
            if let parsed = Double(coordinateString: valueLongitudeString) {
                valueLongitude = parsed
            }
        }
    }
    @Published var valueLatitudeString: String = "" {
        didSet {
            if let parsed = Double(coordinateString: valueLatitudeString) {
                valueLatitude = parsed
            }
        }
    }
    @Published var windowUnits: DataSourceWindowUnits = .last30Days
    
    private var latitudeDelta: Double = 0.5
    private var longitudeDelta: Double = 0.5
        
    var region: MKCoordinateRegion {
        get {
            MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: valueLatitude ?? 0.0, longitude: valueLongitude ?? 0.0), span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta))
        }
        set {
            DispatchQueue.main.async {
                self.valueLongitudeString = "\(newValue.center.longitude)"
                self.valueLatitudeString = "\(newValue.center.latitude)"
                self.longitudeDelta = newValue.span.longitudeDelta
                self.latitudeDelta = newValue.span.latitudeDelta
            }
        }
    }
    
    private var _currentRegion: MKCoordinateRegion?
    var currentRegion: MKCoordinateRegion {
        get {
            MKCoordinateRegion(center: locationManager.lastLocation?.coordinate ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta))
        }
        set {
            _currentRegion = newValue
        }
    }

    private var _readableRegion: MKCoordinateRegion?
    var readableRegion: MKCoordinateRegion {
        get {
            MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: valueLatitude ?? 0.0, longitude: valueLongitude ?? 0.0), span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta))
        }
        set {
            _readableRegion = newValue
        }
    }
    
    var validationText: String? {
        if !startValidating {
            return nil
        }
        switch dataSourceProperty.type {
        case .double, .float:
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
        }
        return "Invalid Latitude"
    }
    var validationLongitudeText: String? {
        if valueLongitudeString.isEmpty {
            return nil
        }
        if let parsed = Double(coordinateString: valueLongitudeString) {
            return "\(parsed)"
        }
        return "Invalid Longitude"
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
                valueLatitude = nil
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
    
    init(dataSourceProperty: DataSourceProperty, isStaticProperty: Bool = false) {
        self.dataSourceProperty = dataSourceProperty
        self.selectedComparison = dataSourceProperty.type.defaultComparison()
        self.isStaticProperty = isStaticProperty
    }
}
