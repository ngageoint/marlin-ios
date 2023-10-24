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

class RouteWaypoint: NSManagedObject {
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
    
    var mkLine: MKGeodesicPolyline? {
        var coordinates: [CLLocationCoordinate2D] = []
        if let waypoints = waypoints {
            for waypoint in waypoints {
                if let waypoint = waypoint as? RouteWaypoint, let ds = waypoint.decodeToDataSource() {
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


extension Route: MapImage {
    var latitude: Double {
        0.0
    }
    
    var longitude: Double {
        0.0
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    static var cacheTiles: Bool = false
    
    func mapImage(marker: Bool, zoomLevel: Int, tileBounds3857: MapBoundingBox?, context: CGContext? = nil) -> [UIImage] {
        var images: [UIImage] = []
//        guard let tileBounds3857 = tileBounds3857 else {
//            return images
//        }
//        if let locations = locations {
//            for location in locations {
//                if let wkt = location["wkt"] {
//                    var distance: Double?
//                    if let distanceString = location["distance"] {
//                        distance = Double(distanceString)
//                    }
//                    
//                    let shape = MKShape.fromWKT(wkt: wkt, distance: distance)
//                    
//                    if let point = shape as? MKPointAnnotation {
//                        let coordinate = point.coordinate
//                        if let distance = distance {
//                            let circleCoordinates = coordinate.circleCoordinates(radiusMeters: distance)
//                            let path = UIBezierPath()
//                            
//                            var pixel = circleCoordinates[0].toPixel(zoomLevel: zoomLevel, tileBounds3857: tileBounds3857, tileSize: TILE_SIZE)
//                            path.move(to: pixel)
//                            for circleCoordinate in circleCoordinates {
//                                pixel = circleCoordinate.toPixel(zoomLevel: zoomLevel, tileBounds3857: tileBounds3857, tileSize: TILE_SIZE)
//                                path.addLine(to: pixel)
//                            }
//                            path.lineWidth = 4
//                            path.close()
//                            NavigationalWarning.color.withAlphaComponent(0.3).setFill()
//                            NavigationalWarning.color.setStroke()
//                            path.fill()
//                            path.stroke()
//                        }
//                        images.append(contentsOf: defaultMapImage(marker: marker, zoomLevel: zoomLevel, pointCoordinate: coordinate, tileBounds3857: tileBounds3857, context: context, tileSize: 512.0))
//                    } else if let polygon = shape as? MKPolygon {
//                        let polyline = polygon.toGeodesicPolyline()
//                        let path = UIBezierPath()
//                        var first = true
//                        
//                        for point in UnsafeBufferPointer(start: polyline.points(), count: polyline.pointCount) {
//                            
//                            let pixel = point.coordinate.toPixel(zoomLevel: zoomLevel, tileBounds3857: tileBounds3857, tileSize: TILE_SIZE, canCross180thMeridian: polyline.boundingMapRect.spans180thMeridian)
//                            if first {
//                                path.move(to: pixel)
//                                first = false
//                            } else {
//                                path.addLine(to: pixel)
//                            }
//                            
//                        }
//                        
//                        path.lineWidth = 4
//                        path.close()
//                        NavigationalWarning.color.withAlphaComponent(0.3).setFill()
//                        NavigationalWarning.color.setStroke()
//                        path.fill()
//                        path.stroke()
//                    } else if let lineShape = shape as? MKGeodesicPolyline {
//                        
//                        let path = UIBezierPath()
//                        var first = true
//                        let points = lineShape.points()
//                        
//                        for point in UnsafeBufferPointer(start: points, count: lineShape.pointCount) {
//                            
//                            let pixel = point.coordinate.toPixel(zoomLevel: zoomLevel, tileBounds3857: tileBounds3857, tileSize: TILE_SIZE)
//                            if first {
//                                path.move(to: pixel)
//                                first = false
//                            } else {
//                                path.addLine(to: pixel)
//                            }
//                            
//                        }
//                        
//                        path.lineWidth = 4
//                        NavigationalWarning.color.setStroke()
//                        path.stroke()
//                    }
//                }
//            }
//        }
        
        return images
    }
}
