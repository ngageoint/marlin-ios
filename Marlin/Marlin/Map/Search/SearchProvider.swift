//
//  SearchProvider.swift
//  Marlin
//
//  Created by Joshua Nelson on 1/29/24.
//

import Foundation
import MapKit

protocol SearchProvider {
    static func performSearch(
        searchText: String,
        region: MKCoordinateRegion?,
        callback: @escaping ([MKMapItem]) -> Void)
}
