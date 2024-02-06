//
//  NativeSearchProvider.swift
//  Marlin
//
//  Created by Joshua Nelson on 1/29/24.
//

import Foundation
import MapKit

class NativeSearchProvider<T: MKLocalSearch>: SearchProvider {
    static func performSearch(
        searchText: String,
        region: MKCoordinateRegion?,
        onCompletion: @escaping ([MKMapItem]) -> Void) {
            var realSearch = searchText
            // check if they maybe entered coordinates
            if let location = CLLocationCoordinate2D(coordinateString: searchText) {
                NSLog("This is a location")
                // just send the location to the search
                realSearch = "\(location.latitude), \(location.longitude)"
            }
            
            let searchRequest = T.Request()
            searchRequest.naturalLanguageQuery = realSearch
            
            // Set the region to an associated map view's region.
            if let region = region {
                searchRequest.region = region
            }
            
            let search = T.init(request: searchRequest)
            
            search.start { (response, _) in
                guard let response = response else {
                    // Handle the error.
                    onCompletion([])
                    return
                }
                
                onCompletion(response.mapItems)
                Metrics.shared.search(query: realSearch, resultCount: response.mapItems.count)
            }
        }
}
