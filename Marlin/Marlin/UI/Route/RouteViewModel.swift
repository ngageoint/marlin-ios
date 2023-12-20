//
//  RouteViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 10/9/23.
//

import Foundation
import MapKit
import GeoJSON
import CoreData

class RouteViewModel: ObservableObject, Identifiable {
    var locationManager = LocationManager.shared()
    var route: Route?
    var routeURI: URL? {
        didSet {
            let context = PersistenceController.current.viewContext
            if let routeURI = routeURI, 
                let id = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: routeURI),
                let route = try? context.existingObject(with: id) as? Route {
                self.route = route
                routeName = route.name ?? ""
                routeDistance = route.distanceMeters
                waypoints = []
                for waypoint in route.waypointArray {
                    if let exportable = waypoint.decodeToDataSource() {
                        addWaypoint(waypoint: exportable)
                    }
                }
            }
        }
    }
    
    @Published var routeMKLine: MKGeodesicPolyline?
    @Published var routeFeatureCollection: FeatureCollection? {
        didSet {
            if let routeFeatureCollection = routeFeatureCollection {
                routeMKLine = MKShape.fromFeatureCollection(featureCollection: routeFeatureCollection)
            } else {
                routeMKLine = nil
            }
        }
    }
    
    @Published var waypoints: [any GeoJSONExportable] = []
    
    @Published var routeName: String = ""
    
    @Published var routeDistance: Double = 0.0
    var measurementFormatter: MeasurementFormatter {
        let measurementFormatter = MeasurementFormatter()
        measurementFormatter.unitOptions = .providedUnit
        measurementFormatter.unitStyle = .short
        measurementFormatter.numberFormatter.maximumFractionDigits = 2
        return measurementFormatter
    }
    var nauticalMilesDistance: String? {
        if routeDistance != 0.0 {
            let metersMeasurement = NSMeasurement(doubleValue: routeDistance, unit: UnitLength.meters)
            let convertedMeasurement = metersMeasurement.converting(to: UnitLength.nauticalMiles)
            return measurementFormatter.string(from: convertedMeasurement)
        }
        return nil
    }
    
    init() {
        if let coordinate = locationManager.lastLocation?.coordinate, CLLocationCoordinate2DIsValid(coordinate) {
            addWaypoint(waypoint: CommonDataSource(name: "Your Current Location", location: coordinate))
        }
    }
    
    func reorder(fromOffsets source: IndexSet, toOffset destination: Int) {
        waypoints.move(fromOffsets: source, toOffset: destination)
        setupFeatureCollection()
    }
    
    func removeWaypoint(waypoint: any GeoJSONExportable) {
        waypoints.removeAll { exportable in
            exportable.uniqueId == waypoint.uniqueId
        }
        setupFeatureCollection()
    }
    
    func addWaypoint(waypoint: any GeoJSONExportable) {
        waypoints.append(waypoint)
        setupFeatureCollection()
    }
    
    func setupFeatureCollection() {
        var features: [Feature] = []
        routeDistance = 0.0
        var previousCoordinate: CLLocation?
        for waypoint in waypoints {
            if let centerPoint = waypoint.sfGeometry?.degreesCentroid() {
                let location = CLLocation(latitude: centerPoint.y.doubleValue, longitude: centerPoint.x.doubleValue)
                if let previousCoordinate = previousCoordinate {
                    routeDistance += previousCoordinate.distance(from: location)
                }
                previousCoordinate = location
            }
            for feature in waypoint.geoJsonFeatures {
                features.append(feature)
            }
            
        }
        let featureCollection = FeatureCollection(features: features)
        routeFeatureCollection = featureCollection
    }
    
    func createRoute(context: NSManagedObjectContext) {
        context.perform {
            var route: Route? = self.route
            
            if route == nil {
                route = Route(context: context)
                route?.createdTime = Date()
            }
            if let route = route {
                route.updatedTime = Date()
                route.name = self.routeName
                route.distanceMeters = self.routeDistance
                var set: Set<RouteWaypoint> = Set<RouteWaypoint>()
                for (i, waypoint) in self.waypoints.enumerated() {
                    let routeWaypoint = RouteWaypoint(context: context)
                    routeWaypoint.dataSource = waypoint.key
                    routeWaypoint.json = waypoint.geoJson
                    routeWaypoint.order = Int64(i)
                    routeWaypoint.route = route
                    routeWaypoint.itemKey = waypoint.itemKey
                    set.insert(routeWaypoint)
                }
                route.waypoints = NSSet(set: set)
                if let routeGeom = route.sfGeometry, 
                    let envelope = routeGeom.envelope(),
                    let minLat = envelope.minY,
                    let maxLat = envelope.maxY,
                    let minLon = envelope.minX,
                    let maxLon = envelope.maxX {
                    route.minLatitude = minLat.doubleValue
                    route.maxLatitude = maxLat.doubleValue
                    route.minLongitude = minLon.doubleValue
                    route.maxLongitude = maxLon.doubleValue
                }
                
                if let routeFeatureCollection = self.routeFeatureCollection {
                    do {
                        let json = try JSONEncoder().encode(routeFeatureCollection)
                        let geoJson = String(data: json, encoding: .utf8)
                        if let geoJson = geoJson {
                            route.geojson = geoJson
                        }
                    } catch {
                        print("error is \(error)")
                    }
                }
                
                try? context.save()
            }
        }
    }
}
