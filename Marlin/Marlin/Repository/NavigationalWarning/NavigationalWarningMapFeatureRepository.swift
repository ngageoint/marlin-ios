//
//  NavigationalWarningMapFeatureRepository.swift
//  Marlin
//
//  Created by Daniel Barela on 2/23/24.
//

import Foundation
import UIKit
import MapKit

class NavigationalWarningMapFeatureRepository: MapFeatureRepository, ObservableObject {

    var alwaysShow: Bool = true
    var dataSource: any DataSourceDefinition = DataSources.navWarning
    let msgYear: Int
    let msgNumber: Int
    let navArea: String
    let localDataSource: NavigationalWarningLocalDataSource

    init(
        msgYear: Int,
        msgNumber: Int,
        navArea: String,
        localDataSource: NavigationalWarningLocalDataSource
    ) {
        self.msgYear = msgYear
        self.msgNumber = msgNumber
        self.navArea = navArea
        self.localDataSource = localDataSource
    }

    func getAnnotationsAndOverlays() async -> AnnotationsAndOverlays {
        if let warning = localDataSource.getNavigationalWarning(
            msgYear: msgYear,
            msgNumber: msgNumber,
            navArea: navArea
        ) {
            return getWarningFeatures(warning: warning)
        }
        return AnnotationsAndOverlays(annotations: [], overlays: [])
    }

    func getWarningFeatures(warning: NavigationalWarningModel) -> AnnotationsAndOverlays {
        var overlays: [MKOverlay] = []
        var annotations: [MKAnnotation] = []
        guard let locations = warning.locations else {
            return AnnotationsAndOverlays(annotations: [], overlays: [])
        }
        for location in locations {
            if let wkt = location["wkt"] {
                var distance: Double?
                if let distanceString = location["distance"] {
                    distance = Double(distanceString)
                }
                if let shape = MKShape.fromWKT(wkt: wkt, distance: distance) {
                    if let polygon = shape as? MKPolygon {
                        let navPoly = NavigationalWarningPolygon(points: polygon.points(), count: polygon.pointCount)
                        navPoly.warning = warning
                        overlays.append(navPoly)
                    } else if let polyline = shape as? MKGeodesicPolyline {
                        let navline = NavigationalWarningGeodesicPolyline(
                            points: polyline.points(),
                            count: polyline.pointCount
                        )
                        navline.warning = warning
                        overlays.append(navline)
                    } else if let polyline = shape as? MKPolyline {
                        let navline = NavigationalWarningPolyline(points: polyline.points(), count: polyline.pointCount)
                        navline.warning = warning
                        overlays.append(navline)
                    } else if let point = shape as? MKPointAnnotation {
                        let navpoint = NavigationalWarningAnnotation()
                        navpoint.coordinate = point.coordinate
                        navpoint.warning = warning
                        annotations.append(navpoint)
                    } else if let circle = shape as? MKCircle {
                        let navcircle = NavigationalWarningCircle(center: circle.coordinate, radius: circle.radius)
                        navcircle.warning = warning
                        overlays.append(navcircle)
                    }
                }
            }
        }
        return AnnotationsAndOverlays(annotations: annotations, overlays: overlays)
    }

    func getItemKeys(
        minLatitude: Double,
        maxLatitude: Double,
        minLongitude: Double,
        maxLongitude: Double,
        distanceTolerance: Double
    ) -> [String] {
        []
    }
}

class NavigationalWarningsMapFeatureRepository: MapFeatureRepository, ObservableObject {
    var alwaysShow: Bool = true
    var dataSource: any DataSourceDefinition = DataSources.navWarning
    let localDataSource: NavigationalWarningLocalDataSource

    init(
        localDataSource: NavigationalWarningLocalDataSource
    ) {
        self.localDataSource = localDataSource
    }

    func getAnnotationsAndOverlays() async -> AnnotationsAndOverlays {
        let warnings = await localDataSource.getNavigationalWarnings(filters: nil)

        let x = await MainActor.run { () -> AnnotationsAndOverlays in
            var overlays: [MKOverlay] = []
            var annotations: [MKAnnotation] = []
            for warning in warnings {
                let features = getWarningFeatures(warning: warning)
                overlays.append(contentsOf: features.overlays)
                annotations.append(contentsOf: features.annotations)
            }
            return AnnotationsAndOverlays(annotations: annotations, overlays: overlays)
        }
        return x
    }

