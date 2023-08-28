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
    case readAsams(date: String? = nil)
    case readModus(date: String? = nil)
    case readNavigationalWarnings
    case readLights(volume: String, noticeYear: String? = nil, noticeWeek: String? = nil)
    case readPorts
    case readRadioBeacons(noticeYear: String? = nil, noticeWeek: String? = nil)
    case readDifferentialGPSStations(volume: String? = nil, noticeYear: String? = nil, noticeWeek: String? = nil)
    case readDFRS
    case readDFRSAreas
    case readElectronicPublications
    case readNoticeToMariners(noticeNumber: Int64? = nil)
    
    static let baseURLString = "https://msi.nga.mil/api"
    static let ntmGraphicKeyBase = "16920957/SFH00000/UNTM"
    
    var method: HTTPMethod
    {
        switch self {
        case .readAsams:
            return .get
        case .readModus:
            return .get
        case .readNavigationalWarnings:
            return .get
        case .readLights:
            return .get
        case .readPorts:
            return .get
        case .readRadioBeacons:
            return .get
        case .readDifferentialGPSStations:
            return .get
        case .readDFRS:
            return .get
        case .readDFRSAreas:
            return .get
        case .readElectronicPublications:
            return .get
        case .readNoticeToMariners:
            return .get
        }
    }
    
    var path: String
    {
        switch self {
        case .readAsams:
            return "/publications/asam"
        case .readModus:
            return "/publications/modu"
        case .readNavigationalWarnings:
            return "/publications/broadcast-warn"
        case .readLights:
            return "/publications/ngalol/lights-buoys"
        case .readPorts:
            return "/publications/world-port-index"
        case .readRadioBeacons:
            return "/publications/ngalol/radiobeacons"
        case .readDifferentialGPSStations:
            return "/publications/ngalol/dgpsstations"
        case .readDFRS:
            return "/publications/radio-navaids/dfrs"
        case .readDFRSAreas:
            return "/publications/radio-navaids/dfrs/areas"
        case .readElectronicPublications:
            return "/publications/stored-pubs"
        case .readNoticeToMariners:
            return "/publications/ntm/pubs"
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .readAsams(date: _):
            // we cannot reliably query for asams that occured after the date we have because
            // records can be inserted with an occurance date in the past
            // we have to query for all records all the time
            let params = [
                "sort": "date",
                "output": "json",
//                "maxOccurDate": Asam.dateFormatter.string(from:Calendar.current.date(byAdding: .hour, value: 24, to: Date()) ?? Date())
            ]
//            if let date = date {
//                params["minOccurDate"] = date
//            }
            return params
        case .readModus(date: let date):
            var params = [
                "maxSourceDate": Modu.dateFormatter.string(from:Calendar.current.date(byAdding: .hour, value: 24, to: Date()) ?? Date()),
                "output": "json"
            ]
            if let date = date {
                params["minSourceDate"] = date
            }
            return params
        case .readNavigationalWarnings:
            return [
                "output": "json"
            ]
        case .readLights(volume: let volume, noticeYear: let noticeYear, noticeWeek: let noticeWeek):
            var params = [
                "output": "json",
                "includeRemovals": false,
                "volume":volume
            ] as [String : Any]
            if let noticeYear = noticeYear, let noticeWeek = noticeWeek {
                let calendar = Calendar.current
                let week = calendar.component(.weekOfYear, from: Date())
                let year = calendar.component(.year, from: Date())
                params["minNoticeNumber"] = "\(noticeYear)\(noticeWeek)"
                params["maxNoticeNumber"] = "\(year)\(String(format: "%02d", week + 1))"
            }
            return params
        case .readPorts:
            return [
                "output": "json"
            ]
        case .readRadioBeacons(noticeYear: let noticeYear, noticeWeek: let noticeWeek):
            var params = [
                "output": "json",
                "includeRemovals": false
            ] as [String : Any]
            if let noticeYear = noticeYear, let noticeWeek = noticeWeek {
                let calendar = Calendar.current
                let week = calendar.component(.weekOfYear, from: Date())
                let year = calendar.component(.year, from: Date())
                params["minNoticeNumber"] = "\(noticeYear)\(noticeWeek)"
                params["maxNoticeNumber"] = "\(year)\(String(format: "%02d", week + 1))"
            }
            return params
        case .readDifferentialGPSStations(volume: let volume, noticeYear: let noticeYear, noticeWeek: let noticeWeek):
            var params = [
                "output": "json",
                "includeRemovals": false
            ] as [String : Any]
            if let volume = volume {
                params["volume"] = volume
            }
            if let noticeYear = noticeYear, let noticeWeek = noticeWeek {
                let calendar = Calendar.current
                let week = calendar.component(.weekOfYear, from: Date())
                let year = calendar.component(.year, from: Date())
                params["minNoticeNumber"] = "\(noticeYear)\(noticeWeek)"
                params["maxNoticeNumber"] = "\(year)\(String(format: "%02d", week + 1))"
            }
            return params
        case .readDFRS:
            return [
                "output": "json"
            ]
        case .readDFRSAreas:
            return [:]
        case .readElectronicPublications:
            return [:]
        case .readNoticeToMariners(noticeNumber: let noticeNumber):
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
    
    func asURLRequest() throws -> URLRequest
    {
        let url = try MSIRouter.baseURLString.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
        urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        
        return urlRequest
    }
}
