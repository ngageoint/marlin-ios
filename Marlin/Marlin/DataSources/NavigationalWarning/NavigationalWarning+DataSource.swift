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

extension NavigationalWarning: Bookmarkable {
    var canBookmark: Bool {
        return true
    }
    
    var itemKey: String {
        return "\(msgYear)--\(msgNumber)--\(navArea ?? "")"
    }
    
    static func getItem(context: NSManagedObjectContext, itemKey: String?) -> Bookmarkable? {
        if let split = itemKey?.split(separator: "--"), split.count == 3 {
            return getNavigationalWarning(
                context: context,
                msgYear: Int64(split[0]) ?? 0,
                msgNumber: Int64(split[1]) ?? 0,
                navArea: "\(split[2])"
            )
        }
        return nil
    }
    
    static func getNavigationalWarning(
        context: NSManagedObjectContext,
        msgYear: Int64,
        msgNumber: Int64,
        navArea: String?
    ) -> NavigationalWarning? {
        if let navArea = navArea {
            return try? context.fetchFirst(
                NavigationalWarning.self,
                predicate: NSPredicate(
                    format: "msgYear = %d AND msgNumber = %d AND navArea = %@",
                    argumentArray: [msgYear, msgNumber, navArea]
                )
            )
        }
        return nil
    }
}

extension NavigationalWarning: Locatable, GeoPackageExportable, GeoJSONExportable {
    static var definition: any DataSourceDefinition = DataSources.navWarning

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

    func geodesicLine(
        firstPoint: CLLocationCoordinate2D?,
        flipped: inout SFLineString?,
        sfLineString: SFLineString,
        previousPoint: CLLocationCoordinate2D,
        currentPoint: CLLocationCoordinate2D
    ) {
        var coords: [CLLocationCoordinate2D] = [previousPoint, currentPoint]
        let geodesicLine = MKGeodesicPolyline(coordinates: &coords, count: 2)

        let glpoints = geodesicLine.points()

        for glpoint in UnsafeBufferPointer(start: glpoints, count: geodesicLine.pointCount) {
            let currentGlPoint = glpoint.coordinate
            if let firstPoint = firstPoint,
               abs(firstPoint.longitude - currentGlPoint.longitude) > 90 {
                if flipped == nil {
                    flipped = SFLineString()
                }
                flipped?.addPoint(
                    SFPoint(
                        xValue: currentGlPoint.longitude,
                        andYValue: currentGlPoint.latitude
                    )
                )

            } else {
                sfLineString.addPoint(
                    SFPoint(
                        xValue: currentGlPoint.longitude,
                        andYValue: currentGlPoint.latitude
                    )
                )

            }
        }
    }

