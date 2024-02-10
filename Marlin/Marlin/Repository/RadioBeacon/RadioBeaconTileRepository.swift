//
//  RadioBeaconTileRepository.swift
//  Marlin
//
//  Created by Daniel Barela on 2/7/24.
//

import Foundation
import UIKit
import Kingfisher

class RadioBeaconTileRepository: TileRepository, ObservableObject {
    var alwaysShow: Bool = true
    var dataSource: any DataSourceDefinition = DataSources.radioBeacon
    var cacheSourceKey: String?
    var imageCache: Kingfisher.ImageCache?
    var filterCacheKey: String {
        ""
    }
    let featureNumber: Int
    let volumeNumber: String
    let localDataSource: RadioBeaconLocalDataSource

    init(featureNumber: Int, volumeNumber: String, localDataSource: RadioBeaconLocalDataSource) {
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

        if let radioBeacon = localDataSource.getRadioBeacon(featureNumber: featureNumber, volumeNumber: volumeNumber) {
            if minLatitude...maxLatitude ~= radioBeacon.latitude && minLongitude...maxLongitude ~= radioBeacon.longitude {
                images.append(RadioBeaconImage(radioBeacon: radioBeacon))
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
        return localDataSource.getRadioBeaconsInBounds(
            filters: UserDefaults.standard.filter(DataSources.radioBeacon),
            minLatitude: minLatitude,
            maxLatitude: maxLatitude,
            minLongitude: minLongitude,
            maxLongitude: maxLongitude)
        .map { model in
            model.itemKey
        }
    }
}

class RadioBeaconsTileRepository: TileRepository, ObservableObject {
    var alwaysShow: Bool = false
    var dataSource: any DataSourceDefinition = DataSources.radioBeacon
    var cacheSourceKey: String? { dataSource.key }
    var imageCache: Kingfisher.ImageCache? {
        if let cacheSourceKey = cacheSourceKey {
            return Kingfisher.ImageCache(name: cacheSourceKey)
        }
        return nil
    }
    var filterCacheKey: String {
        UserDefaults.standard.filter(DataSources.radioBeacon).getCacheKey()
    }
    let localDataSource: RadioBeaconLocalDataSource

    init(localDataSource: RadioBeaconLocalDataSource) {
        self.localDataSource = localDataSource
    }

    func getTileableItems(
        minLatitude: Double,
        maxLatitude: Double,
        minLongitude: Double,
        maxLongitude: Double
    ) -> [DataSourceImage] {
        if !UserDefaults.standard.showOnMapradioBeacon {
            return []
        }
        return localDataSource.getRadioBeaconsInBounds(
            filters: UserDefaults.standard.filter(DataSources.radioBeacon),
            minLatitude: minLatitude,
            maxLatitude: maxLatitude,
            minLongitude: minLongitude,
            maxLongitude: maxLongitude)
        .map { model in
            RadioBeaconImage(radioBeacon: model)
        }
    }

    func getItemKeys(
        minLatitude: Double,
        maxLatitude: Double,
        minLongitude: Double,
        maxLongitude: Double
    ) -> [String] {
        if !UserDefaults.standard.showOnMapradioBeacon {
            return []
        }
        return localDataSource.getRadioBeaconsInBounds(
            filters: UserDefaults.standard.filter(DataSources.radioBeacon),
            minLatitude: minLatitude,
            maxLatitude: maxLatitude,
            minLongitude: minLongitude,
            maxLongitude: maxLongitude)
        .map { model in
            model.itemKey
        }
    }
}

class RadioBeaconImage: DataSourceImage {
    var feature: SFGeometry?
    let radioBeacon: RadioBeaconModel

    static var dataSource: any DataSourceDefinition = DataSources.radioBeacon

    init(radioBeacon: RadioBeaconModel) {
        self.radioBeacon = radioBeacon
        feature = radioBeacon.sfGeometry
    }

    func image(
        context: CGContext?,
        zoom: Int,
        tileBounds: MapBoundingBox,
        tileSize: Double
    ) -> [UIImage] {

        var images: [UIImage] = []
        if let raconImage = raconImage(scale: 2, azimuthCoverage: radioBeacon.azimuthCoverage, zoomLevel: zoom) {
            images.append(raconImage)
            drawImageIntoTile(
                mapImage: raconImage,
                latitude: radioBeacon.latitude,
                longitude: radioBeacon.longitude,
                tileBounds3857: tileBounds,
                tileSize: tileSize
            )
        }
        return images
    }

    func raconImage(scale: Int, azimuthCoverage: [ImageSector]? = nil, zoomLevel: Int) -> UIImage? {
        let radius = CGFloat(zoomLevel) / 3.0 * UIScreen.main.scale * DataSources.radioBeacon.imageScale
        let sectors = azimuthCoverage ?? [ImageSector(startDegrees: 0, endDegrees: 360, color: DataSources.radioBeacon.color)]

        if zoomLevel > 8 {
            return RaconImage(
                frame: CGRect(x: 0, y: 0, width: 3 * (radius + 3.0), height: 3 * (radius + 3.0)),
                sectors: sectors,
                arcWidth: 3.0,
                arcRadius: radius + 3.0,
                text: "Racon (\(radioBeacon.morseLetter))",
                darkMode: false)
        } else {
            return CircleImage(
                color: DataSources.radioBeacon.color,
                radius: radius,
                fill: false,
                arcWidth: min(3.0, radius / 2.0))
        }
    }
}
