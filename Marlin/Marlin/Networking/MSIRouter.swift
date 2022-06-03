//
//  MSIRouter.swift
//  Marlin
//
//  Created by Daniel Barela on 6/3/22.
//

import Foundation
import Alamofire

enum MSIRouter: URLRequestConvertible
{
    case readAsams(parameters: Parameters? = nil)
    case readUser(username: String)
    case updateUser(username: String, parameters: Parameters)
    case destroyUser(username: String)
    
    static let baseURLString = "https://msi.om.east.paas.nga.mil/api"
    
    var method: HTTPMethod
    {
        switch self {
        case .readAsams:
            return .get
        case .readUser:
            return .get
        case .updateUser:
            return .put
        case .destroyUser:
            return .delete
        }
    }
    
    var path: String
    {
        switch self {
        case .readAsams:
            return "/publications/asam"
        case .readUser(let username):
            return "/users/\(username)"
        case .updateUser(let username, _):
            return "/users/\(username)"
        case .destroyUser(let username):
            return "/users/\(username)"
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .readAsams:
            return [
                "sort": "date",
                "output": "json"
            ]
        case .readUser(username: let username):
            return [:]
        case .updateUser(username: let username, parameters: let parameters):
            return [:]
        case .destroyUser(username: let username):
            return [:]
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
