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
    var alwaysShow: Bool = true
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
    ) async -> [DataSourceImage] {
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
    ) async -> [String] {
        return await localDataSource.getModusInBounds(
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
    var alwaysShow: Bool = false
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
    ) async -> [DataSourceImage] {
        if !UserDefaults.standard.showOnMapmodu {
            return []
        }
        return await localDataSource.getModusInBounds(
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
    ) async -> [String] {
        if !UserDefaults.standard.showOnMapmodu {
            return []
        }
        return await localDataSource.getModusInBounds(
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
    var modu: ModuModel

    static var dataSource: any DataSourceDefinition = DataSources.modu

    init(modu: ModuModel) {
        self.modu = modu
        feature = modu.sfGeometry
    }

    func image(
        context: CGContext?,
        zoom: Int,
        tileBounds: MapBoundingBox,
        tileSize: Double
    ) -> [UIImage] {

        var images: [UIImage] = []
        if let distance = modu.distance, distance > 0 {
            let circleCoordinates = modu.coordinate.circleCoordinates(radiusMeters: distance * 1852)
            let path = UIBezierPath()
            var pixel = circleCoordinates[0].toPixel(
                zoomLevel: zoom,
                tileBounds3857: tileBounds,
                tileSize: TILE_SIZE
            )
            path.move(to: pixel)
            for circleCoordinate in circleCoordinates {
                pixel = circleCoordinate.toPixel(
                    zoomLevel: zoom,
                    tileBounds3857: tileBounds,
                    tileSize: TILE_SIZE
                )
                path.addLine(to: pixel)
            }
            path.lineWidth = 4
            path.close()
            DataSources.modu.color.withAlphaComponent(0.3).setFill()
            DataSources.modu.color.setStroke()
            path.fill()
            path.stroke()
        }
        images.append(
            contentsOf: defaultMapImage(
                marker: false,
                zoomLevel: zoom,
                tileBounds3857: tileBounds,
                context: context,
                tileSize: 512.0
            )
        )
        return images
    }
}
