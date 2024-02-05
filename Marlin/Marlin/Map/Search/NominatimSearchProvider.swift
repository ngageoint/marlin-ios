//
//  NominatimSearchProvider.swift
//  Marlin
//
//  Created by Joshua Nelson on 1/30/24.
//

import Foundation
import MapKit
import Alamofire

struct NominatimResponseItem: Decodable {
    let name: String
    let displayName: String
    let lat: String
    let lon: String
}

class NominatimSearchProvider: SearchProvider {
    static func performSearch(
        searchText: String,
        region: MKCoordinateRegion?,
        callback: @escaping ([MKMapItem]) -> Void) {
            do {
                let url = try "https://nominatim.openstreetmap.org".asURL()
                var urlRequest = URLRequest(url: url.appendingPathComponent("/search"))
                urlRequest.httpMethod = HTTPMethod.get.rawValue
                urlRequest = try URLEncoding.default.encode(urlRequest, with: ["q": searchText, "format": "json"])
                
                URLSession.shared.dataTask(with: urlRequest) { data, _, _ in
                    guard let data = data else {
                        callback([])
                        return
                    }
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let nominatimResponse = try? decoder.decode([NominatimResponseItem].self, from: data)
                    guard let nominatimResponse = nominatimResponse else {
                        callback([])
                        return
                    }
                    
                    let mapItems = nominatimResponse.map { item in
                        let placemark = MKPlacemark(
                            coordinate: CLLocationCoordinate2D(
                                latitude: Double(item.lat) ?? 0.0,
                                longitude: Double(item.lon) ?? 0.0))
                        let mapItem = MKMapItem(placemark: placemark)
                        mapItem.name = item.displayName
                        return mapItem
                    }
                    callback(mapItems)
                    return
                }.resume()
            } catch {
                callback([])
                return
            }
        }
}
