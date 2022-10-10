//
//  Modu+Decodable.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import OSLog
import mgrs_ios

struct ModuPropertyContainer: Decodable {
    private enum CodingKeys: String, CodingKey {
        case modu
    }
    let modu: [ModuProperties]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        modu = try container.decode([Throwable<ModuProperties>].self, forKey: .modu).compactMap { try? $0.result.get() }
    }
}

/// A struct encapsulating the properties of a Quake.
struct ModuProperties: Decodable {
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case subregion
        case region
        case longitude
        case latitude
        case distance
        case specialStatus
        case rigStatus
        case position
        case navArea
        case name
        case date
    }
    
    let subregion: Int?
    let region: Int?
    let longitude: Double
    let latitude: Double
    let distance: Double?
    let specialStatus: String?
    let rigStatus: String?
    let position: String?
    let navArea: String?
    let name: String
    let date: Date?
    let mgrs10km: String?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let rawName = try? values.decode(String.self, forKey: .name)
        let rawLatitude = try? values.decode(Double.self, forKey: .latitude)
        let rawLongitude = try? values.decode(Double.self, forKey: .longitude)
        
        guard let name = rawName,
              let latitude = rawLatitude,
              let longitude = rawLongitude
        else {
            let values = "name = \(rawName?.description ?? "nil"), "
            + "latitude = \(rawLatitude?.description ?? "nil"), "
            + "longitude = \(rawLongitude?.description ?? "nil")"
            
            let logger = Logger(subsystem: "mil.nga.msi.Marlin", category: "parsing")
            logger.debug("Ignored: \(values)")
            
            throw MSIError.missingData
        }
        
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.subregion = try? values.decode(Int.self, forKey: .subregion)
        self.region = try? values.decode(Int.self, forKey: .region)
        self.distance = try? values.decode(Double.self, forKey: .distance)
        self.specialStatus = try? values.decode(String.self, forKey: .specialStatus)
        self.rigStatus = try? values.decode(String.self, forKey: .rigStatus)
        self.position = try? values.decode(String.self, forKey: .position)
        self.navArea = try? values.decode(String.self, forKey: .navArea)
        
        var parsedDate: Date? = nil
        if let dateString = try? values.decode(String.self, forKey: .date) {
            if let date = Modu.dateFormatter.date(from: dateString) {
                parsedDate = date
            }
        }
        self.date = parsedDate
        
        let mgrsPosition = MGRS.from(longitude, latitude)
        self.mgrs10km = mgrsPosition.coordinate(.TEN_KILOMETER)
    }
    
    // The keys must have the same name as the attributes of the Modu entity.
    var dictionaryValue: [String: Any?] {
        [
            "subregion": subregion,
            "region": region,
            "longitude": longitude,
            "latitude": latitude,
            "distance": distance,
            "specialStatus": specialStatus,
            "rigStatus": rigStatus,
            "position": position,
            "navArea": navArea,
            "name": name,
            "date": date
        ]
    }
}
