//
//  AsamRouter.swift
//  Marlin
//
//  Created by Daniel Barela on 11/2/23.
//

import Foundation
import Alamofire

enum AsamService: URLRequestConvertible
{
    case getAsams(date: String? = nil)
        
    var method: HTTPMethod
    {
        switch self {
        case .getAsams:
            return .get
        }
    }
    
    var path: String
    {
        switch self {
        case .getAsams:
            return "/publications/asam"
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .getAsams(date: _):
            // we cannot reliably query for asams that occured after the date we have because
            // records can be inserted with an occurance date in the past
            // we have to query for all records all the time
            let params = [
                "sort": "date",
                "output": "json",
            ]
            return params
        }
    }
    
    // MARK: URLRequestConvertible
    
    func asURLRequest() throws -> URLRequest
    {
        let url = try MSIRouter.baseURLString.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
        urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        
        return urlRequest
    }
}
