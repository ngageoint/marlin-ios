//
//  NoticeToMarinersService.swift
//  Marlin
//
//  Created by Daniel Barela on 2/1/24.
//

import Foundation
import Alamofire

enum NoticeToMarinersService: URLRequestConvertible {
    case getNoticeToMariners(noticeNumber: Int64? = nil)

    var method: HTTPMethod {
        switch self {
        case .getNoticeToMariners:
            return .get
        }
    }

    var path: String {
        switch self {
        case .getNoticeToMariners:
            return "/publications/ntm/pubs"
        }
    }

    var parameters: Parameters? {
        switch self {
        case .getNoticeToMariners(noticeNumber: let noticeNumber):
            var params = [
                "output": "json"
            ]
            if let noticeNumber = noticeNumber {
                let calendar = Calendar.current
                let week = calendar.component(.weekOfYear, from: Date())
                let year = calendar.component(.year, from: Date())
                params["minNoticeNumber"] = "\(noticeNumber)"
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
