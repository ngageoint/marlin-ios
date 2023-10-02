//
//  Route+CoreDataClass.swift
//  Marlin
//
//  Created by Daniel Barela on 8/14/23.
//

import Foundation
import CoreData
import UIKit
import GeoJSON

class RouteWaypoint: NSManagedObject {
    func decodeToDataSource() -> DataSource? {
        do {
            let decoder = JSONDecoder()
            if let json = json {
                let jsonData = Data(json.utf8)
                let ds = try decoder.decode(FeatureCollection.self, from: jsonData)
                if !ds.features.isEmpty {
                    let feature = ds.features[0]
                    
                    switch(dataSource) {
                    case Asam.key:
                        let asamModel = AsamModel(feature: ds.features[0])
                        return asamModel
                    case Modu.key:
                        let moduModel = ModuModel(feature: ds.features[0])
                        return moduModel
                    case Light.key:
                        let lightModel = LightModel(feature: ds.features[0])
                        return lightModel
                    case Port.key:
                        let portModel = PortModel(feature: ds.features[0])
                        return portModel
                    case DifferentialGPSStation.key:
                        let dgpsModel = DifferentialGPSStationModel(feature: ds.features[0])
                        return dgpsModel
                    case RadioBeacon.key:
                        let rbModel = RadioBeaconModel(feature: ds.features[0])
                        return rbModel
                    case CommonDataSource.key:
                        let commonModel = CommonDataSource(feature: ds.features[0])
                        return commonModel
                    default:
                        print("no")
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
}

class Route: NSManagedObject {
    var measurementFormatter: MeasurementFormatter {
        let measurementFormatter = MeasurementFormatter()
        measurementFormatter.unitOptions = .providedUnit
        measurementFormatter.unitStyle = .short
        measurementFormatter.numberFormatter.maximumFractionDigits = 2
        return measurementFormatter
    }
    
    public var waypointArray: [RouteWaypoint] {
        let set = waypoints as? Set<RouteWaypoint> ?? []
        return set.sorted {
            $0.order < $1.order
        }
    }
    
    var nauticalMilesDistance: String? {
        if distanceMeters != 0.0 {
            let metersMeasurement = NSMeasurement(doubleValue: distanceMeters, unit: UnitLength.meters)
            let convertedMeasurement = metersMeasurement.converting(to: UnitLength.nauticalMiles)
            return measurementFormatter.string(from: convertedMeasurement)
        }
        return nil
    }
}

extension Route: DataSource {
    static var key: String = "route"
    static var metricsKey: String = "routes"
    
    static var properties: [DataSourceProperty] = []
    
    static var defaultSort: [DataSourceSortParameter] = []
    
    static var defaultFilter: [DataSourceFilterParameter] = []
    
    static var isMappable: Bool = true
    
    static var dataSourceName: String = NSLocalizedString("Routes", comment: "Route data source display name")
    static var fullDataSourceName: String = NSLocalizedString("Routes", comment: "Route data source full display name")
    
    static var color: UIColor = .black
    var color: UIColor {
        Self.color
    }
    
    static var imageScale = UserDefaults.standard.imageScale(key) ?? 1.0
    
    static var imageName: String? = nil
    
    static var systemImageName: String? = "arrow.triangle.turn.up.right.diamond.fill"
        
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }
    
    var itemKey: String {
        return "\(name ?? "")"
    }
    
    var itemTitle: String {
        return "\(name ?? "")"
    }
}
