//
//  SearchProvider.swift
//  Marlin
//
//  Created by Joshua Nelson on 1/29/24.
//

import Foundation
import MapKit

protocol SearchProvider {
    func performSearch(
        searchText: String,
        region: MKCoordinateRegion?,
        onCompletion: @escaping ([SearchResultModel]) -> Void
    )

    func performSearchNear(
        region: MKCoordinateRegion?,
        zoom: Int,
        onCompletion: @escaping ([SearchResultModel]) -> Void
    )
}
