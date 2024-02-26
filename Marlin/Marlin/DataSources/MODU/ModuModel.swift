//
//  ModuModel.swift
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

struct ModuListModel: Hashable, Identifiable {
    var id: String {
        name ?? ""
    }

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var date: Date?
    var latitude: Double
    var longitude: Double
    var name: String?
    var navArea: String?
    var rigStatus: String?
    var specialStatus: String?

    var dateString: String? {
        if let date = date {
            return DataSources.modu.dateFormatter.string(from: date)
        }
        return nil
    }

    var itemTitle: String {
        return name ?? ""
    }

    var canBookmark: Bool = false

    init(modu: Modu) {
        self.canBookmark = true
        self.date = modu.date
        self.latitude = modu.latitude
        self.longitude = modu.longitude
        self.name = modu.name
        self.navArea = modu.navArea
        self.rigStatus = modu.rigStatus
        self.specialStatus = modu.specialStatus
    }
}

extension ModuListModel: Bookmarkable {
    static var definition: any DataSourceDefinition {
        DataSources.modu
    }

    var itemKey: String {
        name ?? ""
    }

    var key: String {
        DataSources.modu.key
    }
}

extension ModuListModel {
    init(moduModel: ModuModel) {
        self.canBookmark = moduModel.canBookmark
        self.date = moduModel.date
        self.latitude = moduModel.latitude
        self.longitude = moduModel.longitude
        self.name = moduModel.name
        self.navArea = moduModel.navArea
        self.rigStatus = moduModel.rigStatus
        self.specialStatus = moduModel.specialStatus
    }
}

struct ModuModel: Locatable, Bookmarkable, Codable, GeoJSONExportable, CustomStringConvertible {
    static var definition: any DataSourceDefinition = DataSources.modu

    var canBookmark: Bool = false
    
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
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(subregion, forKey: .subregion)
        try? container.encode(region, forKey: .region)
        try? container.encode(latitude, forKey: .latitude)
        try? container.encode(longitude, forKey: .longitude)
        try? container.encode(distance, forKey: .distance)
        try? container.encode(specialStatus, forKey: .specialStatus)
        try? container.encode(rigStatus, forKey: .rigStatus)
        try? container.encode(position, forKey: .position)
        try? container.encode(navArea, forKey: .navArea)
        try? container.encode(name, forKey: .name)
        if let date = date {
            try? container.encode(DataSources.modu.dateFormatter.string(from: date), forKey: .date)
        }
    }
    
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

    var sfGeometry: SFGeometry? {
        return SFPoint(xValue: coordinate.longitude, andYValue: coordinate.latitude)
    }

    var itemKey: String {
        return name ?? ""
    }

    var key: String {
        DataSources.modu.key
    }

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var modu: Modu?
    
    var date: Date?
    var distance: Double?
    var latitude: Double
    var longitude: Double
    var mgrs10km: String?
    var name: String?
    var navArea: String?
    var position: String?
    var region: Int?
    var rigStatus: String?
    var specialStatus: String?
    var subregion: Int?
    
    var bookmark: Bookmark?
    
    func isEqualTo(_ other: ModuModel) -> Bool {
        return self.modu == other.modu
    }
    
    static func == (lhs: ModuModel, rhs: ModuModel) -> Bool {
        lhs.isEqualTo(rhs)
    }

    init() {
        self.canBookmark = false
        self.latitude = kCLLocationCoordinate2DInvalid.latitude
        self.longitude = kCLLocationCoordinate2DInvalid.longitude
    }

    init(modu: Modu) {
        self.modu = modu
        self.canBookmark = true
        self.date = modu.date
        self.distance = modu.distance
        self.latitude = modu.latitude
        self.longitude = modu.longitude
        self.mgrs10km = modu.mgrs10km
        self.name = modu.name
        self.navArea = modu.navArea
        self.position = modu.position
        self.region = Int(modu.region)
        self.rigStatus = modu.rigStatus
        self.specialStatus = modu.specialStatus
        self.subregion = Int(modu.subregion)
    }
    
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
        
        var parsedDate: Date?
        if let dateString = try? values.decode(String.self, forKey: .date) {
            if let date = DataSources.modu.dateFormatter.date(from: dateString) {
                parsedDate = date
            }
        }
        self.date = parsedDate
        
        let mgrsPosition = MGRS.from(longitude, latitude)
        self.mgrs10km = mgrsPosition.coordinate(.TEN_KILOMETER)
    }
    
    init?(feature: Feature) {
        if let json = try? JSONEncoder().encode(feature.properties), let string = String(data: json, encoding: .utf8) {
            
            let decoder = JSONDecoder()
            let jsonData = Data(string.utf8)
            if let model = try? decoder.decode(ModuModel.self, from: jsonData) {
                self = model
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    var description: String {
        return "MODU\n\n" +
        "Name: \(name ?? "")\n" +
        "Date: \(dateString ?? "")\n" +
        "Latitude: \(latitude)\n" +
        "Longitude: \(longitude)\n" +
        "Position: \(position ?? "")\n" +
        "Rig Status: \(rigStatus ?? "")\n" +
        "Special Status: \(specialStatus ?? "")\n" +
        "distance: \(distance ?? 0)\n" +
        "Navigation Area: \(navArea ?? "")\n" +
        "Region: \(region ?? 0)\n" +
        "Sub Region: \(subregion ?? 0)\n"
    }
}

extension ModuModel {
    var dateString: String? {
        if let date = date {
            return DataSources.modu.dateFormatter.string(from: date)
        }
        return nil
    }
    
    var itemTitle: String {
        return name ?? ""
    }
}
