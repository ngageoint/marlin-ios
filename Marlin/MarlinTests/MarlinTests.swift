//
//  MarlinTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 6/6/22.
//

import XCTest
import mgrs_ios

class MarlinTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testMGRS() {
        let longitude: Double = 15.3894
        let latitude: Double = 23.5038
        _ = MGRS.from(longitude, latitude, .DEGREE)
    }
    
    func testMGRS2() {
        let longitude: Double = -157.868595
        let latitude: Double = 21.319392
        _ = MGRS.from(longitude, latitude, .DEGREE)
    }
    
    func testGeneralDirection() {
//        let directions = ["N", "E", "S", "W"]
//        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let directions = ["N","NNE","NE","ENE","E","ESE","SE","SSE","S","SSW","SW","WSW","W","WNW", "NW", "NNW"]
//        let bearing = self.bearing(to: point)
//        let index = Int(bearing.truncatingRemainder(dividingBy: 6.125))
        
        let bearingCorrection = 360.0 / Double(directions.count * 2)
        let indexDegrees = 360.0 / Double(directions.count)
        
        for degrees in 0...360 {
            var bearing = Double(degrees) + (bearingCorrection)
            if bearing < 0 {
                bearing = bearing + 360
            }
            if bearing > 360 {
                bearing = bearing - 360
            }
            let index = Int(Double(bearing / indexDegrees).rounded(.down)) % directions.count

            _ = directions[index]
//            print("xxx degrees \(degrees) direction \(direction)")
        }
    }

}
