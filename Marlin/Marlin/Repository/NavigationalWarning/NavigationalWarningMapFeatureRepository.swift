//
//  NavigationalWarningMapFeatureRepository.swift
//  Marlin
//
//  Created by Daniel Barela on 2/23/24.
//

import Foundation
import UIKit
import MapKit
import Kingfisher

class NavigationalWarningMapFeatureRepository: MapFeatureRepository, TileRepository, ObservableObject {
    var cacheSourceKey: String?
    var imageCache: Kingfisher.ImageCache?

    var filterCacheKey: String {
        ""
    }
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

    func getTileableItems(
        minLatitude: Double,
        maxLatitude: Double,
        minLongitude: Double,
        maxLongitude: Double
    ) async -> [DataSourceImage] {
        if !UserDefaults.standard.showOnMapnavWarning {
            return []
        }
        return await localDataSource.getNavigationalWarningsInBounds(
            filters: UserDefaults.standard.filter(DataSources.navWarning),
            minLatitude: minLatitude,
            maxLatitude: maxLatitude,
            minLongitude: minLongitude,
            maxLongitude: maxLongitude
        )
        .map { model in
            NavigationalWarningImage(navigationalWarning: model)
        }
    }

    func getItemKeys(minLatitude: Double, maxLatitude: Double, minLongitude: Double, maxLongitude: Double) async -> [String] {
        []
    }

    func getAnnotationsAndOverlays() async -> AnnotationsAndOverlays {
        return AnnotationsAndOverlays(annotations: [], overlays: [])
    }

    func getItemKeys(
        minLatitude: Double,
        maxLatitude: Double,
        minLongitude: Double,
        maxLongitude: Double,
        distanceTolerance: Double
    ) async -> [String] {
        []
    }
}

class NavigationalWarningsMapFeatureRepository: MapFeatureRepository, TileRepository, ObservableObject {
    var dataSource: any DataSourceDefinition = DataSources.navWarning
    var cacheSourceKey: String? { dataSource.key }
    lazy var imageCache: Kingfisher.ImageCache? = {
        if let cacheSourceKey = cacheSourceKey {
            return Kingfisher.ImageCache(name: cacheSourceKey)
        }
        return nil
    }()

    var filterCacheKey: String {
        UserDefaults.standard.filter(dataSource).getCacheKey()
    }

    var alwaysShow: Bool = false

    func getTileableItems(
        minLatitude: Double,
        maxLatitude: Double,
        minLongitude: Double,
        maxLongitude: Double
    ) async -> [DataSourceImage] {
        if !UserDefaults.standard.showOnMapnavWarning {
            return []
        }
        return await localDataSource.getNavigationalWarningsInBounds(
            filters: UserDefaults.standard.filter(DataSources.navWarning),
            minLatitude: minLatitude,
            maxLatitude: maxLatitude,
            minLongitude: minLongitude,
            maxLongitude: maxLongitude
        )
        .map { model in
            NavigationalWarningImage(navigationalWarning: model)
        }
    }

    func getItemKeys(
        minLatitude: Double,
        maxLatitude: Double,
        minLongitude: Double,
        maxLongitude: Double
    ) async -> [String] {
        []
    }

    let localDataSource: NavigationalWarningLocalDataSource

    init(
        localDataSource: NavigationalWarningLocalDataSource
    ) {
        self.localDataSource = localDataSource
    }

    func getAnnotationsAndOverlays() async -> AnnotationsAndOverlays {
        return AnnotationsAndOverlays(annotations: [], overlays: [])
    }

    func getWarningFeatures(warning: NavigationalWarningModel) -> AnnotationsAndOverlays {
        return AnnotationsAndOverlays(annotations: [], overlays: [])
    }

    func getItemKeys(
        minLatitude: Double,
        maxLatitude: Double,
        minLongitude: Double,
        maxLongitude: Double,
        distanceTolerance: Double
    ) async -> [String] {
        let location = CLLocationCoordinate2D(
            latitude: (maxLatitude - ((maxLatitude - minLatitude) / 2.0)),
            longitude: (maxLongitude - ((maxLongitude - minLongitude) / 2.0)))
        return await localDataSource.getNavigationalWarningsInBounds(
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
