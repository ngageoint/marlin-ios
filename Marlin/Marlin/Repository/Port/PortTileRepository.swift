//
//  PortTileRepository.swift
//  Marlin
//
//  Created by Daniel Barela on 1/30/24.
//

import Foundation
import UIKit
import Kingfisher

class PortTileRepository: TileRepository, ObservableObject {
    var alwaysShow: Bool = true
    var dataSource: any DataSourceDefinition = DataSources.port
    var cacheSourceKey: String?
    var imageCache: Kingfisher.ImageCache?
    var filterCacheKey: String {
        ""
    }
    let portNumber: Int
    @Injected(\.portLocalDataSource)
    private var localDataSource: PortLocalDataSource

    init(portNumber: Int) {
        self.portNumber = portNumber
    }

    func getTileableItems(
        minLatitude: Double,
        maxLatitude: Double,
        minLongitude: Double,
        maxLongitude: Double
    ) async -> [DataSourceImage] {
        var images: [DataSourceImage] = []

        if let port = localDataSource.getPort(portNumber: portNumber) {
            if minLatitude...maxLatitude ~= port.latitude && minLongitude...maxLongitude ~= port.longitude {
                images.append(PortImage(port: port))
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
        return await localDataSource.getPortsInBounds(
            filters: UserDefaults.standard.filter(DataSources.port),
            minLatitude: minLatitude,
            maxLatitude: maxLatitude,
            minLongitude: minLongitude,
            maxLongitude: maxLongitude)
        .map { model in
            model.itemKey
        }
    }
}

class PortsTileRepository: TileRepository, ObservableObject {
    var alwaysShow: Bool = false
    var dataSource: any DataSourceDefinition = DataSources.port
    var cacheSourceKey: String? { dataSource.key }
    var imageCache: Kingfisher.ImageCache? {
        if let cacheSourceKey = cacheSourceKey {
            return Kingfisher.ImageCache(name: cacheSourceKey)
        }
        return nil
    }
    var filterCacheKey: String {
        UserDefaults.standard.filter(DataSources.port).getCacheKey()
    }
    @Injected(\.portLocalDataSource)
    private var localDataSource: PortLocalDataSource

    func getTileableItems(
        minLatitude: Double,
        maxLatitude: Double,
        minLongitude: Double,
        maxLongitude: Double
    ) async -> [DataSourceImage] {
        if !UserDefaults.standard.showOnMapport {
            return []
        }
        return await localDataSource.getPortsInBounds(
            filters: UserDefaults.standard.filter(DataSources.port),
            minLatitude: minLatitude,
            maxLatitude: maxLatitude,
            minLongitude: minLongitude,
            maxLongitude: maxLongitude)
        .map { model in
            PortImage(port: model)
        }
    }

    func getItemKeys(
        minLatitude: Double,
        maxLatitude: Double,
        minLongitude: Double,
        maxLongitude: Double
    ) async -> [String] {
        if !UserDefaults.standard.showOnMapasam {
            return []
        }
        return await localDataSource.getPortsInBounds(
            filters: UserDefaults.standard.filter(DataSources.port),
            minLatitude: minLatitude,
            maxLatitude: maxLatitude,
            minLongitude: minLongitude,
            maxLongitude: maxLongitude)
        .map { model in
            model.itemKey
        }
    }
}

class PortImage: DataSourceImage {
    var feature: SFGeometry?

    static var dataSource: any DataSourceDefinition = DataSources.port

    init(port: PortModel) {
        feature = port.sfGeometry
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
