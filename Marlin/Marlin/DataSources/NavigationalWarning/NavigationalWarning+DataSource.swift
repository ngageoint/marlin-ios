//
//  NavigationalWarning+DataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import UIKit
import CoreData
import MapKit
import sf_ios
import sf_wkt_ios

extension NavigationalWarning: DataSourceLocation, GeoPackageExportable {
    var itemKey: String? {
        return "\(msgYear)--\(msgNumber)--\(navArea ?? "")"
    }
    var sfGeometry: SFGeometry? {
        let collection = SFGeometryCollection()
        if let locations = locations {
            for location in locations {
                if let geometry = locationGeometry(location: location) {
                    collection?.addGeometry(geometry)
                }
            }
        }
                
        return collection
    }
    
    func locationGeometry(location: [String : String]) -> SFGeometry? {
        guard let wkt = location["wkt"] else {
            return nil
        }
        var distance: Double?
        if let distanceString = location["distance"] {
            distance = Double(distanceString)
        }
        if let shape = MKShape.fromWKT(wkt: wkt, distance: distance) {
            if let polygon = shape as? MKPolygon {
                let sfPoly = SFPolygon()
                var previousPoint: CLLocationCoordinate2D?
                var firstPoint: CLLocationCoordinate2D?
                var flipped: SFLineString?

                if let sfLineString = SFLineString() {
                    for point in polygon.points().toArray(capacity: polygon.pointCount) {
                        if firstPoint == nil {
                            firstPoint = point.coordinate
                        }
                        if let previous = previousPoint {
                            let currentPoint = point.coordinate
                            var coords: [CLLocationCoordinate2D] = [previous, currentPoint]
                            let gl = MKGeodesicPolyline(coordinates: &coords, count: 2)

                            let glpoints = gl.points()

                            for glpoint in UnsafeBufferPointer(start: glpoints, count: gl.pointCount) {
                                let currentGlPoint = glpoint.coordinate
                                if let firstPoint = firstPoint, abs(firstPoint.longitude - currentGlPoint.longitude) > 90 {
                                    if flipped == nil {
                                        flipped = SFLineString()
                                    }
                                    flipped?.addPoint(SFPoint(xValue: currentGlPoint.longitude, andYValue: currentGlPoint.latitude))

                                } else {
                                    sfLineString.addPoint(SFPoint(xValue: currentGlPoint.longitude, andYValue: currentGlPoint.latitude))

                                }
                            }
                            previousPoint = currentPoint
                        } else {
                            previousPoint = point.coordinate
                        }
                    }
                    
                    // now draw the geodesic line between the last and the first
                    if let previousPoint = previousPoint, let firstPoint = firstPoint {
                        var coords: [CLLocationCoordinate2D] = [previousPoint, firstPoint]
                        let gl = MKGeodesicPolyline(coordinates: &coords, count: 2)
                        
                        let glpoints = gl.points()
                        
                        for glpoint in UnsafeBufferPointer(start: glpoints, count: gl.pointCount) {
                            let currentGlPoint = glpoint.coordinate
                            if abs(firstPoint.longitude - currentGlPoint.longitude) > 90 {
                                if flipped == nil {
                                    flipped = SFLineString()
                                }
                                flipped?.addPoint(SFPoint(xValue: currentGlPoint.longitude, andYValue: currentGlPoint.latitude))
                                
                            } else {
                                sfLineString.addPoint(SFPoint(xValue: currentGlPoint.longitude, andYValue: currentGlPoint.latitude))
                            }
                        }
                    }
                    
                    sfPoly?.addRing(sfLineString)
                }
                if let flipped = flipped {
                    let flippedPoly = SFPolygon(ring: flipped)
                    return SFGeometryCollection(geometries: [flippedPoly, sfPoly])
                }
                return sfPoly
            } else if let polyline = shape as? MKGeodesicPolyline {
                let sfLineString = SFLineString()
                for point in polyline.points().toArray(capacity: polyline.pointCount) {
                    sfLineString?.addPoint(SFPoint(xValue: point.coordinate.longitude, andYValue: point.coordinate.latitude))
                }
                return sfLineString
            } else if let polyline = shape as? MKPolyline {
                let sfLineString = SFLineString()

                for point in polyline.points().toArray(capacity: polyline.pointCount) {
                    sfLineString?.addPoint(SFPoint(xValue: point.coordinate.longitude, andYValue: point.coordinate.latitude))
                }
                return sfLineString
            } else if let point = shape as? MKPointAnnotation {
                return SFPoint(xValue: point.coordinate.longitude, andYValue: point.coordinate.latitude)
            } else if let circle = shape as? MKCircle {
                return SFPoint(xValue: circle.coordinate.longitude, andYValue: circle.coordinate.latitude)
            }
        }

        return nil
    }
    
