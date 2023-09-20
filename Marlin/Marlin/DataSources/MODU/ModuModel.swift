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

class ModuModel: NSObject, Locatable, Bookmarkable {
    var canBookmark: Bool = false
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var modu: Modu?
    var moduProperties: ModuProperties?
    
    var date: Date?
    var distance: Double?
    var latitude: Double
    var longitude: Double
    var mgrs10km: String?
    var name: String?
    var navArea: String?
    var position: String?
    var region: Int64
    var rigStatus: String?
    var specialStatus: String?
    var subregion: Int64
    
    var bookmark: Bookmark?
    
    func isEqualTo(_ other: ModuModel) -> Bool {
        guard let otherShape = other as? Self else { return false }
        return self.modu == otherShape.modu
    }
    
    static func == (lhs: ModuModel, rhs: ModuModel) -> Bool {
        lhs.isEqualTo(rhs)
    }
    
    init(modu: Modu) {
        self.modu = modu
        self.canBookmark = true
        self.date = modu.date
        self.latitude = modu.latitude
        self.longitude = modu.longitude
        self.mgrs10km = modu.mgrs10km
        self.name = modu.name
        self.navArea = modu.navArea
        self.position = modu.position
        self.region = modu.region
        self.rigStatus = modu.rigStatus
        self.specialStatus = modu.specialStatus
        self.subregion = modu.subregion
    }
    
    init(moduProperties: ModuProperties) {
        self.moduProperties = moduProperties
        self.date = moduProperties.date
        self.latitude = moduProperties.latitude
        self.longitude = moduProperties.longitude
        self.mgrs10km = moduProperties.mgrs10km
        self.name = moduProperties.name
        self.navArea = moduProperties.navArea
        self.position = moduProperties.position
        self.region = Int64(moduProperties.region ?? 0)
        self.rigStatus = moduProperties.rigStatus
        self.specialStatus = moduProperties.specialStatus
        self.subregion = Int64(moduProperties.subregion ?? 0)
    }
    
    convenience init?(feature: Feature) {
        if let json = try? JSONEncoder().encode(feature.properties), let string = String(data: json, encoding: .utf8) {
            
            print(string)
            let decoder = JSONDecoder()
            print("json is \(string)")
            let jsonData = Data(string.utf8)
            if let ds = try? decoder.decode(ModuProperties.self, from: jsonData) {
                self.init(moduProperties: ds)
            } else {
                return nil
            }
        } else {
            return nil
        }
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
        return defaultMapImage(marker: marker, zoomLevel: zoomLevel, tileBounds3857: tileBounds3857, context: context, tileSize: 512.0)
    }
    
    static var cacheTiles: Bool = true
}
