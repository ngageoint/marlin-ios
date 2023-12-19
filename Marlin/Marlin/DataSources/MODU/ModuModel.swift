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

struct ModuModel: Locatable, Bookmarkable, Codable, GeoJSONExportable, CustomStringConvertible {
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
            try? container.encode(Modu.dateFormatter.string(from: date), forKey: .date)
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
    
    init?(feature: Feature) {
        if let json = try? JSONEncoder().encode(feature.properties), let string = String(data: json, encoding: .utf8) {
            
            print(string)
            let decoder = JSONDecoder()
            print("json is \(string)")
            let jsonData = Data(string.utf8)
            if let ds = try? decoder.decode(ModuModel.self, from: jsonData) {
                self = ds
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
            return Modu.dateFormatter.string(from: date)
        }
        return nil
    }
    
    var itemTitle: String {
        return name ?? ""
    }
}

extension ModuModel: DataSource {
    static var definition: any DataSourceDefinition = DataSourceDefinitions.modu.definition
    var color: UIColor {
        Self.color
    }
    
    var sfGeometry: SFGeometry? {
        return SFPoint(xValue: coordinate.longitude, andYValue: coordinate.latitude)
    }
    static var isMappable: Bool = true
    static var dataSourceName: String = NSLocalizedString("MODU", comment: "MODU data source display name")
    static var fullDataSourceName: String = NSLocalizedString("Mobile Offshore Drilling Units", comment: "MODU data source display name")
    static var key: String = "modu"
    static var metricsKey: String = "modus"
    static var imageName: String? = "modu"
    static var systemImageName: String? = nil
    static var color: UIColor = UIColor(argbValue: 0xFF0042A4)
    static var imageScale = UserDefaults.standard.imageScale(key) ?? 1.0
    
    static var defaultSort: [DataSourceSortParameter] = [DataSourceSortParameter(property:DataSourceProperty(name: "Date", key: #keyPath(Modu.date), type: .date), ascending: false)]
    static var defaultFilter: [DataSourceFilterParameter] = []
    
    static var properties: [DataSourceProperty] = [
        DataSourceProperty(name: "Location", key: #keyPath(Modu.mgrs10km), type: .location),
        DataSourceProperty(name: "Subregion", key: #keyPath(Modu.subregion), type: .int),
        DataSourceProperty(name: "Region", key: #keyPath(Modu.region), type: .int),
        DataSourceProperty(name: "Longitude", key: #keyPath(Modu.longitude), type: .longitude),
        DataSourceProperty(name: "Latitude", key: #keyPath(Modu.latitude), type: .latitude),
        DataSourceProperty(name: "Distance", key: #keyPath(Modu.distance), type: .double),
        DataSourceProperty(name: "Special Status", key: #keyPath(Modu.specialStatus), type: .string),
        DataSourceProperty(name: "Rig Status", key: #keyPath(Modu.rigStatus), type: .string),
        DataSourceProperty(name: "Nav Area", key: #keyPath(Modu.navArea), type: .string),
        DataSourceProperty(name: "Name", key: #keyPath(Modu.name), type: .string),
        DataSourceProperty(name: "Date", key: #keyPath(Modu.date), type: .date),
    ]
    
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }
    
    static func postProcess() {}
    
    var itemKey: String {
        return name ?? ""
    }
}

extension ModuModel: MapImage {
    func mapImage(marker: Bool, zoomLevel: Int, tileBounds3857: MapBoundingBox?, context: CGContext?) -> [UIImage] {
        var images: [UIImage] = []
        if let tileBounds3857 = tileBounds3857, var distance = distance, distance > 0 {
            let circleCoordinates = coordinate.circleCoordinates(radiusMeters: distance * 1852)
            let path = UIBezierPath()
            var pixel = circleCoordinates[0].toPixel(zoomLevel: zoomLevel, tileBounds3857: tileBounds3857, tileSize: TILE_SIZE)
            path.move(to: pixel)
            for circleCoordinate in circleCoordinates {
                pixel = circleCoordinate.toPixel(zoomLevel: zoomLevel, tileBounds3857: tileBounds3857, tileSize: TILE_SIZE)
                path.addLine(to: pixel)
            }
            path.lineWidth = 4
            path.close()
            Modu.color.withAlphaComponent(0.3).setFill()
            Modu.color.setStroke()
            path.fill()
            path.stroke()
        }
        images.append(contentsOf: defaultMapImage(marker: marker, zoomLevel: zoomLevel, tileBounds3857: tileBounds3857, context: context, tileSize: 512.0))
        return images
    }
    
    static var cacheTiles: Bool = true
}
