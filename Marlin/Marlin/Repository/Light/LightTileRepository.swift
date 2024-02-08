//
//  LightTileRepository.swift
//  Marlin
//
//  Created by Daniel Barela on 2/5/24.
//

import Foundation
import UIKit
import Kingfisher

class LightTileRepository: TileRepository, ObservableObject {
    var alwaysShow: Bool = true
    var dataSource: any DataSourceDefinition = DataSources.light

    var cacheSourceKey: String?
    
    var imageCache: Kingfisher.ImageCache?
    
    var filterCacheKey: String {
        ""
    }

    let featureNumber: String
    let volumeNumber: String
    let localDataSource: LightLocalDataSource

    init(featureNumber: String, volumeNumber: String, localDataSource: LightLocalDataSource) {
        self.featureNumber = featureNumber
        self.volumeNumber = volumeNumber
        self.localDataSource = localDataSource
    }

    func getTileableItems(
        minLatitude: Double,
        maxLatitude: Double,
        minLongitude: Double,
        maxLongitude: Double
    ) -> [DataSourceImage] {
        var images: [DataSourceImage] = []

        let light = localDataSource.getCharacteristic(
            featureNumber: featureNumber,
            volumeNumber: volumeNumber,
            characteristicNumber: 1
        )
        if let light = light {
            if minLatitude...maxLatitude ~= light.latitude && minLongitude...maxLongitude ~= light.longitude {
                images.append(LightImage(light: light))
            }
        }

        return images
    }
    
    func getItemKeys(minLatitude: Double, maxLatitude: Double, minLongitude: Double, maxLongitude: Double) -> [String] {
        return localDataSource.getLightsInBounds(
            filters: UserDefaults.standard.filter(DataSources.light),
            minLatitude: minLatitude,
            maxLatitude: maxLatitude,
            minLongitude: minLongitude,
            maxLongitude: maxLongitude)
        .map { model in
            model.itemKey
        }
    }
}

class LightsTileRepository: TileRepository, ObservableObject {
    var alwaysShow: Bool = false
    var dataSource: any DataSourceDefinition = DataSources.light

    var cacheSourceKey: String? { dataSource.key }

    var imageCache: Kingfisher.ImageCache? {
        if let cacheSourceKey = cacheSourceKey {
            return Kingfisher.ImageCache(name: cacheSourceKey)
        }
        return nil
    }

    var filterCacheKey: String {
        UserDefaults.standard.filter(DataSources.light).getCacheKey()
    }
    let localDataSource: LightLocalDataSource

    init(localDataSource: LightLocalDataSource) {
        self.localDataSource = localDataSource
    }

    func getTileableItems(
        minLatitude: Double,
        maxLatitude: Double,
        minLongitude: Double,
        maxLongitude: Double
    ) -> [DataSourceImage] {
        if !UserDefaults.standard.showOnMaplight {
            return []
        }
        return localDataSource.getLightsInBounds(
            filters: UserDefaults.standard.filter(DataSources.light),
            minLatitude: minLatitude,
            maxLatitude: maxLatitude,
            minLongitude: minLongitude,
            maxLongitude: maxLongitude)
        .map { model in
            LightImage(light: model)
        }
    }
    
    func getItemKeys(
        minLatitude: Double,
        maxLatitude: Double,
        minLongitude: Double,
        maxLongitude: Double
    ) -> [String] {
        if !UserDefaults.standard.showOnMaplight {
            return []
        }
        return localDataSource.getLightsInBounds(
            filters: UserDefaults.standard.filter(DataSources.light),
            minLatitude: minLatitude,
            maxLatitude: maxLatitude,
            minLongitude: minLongitude,
            maxLongitude: maxLongitude)
        .map { model in
            model.itemKey
        }
    }
}

// class LightImage: DataSourceImage {
//    var feature: SFGeometry?
//
//    static var dataSource: any DataSourceDefinition = DataSources.light
//
//    init(light: LightModel) {
//        feature = light.sfGeometry
//    }
//
//    func image(
//        context: CGContext?,
//        zoom: Int,
//        tileBounds: MapBoundingBox,
//        tileSize: Double
//    ) -> [UIImage] {
//        let images: [UIImage] = defaultMapImage(
//            marker: false,
//            zoomLevel: zoom,
//            tileBounds3857: tileBounds,
//            context: context,
//            tileSize: tileSize
//        )
//
//        return images
//    }
// }
