//
//  DataSourceFilterParameterTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 12/5/22.
//

import XCTest
import CoreLocation

@testable import Marlin

final class DataSourceFilterParameterTests: XCTestCase {
    
    override func setUp() {
        LocationManager.shared().lastLocation = nil
    }
    
    override class func tearDown() {
        LocationManager.shared().lastLocation = nil
    }

    func testStringValueDisplay() {
        let p = DataSourceFilterParameter(property: DataSourceProperty(name: "String", key: "string", type: .string), comparison: .equals, valueString: "Hi")
        XCTAssertEqual(p.display(), "**String** = **Hi**")
    }
    
    func testDateValueDisplay() {
        let date = Date()
        let p = DataSourceFilterParameter(property: DataSourceProperty(name: "Date", key: "date", type: .date), comparison: .equals, valueDate: date)
        XCTAssertEqual(p.display(), "**Date** = **\(date.formatted())**")
        
        let p2 = DataSourceFilterParameter(property: DataSourceProperty(name: "Date", key: "date", type: .date), comparison: .window, windowUnits: .last7Days)
        XCTAssertEqual(p2.display(), "**Date** within the **last 7 days**")
    }
    
    func testIntValueDisplay() {
        let p = DataSourceFilterParameter(property: DataSourceProperty(name: "Int", key: "int", type: .int), comparison: .equals, valueInt: 1)
        XCTAssertEqual(p.display(), "**Int** = **1**")
    }
    
    func testFloatValueDisplay() {
        let p = DataSourceFilterParameter(property: DataSourceProperty(name: "Float", key: "float", type: .float), comparison: .equals, valueDouble: 1.0)
        XCTAssertEqual(p.display(), "**Float** = **1.0**")
    }
    
    func testDoubleValueDisplay() {
        let p = DataSourceFilterParameter(property: DataSourceProperty(name: "Double", key: "double", type: .double), comparison: .equals, valueDouble: 1.0)
        XCTAssertEqual(p.display(), "**Double** = **1.0**")
    }
    
    func testEnumerationValueDisplay() {
        let p = DataSourceFilterParameter(property: DataSourceProperty(name: "Enumeration", key: "Enumeration", type: .enumeration), comparison: .equals, valueString: "Hi")
        XCTAssertEqual(p.display(), "**Enumeration** = **Hi**")
    }
    
    func testBooleanValueDisplay() {
        let p = DataSourceFilterParameter(property: DataSourceProperty(name: "Boolean", key: "Boolean", type: .boolean), comparison: .equals, valueInt: 1)
        XCTAssertEqual(p.display(), "**Boolean** = **True**")
        
        let p2 = DataSourceFilterParameter(property: DataSourceProperty(name: "Boolean", key: "Boolean", type: .boolean), comparison: .equals, valueInt: 0)
        XCTAssertEqual(p2.display(), "**Boolean** = **False**")
    }
    
    func testLatitudeValueDisplay() {
        let p = DataSourceFilterParameter(property: DataSourceProperty(name: "Latitude", key: "Latitude", type: .latitude), comparison: .equals, valueString: "4.0N", valueLatitude: 4.0)
        XCTAssertEqual(p.display(), "**Latitude** = **4.0N**")
    }
    
    func testLongitudeValueDisplay() {
        let p = DataSourceFilterParameter(property: DataSourceProperty(name: "Longitude", key: "Longitude", type: .longitude), comparison: .equals, valueString: "4.0E", valueLongitude: 4.0)
        XCTAssertEqual(p.display(), "**Longitude** = **4.0E**")
    }
    
    func testLocationValueDisplay() {
        let p = DataSourceFilterParameter(property: DataSourceProperty(name: "Location", key: "Location", type: .location), comparison: .closeTo, valueInt: 1, valueLatitude: 2.0, valueLongitude: 3.0)
        XCTAssertEqual(p.display(), "**Location** within **1nm** of **2.0°, 3.0°**")
        
        let p2 = DataSourceFilterParameter(property: DataSourceProperty(name: "Location", key: "Location", type: .location), comparison: .nearMe, valueInt: 1)
        XCTAssertEqual(p2.display(), "**Location** within **1nm** of my location")
    }
    
    func testStringValuePredicate() {
        let p = DataSourceFilterParameter(property: DataSourceProperty(name: "String", key: "string", type: .string), comparison: .equals, valueString: "Hi")
        let predicate = p.toPredicate(dataSource: CommonDataSource.self)
        let compare = NSPredicate(format: "string == %@", "Hi")
        XCTAssertEqual(predicate, compare)
    }
    
    func testDateValuePredicate() {
        let date = Date(timeIntervalSince1970: 0)
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone
        
        // Get today's beginning & end
        let equalDate = calendar.startOfDay(for: date)
        let nextDate = calendar.date(byAdding: .day, value: 1, to: equalDate)!
        let p = DataSourceFilterParameter(property: DataSourceProperty(name: "Date", key: "date", type: .date), comparison: .equals, valueDate: date)
        let predicate = p.toPredicate(dataSource: CommonDataSource.self)
        let compare = NSPredicate(format: "date >= %@ AND date < %@", equalDate as NSDate, nextDate as NSDate)
        XCTAssertEqual(predicate, compare)
                
        let p2 = DataSourceFilterParameter(property: DataSourceProperty(name: "Date", key: "date", type: .date), comparison: .window, windowUnits: .last7Days)
        let start = calendar.startOfDay(for: Date())
        let windowDate = calendar.date(byAdding: .day, value: -7, to: start)!
            
        let predicate2 = p2.toPredicate(dataSource: CommonDataSource.self)
        let compare2 = NSPredicate(format: "date >= %@", windowDate as NSDate)
        XCTAssertEqual(predicate2, compare2)
        
        let p3 = DataSourceFilterParameter(property: DataSourceProperty(name: "Date", key: "date", type: .date), comparison: .greaterThanEqual, valueDate: date)
        let predicate3 = p3.toPredicate(dataSource: CommonDataSource.self)
        let compare3 = NSPredicate(format: "date >= %@", equalDate as NSDate)
        XCTAssertEqual(predicate3, compare3)
    }
    
