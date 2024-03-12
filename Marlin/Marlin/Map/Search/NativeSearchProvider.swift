//
//  NativeSearchProvider.swift
//  Marlin
//
//  Created by Joshua Nelson on 1/29/24.
//

import Foundation
import MapKit

class NativeSearchProvider<T: MKLocalSearch>: SearchProvider {
    func performSearch(
        searchText: String,
        region: MKCoordinateRegion?,
        onCompletion: @escaping ([SearchResultModel]) -> Void
    ) {
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
                onCompletion([])
                return
            }

            onCompletion(response.mapItems.map({ mapItem in
                SearchResultModel(mapItem: mapItem)
            }))
            Metrics.shared.search(query: realSearch, resultCount: response.mapItems.count)
        }
    }

    func performSearchNear(
        region: MKCoordinateRegion?,
        zoom: Int,
        onCompletion: @escaping ([SearchResultModel]) -> Void
    ) {
        let searchRequest = MKLocalPointsOfInterestRequest(coordinateRegion: region!)
        searchRequest.pointOfInterestFilter = .includingAll
        let search: MKLocalSearch = MKLocalSearch(request: searchRequest)

        search.start { (response, _) in
            guard let response = response else {
                onCompletion([])
                return
            }

            onCompletion(response.mapItems.map({ mapItem in
                SearchResultModel(mapItem: mapItem)
            }))
            Metrics.shared.search(query: "Search Near", resultCount: response.mapItems.count)
        }
    }
}
