//
//  AsamModel.swift
//  Marlin
//
//  Created by Daniel Barela on 9/15/23.
//

import Foundation
import CoreLocation

class AsamModel: NSObject, Locatable {
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var asam: Asam?
    var asamProperties: AsamProperties?
    
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
        guard let otherShape = other as? Self else { return false }
        return self.asam == otherShape.asam
    }
    
    static func == (lhs: AsamModel, rhs: AsamModel) -> Bool {
        lhs.isEqualTo(rhs)
    }
    
    init(asam: Asam) {
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
    
    init(asamProperties: AsamProperties) {
        self.asamProperties = asamProperties
        self.asamDescription = asamProperties.asamDescription
        self.date = asamProperties.date
        self.hostility = asamProperties.hostility
        self.latitude = asamProperties.latitude
        self.longitude = asamProperties.longitude
        self.mgrs10km = asamProperties.mgrs10km
        self.navArea = asamProperties.navArea
        self.position = asamProperties.position
        self.reference = asamProperties.reference
        self.subreg = asamProperties.subreg
        self.victim = asamProperties.victim
    }
    
    convenience init?(feature: Feature) {
        if let json = try? JSONEncoder().encode(feature.properties), let string = String(data: json, encoding: .utf8) {
            
            print(string)
            let decoder = JSONDecoder()
            print("json is \(string)")
            let jsonData = Data(string.utf8)
            if let ds = try? decoder.decode(AsamProperties.self, from: jsonData) {
                self.init(asamProperties: ds)
            } else {
                return nil
            }
        } else {
            return nil
        }
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
    static var systemImageName: String? = nil
    
    static var color: UIColor = .black
    static var imageScale = UserDefaults.standard.imageScale(key) ?? 1.0
    
    static var defaultSort: [DataSourceSortParameter] = [DataSourceSortParameter(property:DataSourceProperty(name: "Date", key: #keyPath(Asam.date), type: .date), ascending: false)]
    static var defaultFilter: [DataSourceFilterParameter] = [DataSourceFilterParameter(property: DataSourceProperty(name: "Date", key: #keyPath(Asam.date), type: .date), comparison: .window, windowUnits: DataSourceWindowUnits.last365Days)]
    
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
        return defaultMapImage(marker: marker, zoomLevel: zoomLevel, tileBounds3857: tileBounds3857, context: context, tileSize: 512.0)
    }
    
    static var cacheTiles: Bool = true
}