    func locationPolygon(polygon: MKPolygon) -> SFGeometry? {
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
                    geodesicLine(
                        firstPoint: firstPoint,
                        flipped: &flipped,
                        sfLineString: sfLineString,
                        previousPoint: previous,
                        currentPoint: currentPoint
                    )
                    previousPoint = currentPoint
                } else {
                    previousPoint = point.coordinate
                }
            }

            // now draw the geodesic line between the last and the first
            if let previousPoint = previousPoint, let firstPoint = firstPoint {
                geodesicLine(
                    firstPoint: firstPoint,
                    flipped: &flipped,
                    sfLineString: sfLineString,
                    previousPoint: previousPoint,
                    currentPoint: firstPoint
                )
            }

            sfPoly?.addRing(sfLineString)
        }
        if let flipped = flipped, let sfPoly = sfPoly, let flippedPoly = SFPolygon(ring: flipped) {
            return SFGeometryCollection(geometries: [flippedPoly, sfPoly])
        }
        return sfPoly
    }

    func locationLine(polyline: MKPolyline) -> SFGeometry? {
        let sfLineString = SFLineString()

        for point in polyline.points().toArray(capacity: polyline.pointCount) {
            sfLineString?.addPoint(
                SFPoint(
                    xValue: point.coordinate.longitude,
                    andYValue: point.coordinate.latitude
                )
            )
        }
        return sfLineString
    }

    func locationGeometry(location: [String: String]) -> SFGeometry? {
        guard let wkt = location["wkt"] else {
            return nil
        }
        var distance: Double?
        if let distanceString = location["distance"] {
            distance = Double(distanceString)
        }
        if let shape = MKShape.fromWKT(wkt: wkt, distance: distance) {
            if let polygon = shape as? MKPolygon {
                return locationPolygon(polygon: polygon)
            } else if let polyline = shape as? MKGeodesicPolyline {
                return locationLine(polyline: polyline)
            } else if let polyline = shape as? MKPolyline {
                return locationLine(polyline: polyline)
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
            format: """
                (maxLatitude >= %lf AND minLatitude <= %lf AND maxLongitude >= %lf AND minLongitude <= %lf) \
                OR minLongitude < -180 OR maxLongitude > 180
            """, minLat, maxLat, minLon, maxLon
        )
    }
    
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter
    }
    static var isMappable: Bool = true
    static var dataSourceName: String = NSLocalizedString("Warnings", comment: "Warnings data source display name")
    static var fullDataSourceName: String = 
    NSLocalizedString("Navigational Warnings",
                      comment: "Warnings data source display name")
    static var key: String = "navWarning"
    static var metricsKey: String = "navigational_warnings"
    static var color: UIColor = UIColor(argbValue: 0xFFD32F2F)
    static var imageName: String?
    static var systemImageName: String? = "exclamationmark.triangle.fill"
    static var imageScale: CGFloat = 1.0
    
    static func postProcess() {
        imageCache.clearCache()
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
                
                NotificationCenter.default.post(
                    Notification(
                        name: .DataSourceProcessed,
                        object: DataSourceUpdatedNotification(key: NavigationalWarning.key)))
            }
        }
    }

    var color: UIColor {
        return NavigationalWarning.color
    }
    
    static var defaultSort: [DataSourceSortParameter] = [
        DataSourceSortParameter(
            property: DataSourceProperty(
                name: "Navigational Area",
                key: "navArea",
                type: .string),
            ascending: false),
        DataSourceSortParameter(
            property: DataSourceProperty(
                name: "Issue Date",
                key: "issueDate",
                type: .date),
            ascending: false)
    ]

    static var defaultFilter: [DataSourceFilterParameter] = []
    
    static var properties: [DataSourceProperty] = [
        DataSourceProperty(name: "Navigational Area", key: #keyPath(NavigationalWarning.navArea), type: .string)
    ]
    
    var coordinateRegion: MKCoordinateRegion? {
        region
    }
}

extension NavigationalWarning: BatchImportable {
    
    static var seedDataFiles: [String]?
    static var decodableRoot: Decodable.Type = NavigationalWarningPropertyContainer.self
    
    static func batchImport(value: Decodable?, initialLoad: Bool) async throws -> Int {
        guard let value = value as? NavigationalWarningPropertyContainer else {
            return 0
        }
        let count = value.broadcastWarn.count
        NSLog("Received \(count) \(Self.key) records.")
        return try await Self.importRecords(
            from: value.broadcastWarn,
            taskContext: PersistenceController.current.newTaskContext())
    }
    
    static func dataRequest() -> [MSIRouter] {
        return [MSIRouter.readNavigationalWarnings]
    }
    
    static func shouldSync() -> Bool {
        // sync once every hour
        return UserDefaults.standard
            .dataSourceEnabled(NavigationalWarning.definition)
        && (Date().timeIntervalSince1970 - (60 * 60)) >
        UserDefaults.standard.lastSyncTimeSeconds(NavigationalWarning.definition)
    }
    
    static func newBatchInsertRequest(with propertyList: [NavigationalWarningProperties]) -> NSBatchInsertRequest {
        var index = 0
        let total = propertyList.count
        
        // Provide one dictionary at a time when the closure is called.
        let batchInsertRequest = NSBatchInsertRequest(
            entity: NavigationalWarning.entity(),
            dictionaryHandler: { dictionary in
            guard index < total else { return true }
            let propertyDictionary = propertyList[index].dictionaryValue
            dictionary.addEntries(from: propertyDictionary.mapValues({ value in
                if let value = value {
                    return value
                }
                return NSNull()
            }) as [AnyHashable: Any])
            
            index += 1
            return false
        })
        batchInsertRequest.resultType = .statusOnly
        return batchInsertRequest
    }
    
    static func importRecords(
        from propertiesList: [NavigationalWarningProperties],
        taskContext: NSManagedObjectContext) async throws -> Int {
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
