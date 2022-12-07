//
//  LocationManagerTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 12/6/22.
//

import XCTest
import CoreLocation
import geopackage_ios

@testable import Marlin

final class LocationManagerTests: XCTestCase {
    
    override func setUp() {
        LocationManager.shared.lastLocation = nil
        LocationManager.shared.locationStatus = nil
        LocationManager.shared.currentNavArea = nil
        LocationManager.shared.current10kmMGRS = nil
        if let manager = GPKGGeoPackageFactory.manager() {
            manager.delete(LocationManager.shared.navAreaGeoPackageFileName)
        }
        LocationManager.shared.initializeGeoPackage()
    }
    
    override func tearDown() {
        LocationManager.shared.lastLocation = nil
        LocationManager.shared.locationStatus = nil
        LocationManager.shared.currentNavArea = nil
        LocationManager.shared.current10kmMGRS = nil
    }

    func testRecieveLocationFromSystem() {
        let location = CLLocation(latitude: 4.0, longitude: 5.0)
        LocationManager.shared.locationManager(CLLocationManager(), didUpdateLocations: [location])
        XCTAssertEqual(LocationManager.shared.lastLocation, location)
        XCTAssertEqual(LocationManager.shared.current10kmMGRS, "31NGE24")
        XCTAssertEqual(LocationManager.shared.currentNavArea?.display, "HYDROLANT")
    }
    
    func testAuthStatus() {
        expectation(forNotification: .LocationAuthorizationStatusChanged,
                    object: nil) { notification in
            return true
        }
        LocationManager.shared.locationManager(CLLocationManager(), didChangeAuthorization: .authorizedAlways)
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertEqual(LocationManager.shared.locationStatus, .authorizedAlways)
        XCTAssertEqual(LocationManager.shared.statusString, "authorizedAlways")

        expectation(forNotification: .LocationAuthorizationStatusChanged,
                    object: nil) { notification in
            return true
        }
        LocationManager.shared.locationManager(CLLocationManager(), didChangeAuthorization: .denied)
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertEqual(LocationManager.shared.locationStatus, .denied)
        XCTAssertEqual(LocationManager.shared.statusString, "denied")
        
        expectation(forNotification: .LocationAuthorizationStatusChanged,
                    object: nil) { notification in
            return true
        }
        LocationManager.shared.locationManager(CLLocationManager(), didChangeAuthorization: .notDetermined)
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertEqual(LocationManager.shared.locationStatus, .notDetermined)
        XCTAssertEqual(LocationManager.shared.statusString, "notDetermined")
        
        expectation(forNotification: .LocationAuthorizationStatusChanged,
                    object: nil) { notification in
            return true
        }
        LocationManager.shared.locationManager(CLLocationManager(), didChangeAuthorization: .authorizedWhenInUse)
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertEqual(LocationManager.shared.locationStatus, .authorizedWhenInUse)
        XCTAssertEqual(LocationManager.shared.statusString, "authorizedWhenInUse")
        
        expectation(forNotification: .LocationAuthorizationStatusChanged,
                    object: nil) { notification in
            return true
        }
        LocationManager.shared.locationManager(CLLocationManager(), didChangeAuthorization: .restricted)
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertEqual(LocationManager.shared.locationStatus, .restricted)
        XCTAssertEqual(LocationManager.shared.statusString, "restricted")
    }

}