    func testIntValuePredicate() {
        let p = DataSourceFilterParameter(property: DataSourceProperty(name: "Int", key: "int", type: .int), comparison: .equals, valueInt: 1)
        let predicate = p.toPredicate(dataSource: CommonDataSource.self)
        let compare = NSPredicate(format: "int == %d", 1)
        XCTAssertEqual(predicate, compare)
    }
    
    func testFloatValuePredicate() {
        let p = DataSourceFilterParameter(property: DataSourceProperty(name: "Float", key: "float", type: .float), comparison: .equals, valueDouble: 1.0)
        let predicate = p.toPredicate(dataSource: CommonDataSource.self)
        let compare = NSPredicate(format: "float == %f", 1.0)
        XCTAssertEqual(predicate, compare)
    }
    
    func testDoubleValuePredicate() {
        let p = DataSourceFilterParameter(property: DataSourceProperty(name: "Double", key: "double", type: .double), comparison: .equals, valueDouble: 1.0)
        let predicate = p.toPredicate(dataSource: CommonDataSource.self)
        let compare = NSPredicate(format: "double == %f", 1.0)
        XCTAssertEqual(predicate, compare)
    }
    
    func testEnumerationValuePredicate() {
        let p = DataSourceFilterParameter(property: DataSourceProperty(name: "Enumeration", key: "Enumeration", type: .enumeration), comparison: .equals, valueString: "Hi")
        let predicate = p.toPredicate(dataSource: CommonDataSource.self)
        let compare = NSPredicate(format: "Enumeration == %@", "Hi")
        XCTAssertEqual(predicate, compare)
        
        let p2 = DataSourceFilterParameter(property: DataSourceProperty(name: "Enumeration", key: "Enumeration", type: .enumeration, enumerationValues: ["Yes": ["Y"], "No": ["N"], "Unknown": ["U", "UNK", "unknown"]]), comparison: .equals, valueString: "Unknown")
        print("\(DecisionEnum.keyValueMap)")
        let predicate2 = p2.toPredicate(dataSource: CommonDataSource.self)
        let compare2 = NSPredicate(format: "Enumeration == %@ OR Enumeration == %@ OR Enumeration == %@", "U", "UNK", "unknown")
        XCTAssertEqual(predicate2, compare2)
    }
    
    func testBooleanValuePredicate() {
        let p = DataSourceFilterParameter(property: DataSourceProperty(name: "Boolean", key: "Boolean", type: .boolean), comparison: .equals, valueInt: 1)
        let predicate = p.toPredicate(dataSource: CommonDataSource.self)
        let compare = NSPredicate(format: "Boolean == %d", 1)
        XCTAssertEqual(predicate, compare)
        
        let p2 = DataSourceFilterParameter(property: DataSourceProperty(name: "Boolean", key: "Boolean", type: .boolean), comparison: .equals, valueInt: 0)
        let predicate2 = p2.toPredicate(dataSource: CommonDataSource.self)
        let compare2 = NSPredicate(format: "Boolean == %d", 0)
        XCTAssertEqual(predicate2, compare2)
    }
    
    func testLatitudeValuePredicate() {
        let p = DataSourceFilterParameter(property: DataSourceProperty(name: "Latitude", key: "Latitude", type: .latitude), comparison: .equals, valueString: "4.0N", valueLatitude: 4.0)
        let predicate = p.toPredicate(dataSource: CommonDataSource.self)
        let compare = NSPredicate(format: "Latitude == %f", 4.0)
        XCTAssertEqual(predicate, compare)
    }
    
    func testLongitudeValuePredicate() {
        let p = DataSourceFilterParameter(property: DataSourceProperty(name: "Longitude", key: "Longitude", type: .longitude), comparison: .equals, valueString: "4.0E", valueLongitude: 4.0)
        let predicate = p.toPredicate(dataSource: CommonDataSource.self)
        let compare = NSPredicate(format: "Longitude == %f", 4.0)
        XCTAssertEqual(predicate, compare)
    }
    
    func testLocationValuePredicate() {
        let p = DataSourceFilterParameter(property: DataSourceProperty(name: "Location", key: "Location", type: .location), comparison: .closeTo, valueInt: 1, valueLatitude: 2.0, valueLongitude: 3.0)
        let predicate = p.toPredicate(dataSource: CommonDataSource.self)
        let compare = NSPredicate(format: "latitude <= %f AND latitude >= %f AND longitude <= %f AND longitude >= %f", 2.016627, 1.983373, 3.016637, 2.983363)
        XCTAssertEqual(predicate?.kifPredicateDescription, compare.kifPredicateDescription)

        let p2 = DataSourceFilterParameter(property: DataSourceProperty(name: "Location", key: "Location", type: .location), comparison: .nearMe, valueInt: 1)
        let predicate2 = p2.toPredicate(dataSource: CommonDataSource.self)
        XCTAssertNil(predicate2)

        LocationManager.shared().locationManager(CLLocationManager(), didUpdateLocations: [CLLocation(latitude: 2.0, longitude: 3.0)])
        let predicate3 = p2.toPredicate(dataSource: CommonDataSource.self)
        XCTAssertEqual(predicate3?.kifPredicateDescription, compare.kifPredicateDescription)
    }
}
