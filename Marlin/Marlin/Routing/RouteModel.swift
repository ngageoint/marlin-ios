//
//  RouteModel.swift
//  Marlin
//
//  Created by Daniel Barela on 10/6/23.
//

import Foundation
import CoreData
import MapKit
import GeoJSON

struct RouteModel: Codable, GeoJSONExportable {
    var itemKey: String {
        routeURL?.absoluteString ?? ""
    }
    
    var key: String = "route"
    
    static var properties: [DataSourceProperty] = []
    
    var sfGeometry: SFGeometry?
    
    private enum CodingKeys: String, CodingKey {
        case name
        case createdTime
        case distanceMeters
        case geojson
        case routeId
        case updatedTime
        case waypoints
    }
    
    var name: String?
    var distanceMeters: Double?
    var geojson: String?
    var createdTime: Date?
    var routeId: Int?
    var updatedTime: Date?
    var routeURL: URL?
    var waypoints: [RouteWaypointModel]?
    
    func isEqualTo(_ other: RouteModel) -> Bool {
        return self.routeURL == other.routeURL
    }
    
    static func == (lhs: RouteModel, rhs: RouteModel) -> Bool {
        lhs.isEqualTo(rhs)
    }
    
    init(route: Route) {
        self.name = route.name
        self.distanceMeters = route.distanceMeters
        self.geojson = route.geojson
        self.createdTime = route.createdTime
        self.routeId = Int(route.routeId)
        self.updatedTime = route.updatedTime
        routeURL = route.objectID.uriRepresentation()
        self.waypoints = route.waypoints?.allObjects.compactMap({ waypoint in
            if let waypoint = waypoint as? RouteWaypoint {
                return RouteWaypointModel(waypoint: waypoint)
            }
            return nil
        })
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try? values.decode(String.self, forKey: .name)
        distanceMeters = try? values.decode(Double.self, forKey: .distanceMeters)
        geojson = try? values.decode(String.self, forKey: .geojson)
        createdTime = try? values.decode(Date.self, forKey: .createdTime)
        routeId = try? values.decode(Int.self, forKey: .routeId)
        updatedTime = try? values.decode(Date.self, forKey: .updatedTime)
        waypoints = try? values.decode([RouteWaypointModel].self, forKey: .waypoints)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(name, forKey: .name)
        try? container.encode(distanceMeters, forKey: .distanceMeters)
        try? container.encode(geojson, forKey: .geojson)
        try? container.encode(createdTime, forKey: .createdTime)
        try? container.encode(routeId, forKey: .routeId)
        try? container.encode(updatedTime, forKey: .updatedTime)
        try? container.encode(waypoints, forKey: .waypoints)
    }
}

extension RouteModel {
    var measurementFormatter: MeasurementFormatter {
        let measurementFormatter = MeasurementFormatter()
        measurementFormatter.unitOptions = .providedUnit
        measurementFormatter.unitStyle = .short
        measurementFormatter.numberFormatter.maximumFractionDigits = 2
        return measurementFormatter
    }
    
    public var waypointArray: [RouteWaypointModel] {
        let set = waypoints ?? []
        return set.sorted {
            $0.order ?? -1 < $1.order ?? -1
        }
    }
    
    var nauticalMilesDistance: String? {
        if let distanceMeters = distanceMeters, distanceMeters != 0.0 {
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
                if let ds = waypoint.decodeToDataSource() {
                    for feature in ds.geoJsonFeatures {
                        if let g: Geometry = feature.geometry {
                            addGeometry(g: g, coordinates: &coordinates)
                        }
                    }
                }
            }
        }
        let line = MKGeodesicPolyline(coordinates: &coordinates, count: coordinates.count)
        
        
        return line
    }
    
    func addGeometry(g: Geometry, coordinates: inout [CLLocationCoordinate2D]) {
        switch(g) {
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
                addGeometry(g: geometry, coordinates: &coordinates)
            }
        }
    }
}

extension RouteModel: DataSource {
    var itemTitle: String {
        name ?? ""
    }
    
    var color: UIColor {
        Route.color
    }
    
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }
    
    static func postProcess() {}
    
    static var isMappable: Bool = true
    static var dataSourceName: String = Route.dataSourceName
    static var fullDataSourceName: String = Route.fullDataSourceName
    static var key: String = Route.key
    static var metricsKey: String = Route.metricsKey
    static var imageName: String? = Route.imageName
    static var systemImageName: String? = Route.systemImageName
    
    static var color: UIColor = Route.color
    static var imageScale = Route.imageScale
    
    static var defaultSort: [DataSourceSortParameter] = Route.defaultSort
    static var defaultFilter: [DataSourceFilterParameter] = Route.defaultFilter
}

import SwiftUI
extension RouteModel: DataSourceViewBuilder {
    var detailView: AnyView {
        return AnyView(EmptyView())
    }
        
    var summary: some DataSourceSummaryView {
        return RouteSummaryView(route: self)
    }
}

struct RouteWaypointModel: Codable {
    private enum CodingKeys: String, CodingKey {
        case dataSource
        case itemKey
        case json
        case order
        case routeId
        case waypointId
    }
    
    var dataSource: String?
    var itemKey: String?
    var json: String?
    var order: Int?
    var routeId: Int?
    var waypointId: URL?
    
    func isEqualTo(_ other: RouteWaypointModel) -> Bool {
        return self.waypointId == other.waypointId
    }
    
    static func == (lhs: RouteWaypointModel, rhs: RouteWaypointModel) -> Bool {
        lhs.isEqualTo(rhs)
    }
    
    init(waypoint: RouteWaypoint) {
        dataSource = waypoint.dataSource
        itemKey = waypoint.itemKey
        json = waypoint.json
        order = Int(waypoint.order)
        routeId = Int(waypoint.routeId)
        waypointId = waypoint.objectID.uriRepresentation()
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        dataSource = try? values.decode(String.self, forKey: .dataSource)
        itemKey = try? values.decode(String.self, forKey: .itemKey)
        json = try? values.decode(String.self, forKey: .json)
        order = try? values.decode(Int.self, forKey: .order)
        routeId = try? values.decode(Int.self, forKey: .routeId)
        waypointId = try? values.decode(URL.self, forKey: .waypointId)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(dataSource, forKey: .dataSource)
        try? container.encode(itemKey, forKey: .itemKey)
        try? container.encode(json, forKey: .json)
        try? container.encode(order, forKey: .order)
        try? container.encode(routeId, forKey: .routeId)
        try? container.encode(waypointId, forKey: .waypointId)
    }
}

extension RouteWaypointModel {
    func decodeToDataSource() -> (any GeoJSONExportable)? {
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
