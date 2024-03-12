//
//  SearchRepository.swift
//  Marlin
//
//  Created by Daniel Barela on 3/6/24.
//

import Foundation
import MapKit

struct NominatimResponseItem: Decodable, Hashable {
    var displayName: String
    var lat: String
    var lon: String
    var placeId: Int?
    var licence: String?
    var osmType: String?
    var osmId: Int?
    var address: SearchAddress?
    var boundingbox: [String]?
    var importance: Double?
    var icon: String?
}

struct SearchAddress: Decodable, Hashable {
    var state: String?
    var country: String?
    var countryCode: String?
    var leisure: String?
    var houseNumber: String?
    var road: String?
    var residential: String?
    var county: String?
    var postcode: String?
    var amenity: String?
    var continent: String?
    var region: String?
    var stateDistrict: String?
    var municipality: String?
    var city: String?
    var town: String?
    var village: String?
    var cityDistrict: String?
    var district: String?
    var borough: String?
    var suburb: String?
    var subdivision: String?
    var hamlet: String?
    var croft: String?
    var isolatedDwelling: String?
    var neighbourhood: String?
    var allotments: String?
    var quarter: String?
    var cityBlock: String?
    var farm: String?
    var farmyard: String?
    var industrial: String?
    var commercial: String?
    var retail: String?
    var houseName: String?
    var emergency: String?
    var historic: String?
    var military: String?
    var natural: String?
    var landuse: String?
    var place: String?
    var railway: String?
    var manMade: String?
    var aerialway: String?
    var boundary: String?
    var aeroway: String?
    var club: String?
    var craft: String?
    var office: String?
    var mountainPass: String?
    var shop: String?
    var tourism: String?
    var bridge: String?
    var tunnel: String?
    var waterway: String?
}

extension SearchAddress {
    init(placemark: MKPlacemark) {
        country = placemark.country
        countryCode = placemark.countryCode
        residential = placemark.thoroughfare
        road = placemark.subThoroughfare
        city = placemark.locality
        cityDistrict = placemark.subLocality
        state = placemark.administrativeArea
        stateDistrict = placemark.subAdministrativeArea
        postcode = placemark.postalCode
        waterway = placemark.inlandWater ?? placemark.ocean
    }
}

struct SearchResultModel: Identifiable, Hashable, Locatable, Decodable {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var id: String { "\(lat),\(lon)" }

    var displayName: String
    var lat: String
    var lon: String
    var placeId: Int?
    var licence: String?
    var osmType: String?
    var osmId: Int?
    var address: SearchAddress?
    var boundingbox: [String]?
    var importance: Double?
    var icon: String?

    var latitude: Double {
        Double(lat) ?? kCLLocationCoordinate2DInvalid.latitude
    }
    var longitude: Double {
        Double(lon) ?? kCLLocationCoordinate2DInvalid.longitude
    }
}

extension SearchResultModel {
    init(mapItem: MKMapItem) {
        displayName = mapItem.placemark.title
        ?? "\(mapItem.placemark.coordinate.latitude), \(mapItem.placemark.coordinate.longitude)"
        lat = "\(mapItem.placemark.coordinate.latitude)"
        lon = "\(mapItem.placemark.coordinate.longitude)"
        address = SearchAddress(placemark: mapItem.placemark)
    }
}

class SearchRepository: ObservableObject {
    var latestResults: [SearchResultModel] = []

    var native: SearchProvider?
    var nominatim: SearchProvider?

    init(native: SearchProvider? = nil, nominatim: SearchProvider? = nil) {
        self.native = native
        self.nominatim = nominatim
    }

    func getResult(id: String) -> SearchResultModel? {
        return latestResults.first { model in
            model.id == id
        }
    }

    func performSearch(
        searchText: String,
        region: MKCoordinateRegion?
    ) async -> [SearchResultModel]? {
        latestResults = await withCheckedContinuation { continuation in
            switch UserDefaults.standard.searchType {
            case .native:
                guard let native = native else { 
                    continuation.resume(returning: [])
                    return
                }
                native.performSearch(searchText: searchText, region: region) { result in
                    continuation.resume(returning: result)
                }
            case .nominatim:
                guard let nominatim = nominatim else { 
                    continuation.resume(returning: [])
                    return
                }
                nominatim.performSearch(searchText: searchText, region: region) { result in
                    continuation.resume(returning: result)
                }
            }
        }
        return latestResults
    }

    func performSearchNear(
        region: MKCoordinateRegion?,
        zoom: Int
    ) async -> [SearchResultModel]? {
        latestResults = await withCheckedContinuation { continuation in
            switch UserDefaults.standard.searchType {
            case .native:
                guard let native = native else {
                    continuation.resume(returning: [])
                    return
                }
                native.performSearchNear(region: region, zoom: zoom) { result in
                    continuation.resume(returning: result)
                }
            case .nominatim:
                guard let nominatim = nominatim else {
                    continuation.resume(returning: [])
                    return
                }
                nominatim.performSearchNear(region: region, zoom: zoom) { result in
                    continuation.resume(returning: result)
                }
            }
        }
        return latestResults
    }
}
