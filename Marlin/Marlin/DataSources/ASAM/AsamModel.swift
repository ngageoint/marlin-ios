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

struct AsamModel: Locatable, Bookmarkable, Codable, GeoJSONExportable {
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
        return self.asam == other.asam
    }
    
    static func == (lhs: AsamModel, rhs: AsamModel) -> Bool {
        lhs.isEqualTo(rhs)
    }
    
    init(asam: Asam) {
        self.asam = asam
        self.canBookmark = true
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
            if let date = Asam.dateFormatter.date(from: dateString) {
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
            try? container.encode(Asam.dateFormatter.string(from: date), forKey: .date)
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
            return Asam.dateFormatter.string(from: date)
        }
        return nil
    }
    
    var itemTitle: String {
        return "\(self.hostility ?? "")\(self.hostility != nil && self.victim != nil ? ": " : "")\(self.victim ?? "")"
    }
}

extension AsamModel: DataSource {
    var color: UIColor {
        Self.color
    }
    
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }
    
    static func postProcess() {}
    
    static var isMappable: Bool = true
    static var dataSourceName: String = NSLocalizedString("ASAM", comment: "ASAM data source display name")
    static var fullDataSourceName: String = NSLocalizedString("Anti-Shipping Activity Messages", comment: "ASAM data source full display name")
    static var key: String = "asam"
    static var metricsKey: String = "asams"
    static var imageName: String? = "asam"
    static var systemImageName: String?
    
    static var color: UIColor = .black
    static var imageScale = UserDefaults.standard.imageScale(key) ?? 1.0
    
    static var defaultSort: [DataSourceSortParameter] = [
        DataSourceSortParameter(
            property: DataSourceProperty(
                name: "Date",
                key: #keyPath(Asam.date),
                type: .date),
            ascending: false)
    ]
    static var defaultFilter: [DataSourceFilterParameter] = [
        DataSourceFilterParameter(
            property: DataSourceProperty(
                name: "Date",
                key: #keyPath(Asam.date),
                type: .date),
            comparison: .window,
            windowUnits: DataSourceWindowUnits.last365Days)
    ]

    static var properties: [DataSourceProperty] = [
        DataSourceProperty(name: "Date", key: #keyPath(Asam.date), type: .date),
        DataSourceProperty(name: "Location", key: #keyPath(Asam.mgrs10km), type: .location),
        DataSourceProperty(name: "Reference", key: #keyPath(Asam.reference), type: .string),
        DataSourceProperty(name: "Latitude", key: #keyPath(Asam.latitude), type: .latitude),
        DataSourceProperty(name: "Longitude", key: #keyPath(Asam.longitude), type: .longitude),
        DataSourceProperty(name: "Navigation Area", key: #keyPath(Asam.navArea), type: .string),
        DataSourceProperty(name: "Subregion", key: #keyPath(Asam.subreg), type: .string),
        DataSourceProperty(name: "Description", key: #keyPath(Asam.asamDescription), type: .string),
        DataSourceProperty(name: "Hostility", key: #keyPath(Asam.hostility), type: .string),
        DataSourceProperty(name: "Victim", key: #keyPath(Asam.victim), type: .string)
    ]
    
    var itemKey: String {
        return reference ?? ""
    }
}

extension AsamModel: MapImage {
    func mapImage(marker: Bool, zoomLevel: Int, tileBounds3857: MapBoundingBox?, context: CGContext?) -> [UIImage] {
        return defaultMapImage(
            marker: marker,
            zoomLevel: zoomLevel,
            tileBounds3857: tileBounds3857,
            context: context,
            tileSize: 512.0
        )
    }
    
    static var cacheTiles: Bool = true
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
