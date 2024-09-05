//
//  NavigationalWarningService.swift
//  Marlin
//
//  Created by Daniel Barela on 2/1/24.
//

import Foundation
import Alamofire

enum NavigationalWarningService: URLRequestConvertible {
    case getNavigationalWarnings

    var method: HTTPMethod {
        switch self {
        case .getNavigationalWarnings:
            return .get
        }
    }

    var path: String {
        switch self {
        case .getNavigationalWarnings:
            return "/publications/broadcast-warn"
        }
    }

    var parameters: Parameters? {
        switch self {
        case .getNavigationalWarnings:
            return [
                "status": "active",
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
