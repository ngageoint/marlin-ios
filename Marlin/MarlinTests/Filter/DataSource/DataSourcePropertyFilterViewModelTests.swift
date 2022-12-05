//
//  DataSourcePropertyFilterViewModelTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 12/2/22.
//

import XCTest
import CoreLocation

@testable import Marlin

final class DataSourcePropertyFilterViewModelTests: XCTestCase {

    func testSettingLatitudeToDMS() {
        let model = DataSourcePropertyFilterViewModel(dataSourceProperty: DataSourceProperty(name: "Latitude", key: #keyPath(MockDataSource.latitude), type: .latitude))
        model.startValidating = true
        XCTAssertFalse(model.isValid)
        
        model.valueString = "19°18'01.5\"N"
        XCTAssertTrue(model.isValid)
        XCTAssertEqual(model.valueLatitude, 19.300416666666667)
        XCTAssertEqual(model.validationText, "19.300416666666667")
        
        model.valueString = "a"
        XCTAssertFalse(model.isValid)
        XCTAssertNil(model.valueLatitude)
        XCTAssertEqual(model.validationText, "Invalid Latitude")
        
        model.valueString = ""
        XCTAssertFalse(model.isValid)
        XCTAssertNil(model.valueLatitude)
        XCTAssertEqual(model.validationText, "")
        
        model.valueString = "4"
        XCTAssertTrue(model.isValid)
        XCTAssertEqual(model.valueLatitude, 4.0)
        XCTAssertEqual(model.validationText, "4.0")
    }
    
    func testSettingLongitudeToDMS() {
        let model = DataSourcePropertyFilterViewModel(dataSourceProperty: DataSourceProperty(name: "Longitude", key: #keyPath(MockDataSource.longitude), type: .longitude))
        model.startValidating = true
        XCTAssertFalse(model.isValid)

        model.valueString = "19°18'01.5\"E"
        XCTAssertTrue(model.isValid)
        XCTAssertEqual(model.valueLongitude, 19.300416666666667)
        XCTAssertEqual(model.validationText, "19.300416666666667")

        model.valueString = "a"
        XCTAssertFalse(model.isValid)
        XCTAssertNil(model.valueLongitude)
        XCTAssertEqual(model.validationText, "Invalid Longitude")

        model.valueString = ""
        XCTAssertFalse(model.isValid)
        XCTAssertNil(model.valueLongitude)
        XCTAssertEqual(model.validationText, "")

        model.valueString = "4"
        XCTAssertTrue(model.isValid)
        XCTAssertEqual(model.valueLongitude, 4.0)
        XCTAssertEqual(model.validationText, "4.0")
    }
    
    func testSettingDate() {
        let model = DataSourcePropertyFilterViewModel(dataSourceProperty: DataSourceProperty(name: "Date", key: #keyPath(MockDataSource.dateProperty), type: .date))
        model.startValidating = true
        model.selectedComparison = .equals
        XCTAssertNotNil(model.valueDate)
        XCTAssertTrue(model.isValid)
        
        model.valueDate = Date()
        XCTAssertTrue(model.isValid)
        
        model.selectedComparison = .window
        model.windowUnits = .last7Days
        XCTAssertTrue(model.isValid)
    }
    
    func testSettingInt() {
        let model = DataSourcePropertyFilterViewModel(dataSourceProperty: DataSourceProperty(name: "Int", key: #keyPath(MockDataSource.intProperty), type: .int))
        model.startValidating = true
        model.selectedComparison = .equals
        XCTAssertFalse(model.isValid)
        
        model.valueInt = 1
        XCTAssertTrue(model.isValid)
        
        model.selectedComparison = .equals
        model.valueInt = nil
        XCTAssertFalse(model.isValid)
        XCTAssertEqual(model.validationText, "Invalid number")
    }
    
    func testSettingDouble() {
        let model = DataSourcePropertyFilterViewModel(dataSourceProperty: DataSourceProperty(name: "Double", key: #keyPath(MockDataSource.doubleProperty), type: .double))
        model.startValidating = true
        model.selectedComparison = .equals
        XCTAssertFalse(model.isValid)
        
        model.valueDouble = 1.0
        XCTAssertTrue(model.isValid)
        
        model.selectedComparison = .equals
        model.valueDouble = nil
        XCTAssertFalse(model.isValid)
        XCTAssertEqual(model.validationText, "Invalid number")
    }
    
    func testSettingFloat() {
        let model = DataSourcePropertyFilterViewModel(dataSourceProperty: DataSourceProperty(name: "Float", key: #keyPath(MockDataSource.floatProperty), type: .float))
        model.startValidating = true
        model.selectedComparison = .equals
        XCTAssertFalse(model.isValid)
        
        model.valueDouble = 1.0
        XCTAssertTrue(model.isValid)
        
        model.selectedComparison = .equals
        model.valueDouble = nil
        XCTAssertFalse(model.isValid)
        XCTAssertEqual(model.validationText, "Invalid number")
    }
    
    func testSettingString() {
        let model = DataSourcePropertyFilterViewModel(dataSourceProperty: DataSourceProperty(name: "String", key: #keyPath(MockDataSource.stringProperty), type: .string))
        model.startValidating = true
        model.selectedComparison = .startsWith
        XCTAssertFalse(model.isValid)
        
        model.valueString = "hi"
        XCTAssertTrue(model.isValid)
        XCTAssertEqual(model.validationText, nil)
    }
    
    func testSettingLocation() {
        let model = DataSourcePropertyFilterViewModel(dataSourceProperty: DataSourceProperty(name: "Location", key: #keyPath(MockDataSource.locationProperty), type: .location))
        model.startValidating = true
        model.selectedComparison = .closeTo
        
        model.valueLatitudeString = "19°18'01.5\"N"
        XCTAssertFalse(model.isValid)
        XCTAssertEqual(model.valueLatitude, 19.300416666666667)
        XCTAssertEqual(model.validationLatitudeText, "19.300416666666667")
        model.valueLongitudeString = "19°18'01.5\"E"
        XCTAssertFalse(model.isValid)
        XCTAssertEqual(model.valueLongitude, 19.300416666666667)
        XCTAssertEqual(model.validationLongitudeText, "19.300416666666667")
        model.valueInt = 4
        XCTAssertTrue(model.isValid)
        XCTAssertEqual(model.valueInt, 4)
        XCTAssertEqual(model.validationText, nil)
        
        model.valueLatitudeString = "a"
        XCTAssertFalse(model.isValid)
        XCTAssertNil(model.valueLatitude)
        XCTAssertEqual(model.validationLatitudeText, "Invalid Latitude")
        
        model.valueLatitudeString = ""
        XCTAssertFalse(model.isValid)
        XCTAssertNil(model.valueLatitude)
        XCTAssertEqual(model.validationLatitudeText, nil)
        
        model.valueLatitudeString = "4"
        XCTAssertTrue(model.isValid)
        XCTAssertEqual(model.valueLatitude, 4.0)
        XCTAssertEqual(model.validationLatitudeText, "4.0")
        
        model.valueLongitudeString = "a"
        XCTAssertFalse(model.isValid)
        XCTAssertNil(model.valueLongitude)
        XCTAssertEqual(model.validationLongitudeText, "Invalid Longitude")
        
        model.valueLongitudeString = ""
        XCTAssertFalse(model.isValid)
        XCTAssertNil(model.valueLongitude)
        XCTAssertEqual(model.validationLongitudeText, nil)
        
        model.valueLongitudeString = "4"
        XCTAssertTrue(model.isValid)
        XCTAssertEqual(model.valueLongitude, 4.0)
        XCTAssertEqual(model.validationLongitudeText, "4.0")
        
        model.selectedComparison = .nearMe
        model.valueInt = nil
        XCTAssertEqual(model.valueInt, nil)
        // no last location
        XCTAssertNil(LocationManager.shared.lastLocation)
        XCTAssertFalse(model.isValid)
        
        LocationManager.shared.locationManager(CLLocationManager(), didUpdateLocations: [CLLocation(latitude: 1.0, longitude: 1.0)])
        XCTAssertNotNil(LocationManager.shared.lastLocation)
        XCTAssertFalse(model.isValid)
        
        model.valueInt = 4
        XCTAssertTrue(model.isValid)
    }
    
    func testSettingChangingProperty() {
        let model = DataSourcePropertyFilterViewModel(dataSourceProperty: DataSourceProperty(name: "Float", key: #keyPath(MockDataSource.floatProperty), type: .float))

        model.selectedComparison = .greaterThan
        model.valueDouble = 1.0
        model.valueString = "a"
        model.valueInt = 1
        model.valueLongitude = 1.0
        model.valueLatitude = 1.0
        model.valueLatitudeString = "a"
        model.valueLongitudeString = "a"
        model.windowUnits = .last7Days
        
        model.dataSourceProperty = DataSourceProperty(name: "Double", key: #keyPath(MockDataSource.doubleProperty), type: .double)
        XCTAssertNil(model.valueDouble)
        XCTAssertNil(model.valueInt)
        XCTAssertNil(model.valueLongitude)
        XCTAssertNil(model.valueLatitude)
        XCTAssertEqual(model.valueString, "")
        XCTAssertEqual(model.valueLatitudeString, "")
        XCTAssertEqual(model.valueLongitudeString, "")
        XCTAssertEqual(model.selectedComparison, DataSourcePropertyType.double.defaultComparison())
    }
}
