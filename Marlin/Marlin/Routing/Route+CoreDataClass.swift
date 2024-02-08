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
import MapKit
import sf_ios

class RouteWaypoint: NSManagedObject {
    
    var sfGeometry: SFGeometry? {
        let decoded = decodeToDataSource()
        return decoded?.sfGeometry
    }
    
    // ignoring this error because this is how many data sources we have
    // swiftlint:disable cyclomatic_complexity
    func decodeToDataSource() -> (any GeoJSONExportable)? {
        do {
            let decoder = JSONDecoder()
            if let json = json {
                let jsonData = Data(json.utf8)
                let featureCollection = try decoder.decode(FeatureCollection.self, from: jsonData)
                if !featureCollection.features.isEmpty {
                    switch dataSource {
                    case DataSources.asam.key:
                        let asamModel = AsamModel(feature: featureCollection.features[0])
                        return asamModel
                    case DataSources.modu.key:
                        let moduModel = ModuModel(feature: featureCollection.features[0])
                        return moduModel
                    case Light.key:
                        let lightModel = LightModel(feature: featureCollection.features[0])
                        return lightModel
                    case DataSources.port.key:
                        let portModel = PortModel(feature: featureCollection.features[0])
                        return portModel
                    case DataSources.dgps.key:
                        let dgpsModel = DifferentialGPSStationModel(feature: featureCollection.features[0])
                        return dgpsModel
                    case DataSources.radioBeacon.key:
                        let rbModel = RadioBeaconModel(feature: featureCollection.features[0])
                        return rbModel
                    case CommonDataSource.key:
                        let commonModel = CommonDataSource(feature: featureCollection.features[0])
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
    // swiftlint:enable cyclomatic_complexity
}

extension Route: Locatable, GeoPackageExportable {
    var sfGeometry: SFGeometry? {
        let collection = SFGeometryCollection()
        if let waypoints = waypoints {
            for waypoint in waypoints {
                if let waypoint = waypoint as? RouteWaypoint, let geometry = waypoint.sfGeometry {
                    collection?.addGeometry(geometry)
                }
            }
        }
        
        return collection
    }
    
    static func getBoundingPredicate(minLat: Double, maxLat: Double, minLon: Double, maxLon: Double) -> NSPredicate {
        return NSPredicate(
            format: """
                (maxLatitude >= %lf \
                AND minLatitude <= %lf \
                AND maxLongitude >= %lf \
                AND minLongitude <= %lf) \
                OR minLongitude < -180 \
                OR maxLongitude > 180
            """, minLat, maxLat, minLon, maxLon
        )
    }
}

class Route: NSManagedObject {
    
    lazy var coordinate: CLLocationCoordinate2D = {
        if let region = self.region {
            return region.center
        }
        return kCLLocationCoordinate2DInvalid
    }()
    
    lazy var region: MKCoordinateRegion? = {
        if let geometry = self.sfGeometry, let envelope = geometry.envelope() {
            // get coordinate region from envelope
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: envelope.midY(), longitude: envelope.midX()),
                span: MKCoordinateSpan(latitudeDelta: envelope.yRange(), longitudeDelta: envelope.xRange()))
        }
        return nil
    }()
    
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
    
    var mkLine: MKGeodesicPolyline? {
        var coordinates: [CLLocationCoordinate2D] = []
        if let waypoints = waypoints {
            for waypoint in waypoints {
                if let waypoint = waypoint as? RouteWaypoint, let dataSource = waypoint.decodeToDataSource() {
                    for feature in dataSource.geoJsonFeatures {
                        if let geometry: Geometry = feature.geometry {
                            addGeometry(geometry: geometry, coordinates: &coordinates)
                        }
                    }
                }
            }
        }
        let line = MKGeodesicPolyline(coordinates: &coordinates, count: coordinates.count)

        return line
    }
    
    func addGeometry(geometry: Geometry, coordinates: inout [CLLocationCoordinate2D]) {
        switch geometry {
        case .point(let point):
            coordinates.append(point.coordinates.coordinate)
        case .multiPoint(let multiPoint):
            coordinates.append(contentsOf: multiPoint.coordinates.map { position in
                position.coordinate
            })
        case .lineString(let lineString):
            coordinates.append(contentsOf: lineString.coordinates.map { position in
                position.coordinate
            })
        case .multiLineString(let multiLineString):
            coordinates.append(contentsOf: multiLineString.coordinates.flatMap { lineString in
                lineString.coordinates.map { position in
                    position.coordinate
                }
            })
        case .polygon(let poly):
            coordinates.append(contentsOf: poly.coordinates.flatMap { ring in
                ring.coordinates.map { position in
                    position.coordinate
                }
            })
        case .multiPolygon(let multipoly):
            coordinates.append(contentsOf: multipoly.coordinates.flatMap { poly in
                poly.coordinates.flatMap { ring in
                    ring.coordinates.map { position in
                        position.coordinate
                    }
                }
            })
        case .geometryCollection(let collection):
            for geometry in collection {
                addGeometry(geometry: geometry, coordinates: &coordinates)
            }
        }
    }
}

extension Route: DataSource {
    static var definition: any DataSourceDefinition = DataSourceDefinitions.route.definition
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
    
    static var imageName: String?
    
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

extension Route: MapImage {

    var latitude: Double {
        coordinate.latitude
    }
    
    var longitude: Double {
        coordinate.longitude
    }
    
    static var cacheTiles: Bool = false
    
    func mapImage(
        marker: Bool,
        zoomLevel: Int,
        tileBounds3857: MapBoundingBox?,
        context: CGContext? = nil) -> [UIImage] {
        let images: [UIImage] = []
        return images
    }
}