    static func getBoundingPredicate(minLat: Double, maxLat: Double, minLon: Double, maxLon: Double) -> NSPredicate {
        return NSPredicate(
            format: "maxLatitude >= %lf AND minLatitude <= %lf AND maxLongitude >= %lf AND minLongitude <= %lf", minLat, maxLat, minLon, maxLon
        )
    }
    
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter
    }
    static var isMappable: Bool = true
    static var dataSourceName: String = NSLocalizedString("Warnings", comment: "Warnings data source display name")
    static var fullDataSourceName: String = NSLocalizedString("Navigational Warnings", comment: "Warnings data source display name")
    static var key: String = "navWarning"
    static var metricsKey: String = "navigational_warnings"
    static var color: UIColor = UIColor(argbValue: 0xFFD32F2F)
    static var imageName: String? = nil
    static var systemImageName: String? = "exclamationmark.triangle.fill"
    static var imageScale: CGFloat = 1.0
    
    static func postProcess() {
        if !UserDefaults.standard.navigationalWarningsLocationsParsed {
            DispatchQueue.global(qos: .utility).async {
                let fetchRequest = NavigationalWarning.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "locations == nil")
                let context = PersistenceController.current.newTaskContext()
                context.performAndWait {
                    if let objects = try? context.fetch(fetchRequest), !objects.isEmpty {

                        for warning in objects {
                            if let mappedLocation = warning.mappedLocation {
                                if let region = mappedLocation.region {
                                    warning.latitude = region.center.latitude
                                    warning.longitude = region.center.longitude
                                    warning.minLatitude = region.center.latitude - (region.span.latitudeDelta / 2.0)
                                    warning.maxLatitude = region.center.latitude + (region.span.latitudeDelta / 2.0)
                                    warning.minLongitude = region.center.longitude - (region.span.longitudeDelta / 2.0)
                                    warning.maxLongitude = region.center.longitude + (region.span.longitudeDelta / 2.0)
                                }
                                warning.locations = mappedLocation.wktDistance
                            }
                        }
                    }
                    do {
                        try context.save()
                    } catch {
                    }
                }
                
                NotificationCenter.default.post(Notification(name: .DataSourceProcessed, object: DataSourceUpdatedNotification(key: NavigationalWarning.key)))
            }
        }
    }

    var color: UIColor {
        return NavigationalWarning.color
    }
    
    static var defaultSort: [DataSourceSortParameter] = [DataSourceSortParameter(property:DataSourceProperty(name: "Navigational Area", key: "navArea", type: .string), ascending: false), DataSourceSortParameter(property:DataSourceProperty(name: "Issue Date", key: "issueDate", type: .date), ascending: false)]
    
    static var defaultFilter: [DataSourceFilterParameter] = []
    
    static var properties: [DataSourceProperty] = []
    
    var coordinateRegion: MKCoordinateRegion? {
        region
    }
}

extension NavigationalWarning: BatchImportable {
    
    static var seedDataFiles: [String]? = nil
    static var decodableRoot: Decodable.Type = NavigationalWarningPropertyContainer.self
    
    static func batchImport(value: Decodable?, initialLoad: Bool) async throws -> Int {
        guard let value = value as? NavigationalWarningPropertyContainer else {
            return 0
        }
        let count = value.broadcastWarn.count
        NSLog("Received \(count) \(Self.key) records.")
        return try await Self.importRecords(from: value.broadcastWarn, taskContext: PersistenceController.current.newTaskContext())
    }
    
    static func dataRequest() -> [MSIRouter] {
        return [MSIRouter.readNavigationalWarnings]
    }
    
    static func shouldSync() -> Bool {
        // sync once every hour
        return UserDefaults.standard.dataSourceEnabled(NavigationalWarning.self) && (Date().timeIntervalSince1970 - (60 * 60)) > UserDefaults.standard.lastSyncTimeSeconds(NavigationalWarning.self)
    }
    
    static func newBatchInsertRequest(with propertyList: [NavigationalWarningProperties]) -> NSBatchInsertRequest {
        var index = 0
        let total = propertyList.count
        
        // Provide one dictionary at a time when the closure is called.
        let batchInsertRequest = NSBatchInsertRequest(entity: NavigationalWarning.entity(), dictionaryHandler: { dictionary in
            guard index < total else { return true }
            dictionary.addEntries(from: propertyList[index].dictionaryValue.filter({
                return $0.value != nil
            }) as [AnyHashable : Any])
            index += 1
            return false
        })
        batchInsertRequest.resultType = .statusOnly
        return batchInsertRequest
    }
    
    static func importRecords(from propertiesList: [NavigationalWarningProperties], taskContext: NSManagedObjectContext) async throws -> Int {
        guard !propertiesList.isEmpty else { return 0 }
        
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importNavigationalWarnings"
        
        let count = try await taskContext.perform {
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = NavigationalWarning.newBatchInsertRequest(with: propertiesList)
            batchInsertRequest.resultType = .objectIDs
            if let fetchResult = try? taskContext.execute(batchInsertRequest),
               let batchInsertResult = fetchResult as? NSBatchInsertResult {
                if let objectIds = batchInsertResult.result as? [NSManagedObjectID] {
                    if objectIds.count > 0 {
                        NSLog("Inserted \(objectIds.count) Navigational Warning records")
                        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "NavigationalWarning")
                        fetch.predicate = NSPredicate(format: "NOT (self IN %@)", objectIds)
                        let request = NSBatchDeleteRequest(fetchRequest: fetch)
                        request.resultType = .resultTypeCount
                        if let deleteResult = try? taskContext.execute(request),
                           let batchDeleteResult = deleteResult as? NSBatchDeleteResult {
                            if let count = batchDeleteResult.result as? Int {
                                NSLog("Deleted \(count) old records")
                            }
                        }
                        try? taskContext.save()
                        return objectIds.count
                    } else {
                        NSLog("No new NavigationalWarning records")
                    }
                }
                try? taskContext.save()
                return 0
            }
            throw MSIError.batchInsertError
        }
        return count
    }
}
