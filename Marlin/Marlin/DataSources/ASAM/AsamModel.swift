//
//  AsamModel.swift
//  Marlin
//
//  Created by Daniel Barela on 9/15/23.
//

import Foundation
import CoreLocation
import GeoJSON
import UIKit
import OSLog
import mgrs_ios

struct AsamListModel: Hashable, Identifiable {
    var id: String {
        reference ?? ""
    }
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var asamDescription: String?
    var date: Date?
    var hostility: String?
    var latitude: Double
    var longitude: Double
    var reference: String?
    var victim: String?
    
    var canBookmark: Bool = false
    
    init(asam: Asam) {
        self.canBookmark = true
        self.asamDescription = asam.asamDescription
        self.date = asam.date
        self.hostility = asam.hostility
        self.latitude = asam.latitude
        self.longitude = asam.longitude
        self.reference = asam.reference
        self.victim = asam.victim
    }
}

extension AsamListModel {
    var dateString: String? {
        if let date = date {
            return DataSources.asam.dateFormatter.string(from: date)
        }
        return nil
    }
    
    var itemTitle: String {
        return "\(self.hostility ?? "")\(self.hostility != nil && self.victim != nil ? ": " : "")\(self.victim ?? "")"
    }
}

extension AsamListModel: Bookmarkable {
    static var definition: any DataSourceDefinition {
        DataSources.asam
    }
    
    var itemKey: String {
        return reference ?? ""
    }
    
    var key: String {
        DataSources.asam.key
    }
}

extension AsamListModel {
    init(asamModel: AsamModel) {
        self.canBookmark = asamModel.canBookmark
        self.asamDescription = asamModel.asamDescription
        self.date = asamModel.date
        self.hostility = asamModel.hostility
        self.latitude = asamModel.latitude
        self.longitude = asamModel.longitude
        self.reference = asamModel.reference
        self.victim = asamModel.victim
    }
}

struct AsamModel: Locatable, Bookmarkable, Codable, GeoJSONExportable, Hashable, Identifiable {
    var id: String {
        reference ?? ""
    }
    var itemKey: String {
        return reference ?? ""
    }
    static var definition: any DataSourceDefinition = DataSourceDefinitions.asam.definition
    var sfGeometry: SFGeometry? {
        return SFPoint(xValue: coordinate.longitude, andYValue: coordinate.latitude)
    }
    
    var canBookmark: Bool = false
    
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
        case asamDescription
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    var asam: Asam?
    var asamDescription: String?
    var date: Date?
    var hostility: String?
    var latitude: Double
    var longitude: Double
    var mgrs10km: String?
    var navArea: String?
    var position: String?
    var reference: String?
    var subreg: String?
    var victim: String?
    
    func isEqualTo(_ other: AsamModel) -> Bool {
//        return self.asam == other.asam
        return self.reference == other.reference
    }
    
    static func == (lhs: AsamModel, rhs: AsamModel) -> Bool {
        lhs.isEqualTo(rhs)
    }
    
    init() {
        self.canBookmark = false
        self.latitude = kCLLocationCoordinate2DInvalid.latitude
        self.longitude = kCLLocationCoordinate2DInvalid.longitude
    }
    
    init(asam: Asam) {
        self.canBookmark = true
        self.asam = asam
        self.asamDescription = asam.asamDescription
        self.date = asam.date
        self.hostility = asam.hostility
        self.latitude = asam.latitude
        self.longitude = asam.longitude
        self.mgrs10km = asam.mgrs10km
        self.navArea = asam.navArea
        self.position = asam.position
        self.reference = asam.reference
        self.subreg = asam.subreg
        self.victim = asam.victim
    }
    
    init?(feature: Feature) {
        if let json = try? JSONEncoder().encode(feature.properties), let string = String(data: json, encoding: .utf8) {
            
            let decoder = JSONDecoder()
            let jsonData = Data(string.utf8)
            
            if let model = try? decoder.decode(AsamModel.self, from: jsonData) {
                self = model
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
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
            self.asamDescription = try? otherValues.decode(String.self, forKey: .asamDescription)
        }
        var parsedDate: Date?
        if let dateString = try? values.decode(String.self, forKey: .date) {
            if let date = DataSources.asam.dateFormatter.date(from: dateString) {
                parsedDate = date
            }
        }
        self.date = parsedDate
        
        let mgrsPosition = MGRS.from(longitude, latitude)
        self.mgrs10km = mgrsPosition.coordinate(.TEN_KILOMETER)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(reference, forKey: .reference)
        try? container.encode(latitude, forKey: .latitude)
        try? container.encode(longitude, forKey: .longitude)
        try? container.encode(position, forKey: .position)
        try? container.encode(navArea, forKey: .navArea)
        try? container.encode(subreg, forKey: .subreg)
        try? container.encode(hostility, forKey: .hostility)
        try? container.encode(victim, forKey: .victim)
        try? container.encode(asamDescription, forKey: .asamDescription)
        if let date = date {
            try? container.encode(DataSources.asam.dateFormatter.string(from: date), forKey: .date)
        }
    }
    
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

extension AsamModel {
    var dateString: String? {
        if let date = date {
            return DataSources.asam.dateFormatter.string(from: date)
        }
        return nil
    }
    
    var itemTitle: String {
        return "\(self.hostility ?? "")\(self.hostility != nil && self.victim != nil ? ": " : "")\(self.victim ?? "")"
    }
}

extension AsamModel: CustomStringConvertible {
    var description: String {
        return "ASAM\n\n" +
        "Reference: \(reference ?? "")\n" +
        "Date: \(dateString ?? "")\n" +
        "Latitude: \(latitude)\n" +
        "Longitude: \(longitude)\n" +
        "Navigation Area: \(navArea ?? "")\n" +
        "Subregion: \(subreg ?? "")\n" +
        "Description: \(asamDescription ?? "")\n" +
        "Hostility: \(hostility ?? "")\n" +
        "Victim: \(victim ?? "")\n"
    }
}