    func getWarningFeatures(warning: NavigationalWarningModel) -> AnnotationsAndOverlays {
        var overlays: [MKOverlay] = []
        var annotations: [MKAnnotation] = []
        guard let locations = warning.locations else {
            return AnnotationsAndOverlays(annotations: [], overlays: [])
        }
        for location in locations {
            if let wkt = location["wkt"] {
                var distance: Double?
                if let distanceString = location["distance"] {
                    distance = Double(distanceString)
                }
                if let shape = MKShape.fromWKT(wkt: wkt, distance: distance) {
                    if let polygon = shape as? MKPolygon {
                        let navPoly = NavigationalWarningPolygon(points: polygon.points(), count: polygon.pointCount)
                        overlays.append(navPoly)
                    } else if let polyline = shape as? MKGeodesicPolyline {
                        let navline: NavigationalWarningGeodesicPolyline = NavigationalWarningGeodesicPolyline(
                            points: polyline.points(),
                            count: polyline.pointCount
                        )
                        overlays.append(navline)
                    } else if let polyline = shape as? MKPolyline {
                        let navline = NavigationalWarningPolyline(points: polyline.points(), count: polyline.pointCount)
                        overlays.append(navline)
                    } else if let point = shape as? MKPointAnnotation {
                        let navpoint = NavigationalWarningAnnotation()
                        navpoint.coordinate = point.coordinate
                        annotations.append(navpoint)
                    } else if let circle = shape as? MKCircle {
                        let navcircle = NavigationalWarningCircle(center: circle.coordinate, radius: circle.radius)
                        overlays.append(navcircle)
                    }
                }
            }
        }
        return AnnotationsAndOverlays(annotations: annotations, overlays: overlays)
    }

    func getItemKeys(
        minLatitude: Double,
        maxLatitude: Double,
        minLongitude: Double,
        maxLongitude: Double,
        distanceTolerance: Double
    ) -> [String] {
        let location = CLLocationCoordinate2D(
            latitude: (maxLatitude - ((maxLatitude - minLatitude) / 2.0)),
            longitude: (maxLongitude - ((maxLongitude - minLongitude) / 2.0)))
        return localDataSource.getNavigationalWarningsInBounds(
            filters: nil,
            minLatitude: minLatitude,
            maxLatitude: maxLatitude,
            minLongitude: minLongitude,
            maxLongitude: maxLongitude
        ).filter { warning in
            verifyMatch(
                warning: warning,
                location: location,
                longitudeTolerance: (maxLongitude - minLongitude) / 2.0,
                distanceTolerance: distanceTolerance)
        }.map { model in
            model.itemKey
        }
    }

    func verifyMatch(
        warning: NavigationalWarningModel,
        location: CLLocationCoordinate2D,
        longitudeTolerance: Double,
        distanceTolerance: Double
    ) -> Bool {
        if let locations = warning.locations {
            for wktLocation in locations {
                if let wkt = wktLocation["wkt"] {
                    var distance: Double?
                    if let distanceString = wktLocation["distance"] {
                        distance = Double(distanceString)
                    }
                    if let shape = MKShape.fromWKT(wkt: wkt, distance: distance) {
                        if let polygon = shape as? MKPolygon {
                            for polyline in polygon.getGeodesicClickAreas()
                            where polygonHitTest(closedPolyline: polyline, location: location) {
                                return true
                            }
                        } else if let polyline = shape as? MKPolyline {
                            if lineHitTest(line: polyline, location: location, distanceTolerance: distanceTolerance) {
                                return true
                            }
                        } else if let point = shape as? MKPointAnnotation {
                            let minLon = location.longitude - longitudeTolerance
                            let maxLon = location.longitude + longitudeTolerance
                            let minLat = location.latitude - longitudeTolerance
                            let maxLat = location.latitude + longitudeTolerance
                            if minLon <= point.coordinate.longitude
                                && maxLon >= point.coordinate.longitude
                                && minLat <= point.coordinate.latitude
                                && maxLat >= point.coordinate.latitude {
                                return true
                            }
                        } else if let circle = shape as? MKCircle {
                            if circleHitTest(circle: circle, location: location) {
                                return true
                            }
                        }
                    }
                }
            }
        }
        return false
    }
}
