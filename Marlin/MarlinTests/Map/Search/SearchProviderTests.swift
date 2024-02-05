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
        NativeSearchProvider<MKLocalSearchMock2>.performSearch(searchText: "search", region: nil) { result in
            XCTAssertEqual(result[0].name, "Test item")
            XCTAssertEqual(result[0].pointOfInterestCategory, .airport)
        }
        XCTAssertEqual(MKLocalSearchMock.searchRequest?.naturalLanguageQuery, "search")
    }
    
    func testNominatimSearchProvider(){
        stub(
            condition: isScheme("https")
            && isHost("nominatim.openstreetmap.org")
            && isPath("/search")
            && containsQueryParams(["q":"test search"])
        ) { request in
            return HTTPStubsResponse(
                fileAtPath: OHPathForFile("nominatimMockData.json", type(of: self))!,
                statusCode: 200,
                headers: ["Content-Type":"application/json; charset=utf-8"]
            )
        }
        
        var wasCallbackCalled = false
        NominatimSearchProvider.performSearch(searchText: "test search", region: nil) { result in
            XCTAssertEqual(result[0].name, "Washington, District of Columbia, United States")
            wasCallbackCalled = true
        }
        tester().wait(forTimeInterval: 1)
        XCTAssertTrue(wasCallbackCalled)
    }
}

class MKLocalSearchMock2: MKLocalSearch {
    
    static var searchRequest: MKLocalSearch.Request?
    static var results: [MKMapItem]?
    
    override init(request: MKLocalSearch.Request) {
        super.init(request: request)
        MKLocalSearchMock.searchRequest = request
    }
    
    override func start(completionHandler: @escaping MKLocalSearch.CompletionHandler) {
        let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0))
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Test item"
        mapItem.pointOfInterestCategory = .airport
        
        let mapItems = MKLocalSearchMock.results ?? [mapItem]
        let response: MKLocalSearch.Response = MockMKLocalSearchResponse(mapItems: mapItems)
        completionHandler(response, nil)
    }
}
