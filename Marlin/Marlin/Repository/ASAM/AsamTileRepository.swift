//
//  AsamTileRepository.swift
//  Marlin
//
//  Created by Daniel Barela on 1/24/24.
//

import Foundation
import UIKit
import Kingfisher

class AsamTileRepository: TileRepository, ObservableObject {
    var alwaysShow: Bool = true
    var dataSource: any DataSourceDefinition = DataSources.asam
    var cacheSourceKey: String?
    var imageCache: Kingfisher.ImageCache?
    var filterCacheKey: String {
        ""
    }
    let reference: String
    let localDataSource: AsamLocalDataSource

    init(reference: String, localDataSource: AsamLocalDataSource) {
        self.reference = reference
        self.localDataSource = localDataSource
    }

    func getTileableItems(
        minLatitude: Double,
        maxLatitude: Double,
        minLongitude: Double,
        maxLongitude: Double
    ) -> [DataSourceImage] {
        var images: [DataSourceImage] = []

        if let asam = localDataSource.getAsam(reference: reference) {
            if minLatitude...maxLatitude ~= asam.latitude && minLongitude...maxLongitude ~= asam.longitude {
                images.append(AsamImage(asam: asam))
            }
        }

        return images
    }

    func getItemKeys(
        minLatitude: Double,
        maxLatitude: Double,
        minLongitude: Double,
        maxLongitude: Double
    ) -> [String] {
        return localDataSource.getAsamsInBounds(
            filters: UserDefaults.standard.filter(DataSources.asam),
            minLatitude: minLatitude,
            maxLatitude: maxLatitude,
            minLongitude: minLongitude,
            maxLongitude: maxLongitude)
        .map { model in
            model.itemKey
        }
    }
}

class AsamsTileRepository: TileRepository, ObservableObject {
    var alwaysShow: Bool = false
    var dataSource: any DataSourceDefinition = DataSources.asam
    var cacheSourceKey: String? { dataSource.key }
    var imageCache: Kingfisher.ImageCache? {
        if let cacheSourceKey = cacheSourceKey {
            return Kingfisher.ImageCache(name: cacheSourceKey)
        }
        return nil
    }
    var filterCacheKey: String {
        UserDefaults.standard.filter(DataSources.asam).getCacheKey()
    }
    let localDataSource: AsamLocalDataSource

    init(localDataSource: AsamLocalDataSource) {
        self.localDataSource = localDataSource
    }

    func getTileableItems(
        minLatitude: Double,
        maxLatitude: Double,
        minLongitude: Double,
        maxLongitude: Double
    ) -> [DataSourceImage] {
        if !UserDefaults.standard.showOnMapasam {
            return []
        }
        return localDataSource.getAsamsInBounds(
            filters: UserDefaults.standard.filter(DataSources.asam),
            minLatitude: minLatitude,
            maxLatitude: maxLatitude,
            minLongitude: minLongitude,
            maxLongitude: maxLongitude)
        .map { model in
            AsamImage(asam: model)
        }
    }

    func getItemKeys(
        minLatitude: Double,
        maxLatitude: Double,
        minLongitude: Double,
        maxLongitude: Double
    ) -> [String] {
        if !UserDefaults.standard.showOnMapasam {
            return []
        }
        return localDataSource.getAsamsInBounds(
            filters: UserDefaults.standard.filter(DataSources.asam),
            minLatitude: minLatitude,
            maxLatitude: maxLatitude,
            minLongitude: minLongitude,
            maxLongitude: maxLongitude)
        .map { model in
            model.itemKey
        }
    }
}

class AsamImage: DataSourceImage {
    var feature: SFGeometry?
    
    static var dataSource: any DataSourceDefinition = DataSources.asam

    init(asam: AsamModel) {
        feature = asam.sfGeometry
    }

    func image(
        context: CGContext?,
        zoom: Int,
        tileBounds: MapBoundingBox,
        tileSize: Double
    ) -> [UIImage] {
        let images: [UIImage] = defaultMapImage(
                marker: false,
                zoomLevel: zoom,
                tileBounds3857: tileBounds,
                context: context,
                tileSize: tileSize
            )

        return images
    }
}