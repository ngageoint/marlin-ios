//
//  SearchRepository.swift
//  Marlin
//
//  Created by Daniel Barela on 3/6/24.
//

import Foundation
import MapKit

class SearchRepository {
    func performSearch(
        searchText: String,
        region: MKCoordinateRegion?
    ) async -> [MKMapItem]? {
        await withCheckedContinuation { continuation in
            switch UserDefaults.standard.searchType {
            case .native:
                NativeSearchProvider.performSearch(searchText: searchText, region: region) { result in
                    continuation.resume(returning: result)
                }
            case .nominatim:
                NominatimSearchProvider.performSearch(searchText: searchText, region: region) { result in
                    continuation.resume(returning: result)
                }
            }
        }
    }
}
