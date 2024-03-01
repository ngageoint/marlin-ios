//
//  SearchProviderTests.swift
//  MarlinTests
//
//  Created by Joshua Nelson on 1/30/24.
//

import Foundation
import XCTest
import Combine
import OHHTTPStubs
import CoreData
import SwiftUI
import MapKit

@testable import Marlin

final class SearchProviderTests: XCTestCase {
    func testNativeSearchProvider() {
        NativeSearchProvider<MKLocalSearchMock>.performSearch(searchText: "search", region: nil) { result in
            XCTAssertEqual(result[0].name, "Test item")
            XCTAssertEqual(result[0].placemark.coordinate.latitude, 1.0)
            XCTAssertEqual(result[0].placemark.coordinate.longitude, 1.0)
            XCTAssertEqual(result[0].pointOfInterestCategory, .airport)
        }
        XCTAssertEqual(MKLocalSearchMock.searchRequest?.naturalLanguageQuery, "search")
    }
    
    func testNominatimSearchProvider(){
        stub(
            condition: isScheme("https")
            && isHost("osm-nominatim.gs.mil")
            && isPath("/search")
            && containsQueryParams(["q":"test search"])
        ) { request in
            XCTAssertEqual(request.headers["User-Agent"], "marlin-ios")
            return HTTPStubsResponse(
                fileAtPath: OHPathForFile("nominatimMockData.json", type(of: self))!,
                statusCode: 200,
                headers: ["Content-Type":"application/json; charset=utf-8"]
            )
        }
        
        var wasCallbackCalled = false
        NominatimSearchProvider.performSearch(searchText: "test search", region: nil) { result in
            XCTAssertEqual(result.count, 4)
            XCTAssertEqual(result[0].name, "Washington, District of Columbia, United States")
            XCTAssertEqual(result[0].placemark.coordinate.latitude, 38.8950368)
            XCTAssertEqual(result[0].placemark.coordinate.longitude, -77.0365427)
            
            XCTAssertEqual(result[1].name, "Washington, United States")
            XCTAssertEqual(result[1].placemark.coordinate.latitude, 0.0)
            XCTAssertEqual(result[1].placemark.coordinate.longitude, 0.0)
            
            XCTAssertEqual(result[2].name, "Washington County, Texas, United States")
            XCTAssertEqual(result[2].placemark.coordinate.latitude, 30.2226352)
            XCTAssertEqual(result[2].placemark.coordinate.longitude, -96.3936114)
            
            XCTAssertEqual(result[3].name, "Washington County, Illinois, United States")
            XCTAssertEqual(result[3].placemark.coordinate.latitude, 38.3662806)
            XCTAssertEqual(result[3].placemark.coordinate.longitude, -89.4201902)
            wasCallbackCalled = true
        }
        tester().wait(forTimeInterval: 1)
        XCTAssertTrue(wasCallbackCalled)
    }
    
    func testNominatimCoordinateSearch(){
        stub(
            condition: isScheme("https")
            && isHost("osm-nominatim.gs.mil")
            && isPath("/search")
            && containsQueryParams(["q": "38.7, -90.3"])
        ) { request in
            return HTTPStubsResponse(
                fileAtPath: OHPathForFile("nominatimMockData.json", type(of: self))!,
                statusCode: 200,
                headers: ["Content-Type":"application/json; charset=utf-8"]
            )
        }
        
        var wasCallbackCalled = false
        NominatimSearchProvider.performSearch(searchText: "38.70, -90.30", region: nil) { result in
            XCTAssertEqual(result.count, 5)
            
            XCTAssertEqual(result[0].name, "38.7, -90.3")
            XCTAssertEqual(result[0].placemark.coordinate.latitude, 38.7)
            XCTAssertEqual(result[0].placemark.coordinate.longitude, -90.3)
            
            XCTAssertEqual(result[1].name, "Washington, District of Columbia, United States")
            XCTAssertEqual(result[1].placemark.coordinate.latitude, 38.8950368)
            XCTAssertEqual(result[1].placemark.coordinate.longitude, -77.0365427)
            
            XCTAssertEqual(result[2].name, "Washington, United States")
            XCTAssertEqual(result[2].placemark.coordinate.latitude, 0.0)
            XCTAssertEqual(result[2].placemark.coordinate.longitude, 0.0)
            
            XCTAssertEqual(result[3].name, "Washington County, Texas, United States")
            XCTAssertEqual(result[3].placemark.coordinate.latitude, 30.2226352)
            XCTAssertEqual(result[3].placemark.coordinate.longitude, -96.3936114)
            
            XCTAssertEqual(result[4].name, "Washington County, Illinois, United States")
            XCTAssertEqual(result[4].placemark.coordinate.latitude, 38.3662806)
            XCTAssertEqual(result[4].placemark.coordinate.longitude, -89.4201902)
            wasCallbackCalled = true
        }
        tester().wait(forTimeInterval: 1)
        XCTAssertTrue(wasCallbackCalled)
    }
}
