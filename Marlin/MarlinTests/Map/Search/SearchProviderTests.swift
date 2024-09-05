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
        NativeSearchProvider<MKLocalSearchMock>().performSearch(searchText: "search", region: nil) { result in
            XCTAssertEqual(result[0].name, "Test item")
            XCTAssertEqual(result[0].coordinate.latitude, 1.0)
            XCTAssertEqual(result[0].coordinate.longitude, 1.0)
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
        NominatimSearchProvider().performSearch(searchText: "test search", region: nil) { result in
            XCTAssertEqual(result.count, 4)
            XCTAssertEqual(result[0].displayName, "Washington, District of Columbia, United States")
            XCTAssertEqual(result[0].coordinate.latitude, 38.8950368)
            XCTAssertEqual(result[0].coordinate.longitude, -77.0365427)
            
            XCTAssertEqual(result[1].displayName, "Washington, United States")
            XCTAssertEqual(result[1].coordinate.latitude, -180.0)
            XCTAssertEqual(result[1].coordinate.longitude, -180.0)
            
            XCTAssertEqual(result[2].displayName, "Washington County, Texas, United States")
            XCTAssertEqual(result[2].coordinate.latitude, 30.2226352)
            XCTAssertEqual(result[2].coordinate.longitude, -96.3936114)
            
            XCTAssertEqual(result[3].displayName, "Washington County, Illinois, United States")
            XCTAssertEqual(result[3].coordinate.latitude, 38.3662806)
            XCTAssertEqual(result[3].coordinate.longitude, -89.4201902)
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
        NominatimSearchProvider().performSearch(searchText: "38.70, -90.30", region: nil) { result in
            XCTAssertEqual(result.count, 5)
            
            let results = result.sorted { one, two in
                one.placeId ?? 0 < two.placeId ?? 0
            }
            
            XCTAssertEqual(result[0].displayName, "Washington, District of Columbia, United States")
            XCTAssertEqual(result[0].coordinate.latitude, 38.8950368)
            XCTAssertEqual(result[0].coordinate.longitude, -77.0365427)
            
            XCTAssertEqual(result[1].displayName, "Washington, United States")
            XCTAssertEqual(result[1].coordinate.latitude, -180.0)
            XCTAssertEqual(result[1].coordinate.longitude, -180.0)
            
            XCTAssertEqual(result[2].displayName, "Washington County, Texas, United States")
            XCTAssertEqual(result[2].coordinate.latitude, 30.2226352)
            XCTAssertEqual(result[2].coordinate.longitude, -96.3936114)
            
            XCTAssertEqual(result[3].displayName, "Washington County, Illinois, United States")
            XCTAssertEqual(result[3].coordinate.latitude, 38.3662806)
            XCTAssertEqual(result[3].coordinate.longitude, -89.4201902)
            
            XCTAssertEqual(result[4].displayName, "38.7, -90.3")
            XCTAssertEqual(result[4].coordinate.latitude, 38.7)
            XCTAssertEqual(result[4].coordinate.longitude, -90.3)
            
            wasCallbackCalled = true
        }
        tester().wait(forTimeInterval: 1)
        XCTAssertTrue(wasCallbackCalled)
    }
}
