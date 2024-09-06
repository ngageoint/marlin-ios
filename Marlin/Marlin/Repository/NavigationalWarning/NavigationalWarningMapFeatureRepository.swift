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
    @Injected(\.navWarningLocalDataSource)
    var localDataSource: NavigationalWarningLocalDataSource

    init(
        msgYear: Int,
        msgNumber: Int,
        navArea: String
    ) {
        self.msgYear = msgYear
        self.msgNumber = msgNumber
        self.navArea = navArea
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

    func getItemKeys(
        minLatitude: Double,
        maxLatitude: Double,
        minLongitude: Double,
        maxLongitude: Double
    ) async -> [String] {
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

    @Injected(\.navWarningLocalDataSource)
    var localDataSource: NavigationalWarningLocalDataSource

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
        guard let locations = warning.locations else {
            return false
        }
        for wktLocation in locations {
            if let wkt = wktLocation["wkt"] {
                var distance: Double?
                if let distanceString = wktLocation["distance"] {
                    distance = Double(distanceString)
                }
                if let shape = MKShape.fromWKT(wkt: wkt, distance: distance) {
                    switch shape {
                    case let polygon as MKPolygon:
                        for polyline in polygon.getGeodesicClickAreas()
                        where polygonHitTest(closedPolyline: polyline, location: location) {
                            return true
                        }
                    case let polyline as MKPolyline:
                        if lineHitTest(line: polyline, location: location, distanceTolerance: distanceTolerance) {
                            return true
                        }
                    case let point as MKPointAnnotation:
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
                    case let circle as MKCircle:
                        if circleHitTest(circle: circle, location: location) {
                            return true
                        }
                    default:
                        return false
                    }
                }
            }
        }
        return false
    }
}
