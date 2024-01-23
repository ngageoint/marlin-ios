//
//  ModuService.swift
//  Marlin
//
//  Created by Daniel Barela on 1/22/24.
//

import Foundation
import Alamofire

enum ModuService: URLRequestConvertible {
    case getModus(date: String? = nil)

    var method: HTTPMethod {
        switch self {
        case .getModus:
            return .get
        }
    }

    var path: String {
        switch self {
        case .getModus:
            return "/publications/modu"
        }
    }

    var parameters: Parameters? {
        switch self {
        case .getModus(date: let date):
            var params = [
                "maxSourceDate": Modu.dateFormatter.string(
                    from: Calendar.current.date(byAdding: .hour, value: 24, to: Date()) ?? Date()),
                "output": "json"
            ]
            if let date = date {
                params["minSourceDate"] = date
            }
            return params
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
