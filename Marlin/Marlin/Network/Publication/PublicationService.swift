//
//  PublicationService.swift
//  Marlin
//
//  Created by Daniel Barela on 2/1/24.
//

import Foundation
import Alamofire

enum PublicationService: URLRequestConvertible {
    case getPublications

    var method: HTTPMethod {
        switch self {
        case .getPublications:
            return .get
        }
    }

    var path: String {
        switch self {
        case .getPublications:
            return "/publications/stored-pubs"
        }
    }

    var parameters: Parameters? {
        switch self {
        case .getPublications:
            return [:]
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
