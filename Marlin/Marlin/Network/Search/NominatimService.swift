//
//  NominatimService.swift
//  Marlin
//
//  Created by Daniel Barela on 3/11/24.
//

import Foundation
import Alamofire

enum NominatimService: URLRequestConvertible {
    static let nominatimURL = "https://osm-nominatim.gs.mil"

    case textSearch(query: String? = nil)
    case boundedSearch(minLat: Double, minLon: Double, maxLat: Double, maxLon: Double, query: String? = nil)
    case reverse(lat: Double, lon: Double, zoom: Int)

    var method: HTTPMethod {
        switch self {
        case .textSearch:
            return .get
        case .boundedSearch:
            return .get
        case .reverse:
            return .get
        }
    }

    var path: String {
        switch self {
        case .textSearch:
            return "/search"
        case .boundedSearch:
            return "/search"
        case .reverse:
            return "/reverse"
        }
    }

    var parameters: Parameters? {
        switch self {
        case .textSearch(let query):
            let params = [
                "q": query ?? "",
                "format": "json"
            ]
            return params
        case .boundedSearch(let minLat, let minLon, let maxLat, let maxLon, let query):
            let params = [
                "q": query ?? "",
                "bounded": "1",
                "viewbox": "\(minLon),\(minLat),\(maxLon),\(maxLat)",
                "format": "json"
            ]
            return params
        case .reverse(let lat, let lon, let zoom):
            let params = [
                "zoom": "\(zoom)",
                "lat": "\(lat)",
                "lon": "\(lon)",
                "format": "json"
            ]
            return params
        }
    }

    var headers: HTTPHeaders? {
        switch self {
        case .textSearch:
            return [HTTPHeader.userAgent("marlin-ios")]
        case .boundedSearch:
            return [HTTPHeader.userAgent("marlin-ios")]
        case .reverse:
            return [HTTPHeader.userAgent("marlin-ios")]
        }
    }

    // MARK: URLRequestConvertible

    func asURLRequest() throws -> URLRequest {
        let url = try NominatimService.nominatimURL.asURL()

        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        if let headers = headers {
            urlRequest.headers = headers
        }

        urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)

        return urlRequest
    }
}
