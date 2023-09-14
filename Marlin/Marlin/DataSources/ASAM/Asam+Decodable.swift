//
//  Asam+Decodable.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import CoreLocation
import OSLog
import mgrs_ios

struct AsamPropertyContainer: Decodable {
    private enum CodingKeys: String, CodingKey {
        case asam
    }
    let asam: [AsamProperties]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        asam = try container.decode([Throwable<AsamProperties>].self, forKey: .asam).compactMap { try? $0.result.get() }
    }
}

struct AsamProperties: Decodable {
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case reference
        case position
        case navArea
        case subreg
        case hostility
        case victim
        case latitude
        case longitude
        case asamDescription = "description"
        case date
    }
    
    private enum InternalCodingKeys: String, CodingKey {
        case description
    }
    
    let reference: String?
    let latitude: Double
    let longitude: Double
    let position: String?
    let navArea: String?
    let subreg: String?
    let hostility: String?
    let victim: String?
    var asamDescription: String?
    let date: Date?
    let mgrs10km: String?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let rawReference = try? values.decode(String.self, forKey: .reference)
        let rawLatitude = try? values.decode(Double.self, forKey: .latitude)
        let rawLongitude = try? values.decode(Double.self, forKey: .longitude)
        
        guard let reference = rawReference,
              let latitude = rawLatitude,
              let longitude = rawLongitude
        else {
            let values = "reference = \(rawReference?.description ?? "nil"), "
            + "latitude = \(rawLatitude?.description ?? "nil"), "
            + "longitude = \(rawLongitude?.description ?? "nil")"
            
            let logger = Logger(subsystem: "mil.nga.msi.Marlin", category: "parsing")
            logger.info("Ignored: \(values)")
            
            throw MSIError.missingData
        }
        
        self.reference = reference
        self.latitude = latitude
        self.longitude = longitude
        self.position = try? values.decode(String.self, forKey: .position)
        self.navArea = try? values.decode(String.self, forKey: .navArea)
        self.subreg = try? values.decode(String.self, forKey: .subreg)
        self.hostility = try? values.decode(String.self, forKey: .hostility)
        self.victim = try? values.decode(String.self, forKey: .victim)
        self.asamDescription = try? values.decode(String.self, forKey: .asamDescription)
        if self.asamDescription == nil {
            let otherValues = try decoder.container(keyedBy: InternalCodingKeys.self)
            self.asamDescription = try otherValues.decode(String.self, forKey: .description)
        }
        var parsedDate: Date? = nil
        if let dateString = try? values.decode(String.self, forKey: .date) {
            if let date = Asam.dateFormatter.date(from: dateString) {
                parsedDate = date
            }
        }
        self.date = parsedDate
        
        let mgrsPosition = MGRS.from(longitude, latitude)
        self.mgrs10km = mgrsPosition.coordinate(.TEN_KILOMETER)
    }
    
    // The keys must have the same name as the attributes of the Asam entity.
    var dictionaryValue: [String: Any?] {
        [
            "reference": reference,
            "latitude": latitude,
            "longitude": longitude,
            "position": position,
            "navArea": navArea,
            "subreg": subreg,
            "hostility": hostility,
            "victim": victim,
            "asamDescription": asamDescription,
            "date": date,
            "mgrs10km": mgrs10km
        ]
    }
}

