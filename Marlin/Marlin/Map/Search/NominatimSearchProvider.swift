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
    let displayName: String
    let lat: String
    let lon: String
}

class NominatimSearchProvider: SearchProvider {
    static func performSearch(
        searchText rawSearchTerm: String,
        region: MKCoordinateRegion?,
        onCompletion: @escaping ([MKMapItem]) -> Void) {
            do {
                var searchTerm = rawSearchTerm
                let parsedLocation = CLLocationCoordinate2D(coordinateString: searchTerm)
                if let location = parsedLocation {
                    searchTerm = "\(location.latitude), \(location.longitude)"
                }
                
                let url = try "https://osm-nominatim.gs.mil".asURL()
                var urlRequest = URLRequest(url: url.appendingPathComponent("/search"))
                urlRequest.httpMethod = HTTPMethod.get.rawValue
                urlRequest.setValue("marlin-ios", forHTTPHeaderField: "User-Agent")
                urlRequest = try URLEncoding.default.encode(urlRequest, with: ["q": searchTerm, "format": "json"])
                URLSession.shared.dataTask(with: urlRequest) { data, _, _ in
                    guard let data = data else {
                        onCompletion([])
                        return
                    }
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let nominatimResponse = try? decoder.decode([NominatimResponseItem].self, from: data)
                    guard let nominatimResponse = nominatimResponse else {
                        onCompletion([])
                        return
                    }
                    
                    var mapItems = nominatimResponse.map { item in
                        let placemark = MKPlacemark(
                            coordinate: CLLocationCoordinate2D(
                                latitude: Double(item.lat) ?? 0.0,
                                longitude: Double(item.lon) ?? 0.0))
                        let mapItem = MKMapItem(placemark: placemark)
                        mapItem.name = item.displayName
                        return mapItem
                    }
                    if let location = parsedLocation {
                        let coordPlacemark = MKPlacemark(coordinate: location)
                        let coordMapItem = MKMapItem(placemark: coordPlacemark)
                        coordMapItem.name = "\(location.latitude), \(location.longitude)"
                        mapItems.insert(coordMapItem, at: 0)
                    }
                    onCompletion(mapItems)
                    return
                }.resume()
            } catch {
                onCompletion([])
                return
            }
        }
}
