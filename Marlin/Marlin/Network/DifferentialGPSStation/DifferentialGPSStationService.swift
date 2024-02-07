//
//  DifferentialGPSStationsService.swift
//  Marlin
//
//  Created by Daniel Barela on 2/1/24.
//

import Foundation
import Alamofire

enum DifferentialGPSStationService: URLRequestConvertible {
    case getDifferentialGPSStations(noticeYear: String? = nil, noticeWeek: String? = nil)

    var method: HTTPMethod {
        switch self {
        case .getDifferentialGPSStations:
            return .get
        }
    }

    var path: String {
        switch self {
        case .getDifferentialGPSStations:
            return "/publications/ngalol/dgpsstations"
        }
    }

    var parameters: Parameters? {
        switch self {
        case .getDifferentialGPSStations(noticeYear: let noticeYear, noticeWeek: let noticeWeek):
            var params = [
                "output": "json",
                "includeRemovals": false
            ] as [String: Any]
            if let noticeYear = noticeYear, let noticeWeek = noticeWeek {
                let calendar = Calendar.current
                let week = calendar.component(.weekOfYear, from: Date())
                let year = calendar.component(.year, from: Date())
                params["minNoticeNumber"] = "\(noticeYear)\(noticeWeek)"
                params["maxNoticeNumber"] = "\(year)\(String(format: "%02d", week + 1))"
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
