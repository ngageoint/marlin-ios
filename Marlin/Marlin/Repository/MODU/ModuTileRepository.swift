//
//  ModuTileRepository.swift
//  Marlin
//
//  Created by Daniel Barela on 1/26/24.
//

import Foundation
import UIKit
import sf_geojson_ios
import Kingfisher

class ModuTileRepository: TileRepository, ObservableObject {
    var dataSource: any DataSourceDefinition = DataSources.modu
    var cacheSourceKey: String?
    var imageCache: Kingfisher.ImageCache?
    var filterCacheKey: String {
        ""
    }
    let name: String
    let localDataSource: ModuLocalDataSource

    init(name: String, localDataSource: ModuLocalDataSource) {
        self.name = name
        self.localDataSource = localDataSource
    }

    func getTileableItems(
        minLatitude: Double,
        maxLatitude: Double,
        minLongitude: Double,
        maxLongitude: Double
    ) -> [DataSourceImage] {
        var images: [DataSourceImage] = []

        if let modu = localDataSource.getModu(name: name) {
            if minLatitude...maxLatitude ~= modu.latitude && minLongitude...maxLongitude ~= modu.longitude {
                images.append(ModuImage(modu: modu))
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
        return localDataSource.getModusInBounds(
            filters: UserDefaults.standard.filter(DataSources.modu),
            minLatitude: minLatitude,
            maxLatitude: maxLatitude,
            minLongitude: minLongitude,
            maxLongitude: maxLongitude)
        .map { model in
            model.itemKey
        }
    }
}

class ModusTileRepository: TileRepository, ObservableObject {
    var dataSource: any DataSourceDefinition = DataSources.modu
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
    let localDataSource: ModuLocalDataSource

    init(localDataSource: ModuLocalDataSource) {
        self.localDataSource = localDataSource
    }

    func getTileableItems(
        minLatitude: Double,
        maxLatitude: Double,
        minLongitude: Double,
        maxLongitude: Double
    ) -> [DataSourceImage] {
        if !UserDefaults.standard.showOnMapmodu {
            return []
        }
        return localDataSource.getModusInBounds(
            filters: UserDefaults.standard.filter(DataSources.modu),
            minLatitude: minLatitude,
            maxLatitude: maxLatitude,
            minLongitude: minLongitude,
            maxLongitude: maxLongitude)
        .map { model in
            ModuImage(modu: model)
        }
    }

    func getItemKeys(
        minLatitude: Double,
        maxLatitude: Double,
        minLongitude: Double,
        maxLongitude: Double
    ) -> [String] {
        if !UserDefaults.standard.showOnMapmodu {
            return []
        }
        return localDataSource.getModusInBounds(
            filters: UserDefaults.standard.filter(DataSources.modu),
            minLatitude: minLatitude,
            maxLatitude: maxLatitude,
            minLongitude: minLongitude,
            maxLongitude: maxLongitude)
        .map { model in
            model.itemKey
        }
    }
}

class ModuImage: DataSourceImage {
    var feature: SFGeometry?

    static var dataSource: any DataSourceDefinition = DataSources.modu

    init(modu: ModuModel) {
        feature = modu.sfGeometry
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
