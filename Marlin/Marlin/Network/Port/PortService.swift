//
//  PortService.swift
//  Marlin
//
//  Created by Daniel Barela on 1/30/24.
//

import Foundation
import Alamofire

enum PortService: URLRequestConvertible {
    case getPorts

    var method: HTTPMethod {
        switch self {
        case .getPorts:
            return .get
        }
    }

    var path: String {
        switch self {
        case .getPorts:
            return "/publications/world-port-index"
        }
    }

    var parameters: Parameters? {
        switch self {
        case .getPorts:
            return [
                "output": "json"
            ]
        }
    }

    // MARK: URLRequestConvertible

    func asURLRequest() throws -> URLRequest {
        let url = try MSIRouter.baseURLString.asURL()

        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue

        urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)

        return urlRequest
    }
}
