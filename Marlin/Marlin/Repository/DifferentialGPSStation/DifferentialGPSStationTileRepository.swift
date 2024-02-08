//
//  DifferentialGPSStationTileRepository.swift
//  Marlin
//
//  Created by Daniel Barela on 2/8/24.
//

import Foundation
import UIKit
import Kingfisher

class DifferentialGPSStationTileRepository: TileRepository, ObservableObject {
    var dataSource: any DataSourceDefinition = DataSources.dgps
    var cacheSourceKey: String?
    var imageCache: Kingfisher.ImageCache?
    var filterCacheKey: String {
        ""
    }
    let featureNumber: Int
    let volumeNumber: String
    let localDataSource: DifferentialGPSStationLocalDataSource
    var alwaysShow: Bool = true

    init(featureNumber: Int, volumeNumber: String, localDataSource: DifferentialGPSStationLocalDataSource) {
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

        if let dgps = localDataSource.getDifferentialGPSStation(featureNumber: featureNumber, volumeNumber: volumeNumber) {
            if minLatitude...maxLatitude ~= dgps.latitude && minLongitude...maxLongitude ~= dgps.longitude {
                images.append(DifferentialGPSStationImage(differentialGPSStation: dgps))
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
        return localDataSource.getDifferentialGPSStationsInBounds(
            filters: UserDefaults.standard.filter(DataSources.dgps),
            minLatitude: minLatitude,
            maxLatitude: maxLatitude,
            minLongitude: minLongitude,
            maxLongitude: maxLongitude)
        .map { model in
            model.itemKey
        }
    }
}

class DifferentialGPSStationsTileRepository: TileRepository, ObservableObject {
    var alwaysShow: Bool = false
    var dataSource: any DataSourceDefinition = DataSources.dgps
    var cacheSourceKey: String? { dataSource.key }
    var imageCache: Kingfisher.ImageCache? {
        if let cacheSourceKey = cacheSourceKey {
            return Kingfisher.ImageCache(name: cacheSourceKey)
        }
        return nil
    }
    var filterCacheKey: String {
        UserDefaults.standard.filter(DataSources.dgps).getCacheKey()
    }
    let localDataSource: DifferentialGPSStationLocalDataSource

    init(localDataSource: DifferentialGPSStationLocalDataSource) {
        self.localDataSource = localDataSource
    }

    func getTileableItems(
        minLatitude: Double,
        maxLatitude: Double,
        minLongitude: Double,
        maxLongitude: Double
    ) -> [DataSourceImage] {
        if !UserDefaults.standard.showOnMapdifferentialGPSStation {
            return []
        }
        return localDataSource.getDifferentialGPSStationsInBounds(
            filters: UserDefaults.standard.filter(DataSources.dgps),
            minLatitude: minLatitude,
            maxLatitude: maxLatitude,
            minLongitude: minLongitude,
            maxLongitude: maxLongitude)
        .map { model in
            DifferentialGPSStationImage(differentialGPSStation: model)
        }
    }

    func getItemKeys(
        minLatitude: Double,
        maxLatitude: Double,
        minLongitude: Double,
        maxLongitude: Double
    ) -> [String] {
        if !UserDefaults.standard.showOnMapdifferentialGPSStation {
            return []
        }
        return localDataSource.getDifferentialGPSStationsInBounds(
            filters: UserDefaults.standard.filter(DataSources.dgps),
            minLatitude: minLatitude,
            maxLatitude: maxLatitude,
            minLongitude: minLongitude,
            maxLongitude: maxLongitude)
        .map { model in
            model.itemKey
        }
    }
}

class DifferentialGPSStationImage: DataSourceImage {
    var feature: SFGeometry?

    static var dataSource: any DataSourceDefinition = DataSources.dgps

    init(differentialGPSStation: DifferentialGPSStationModel) {
        feature = differentialGPSStation.sfGeometry
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
