//
//  SearchResultsMapTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/30/23.
//

import XCTest
import SwiftUI
import Combine
import CoreLocation
import MapKit

@testable import Marlin

final class SearchResultsMapTests: XCTestCase {

    override func setUp() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults()
    }
    
    override func tearDown() {
    }
    
    func testSearchResultMap() {
        
        UserDefaults.standard.set(Int(MKMapType.standard.rawValue), forKey: "mapType")
        UserDefaults.standard.mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0), latitudinalMeters: 10000, longitudinalMeters: 10000)
        
        class PassThrough {
            @Published var searchResults: [MKMapItem]?
            var searchResultMap: SearchResultsMap
            init(searchResultMap: SearchResultsMap) {
                self.searchResultMap = searchResultMap
            }
        }
        
        class SearchResultsMixins: MapMixins {
            override init() {
                super.init()
                self.mixins = [SearchResultsMap()]
            }
        }
        
        struct Container: View {
            @StateObject var mapState: MapState = MapState()
            @State var filterOpen: Bool = false
            
            var passThrough: PassThrough
            @StateObject var mixins: SearchResultsMixins = SearchResultsMixins()

            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                ZStack {
                    MarlinMap(name: "Marlin Compact Map", mixins: mixins, mapState: mapState)
                }
                .onAppear {
                    if let searchResults = passThrough.searchResults {
                        mapState.searchResults = searchResults.map({ mapItem in
                            SearchResultModel(mapItem: mapItem)
                        })
                    }
                }
            }
        }
        let searchResultMap = SearchResultsMap()
        let appState = AppState()
        let passThrough = PassThrough(searchResultMap: searchResultMap)
        let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0))
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Test item"
        mapItem.pointOfInterestCategory = .airport
        
        passThrough.searchResults = [
            mapItem
        ]
        
        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "Test item\n\n, United States")
    }
}
