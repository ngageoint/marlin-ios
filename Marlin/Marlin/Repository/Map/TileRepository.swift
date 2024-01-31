//
//  TileRepository.swift
//  Marlin
//
//  Created by Daniel Barela on 1/24/24.
//

import Foundation
import UIKit
import sf_ios
import Kingfisher
import CoreLocation

protocol DataSourceImage {
    var feature: SFGeometry? { get set }
    static var dataSource: any DataSourceDefinition { get }
    static var imageCache: Kingfisher.ImageCache { get }
    @discardableResult
    func image(
        context: CGContext?,
        zoom: Int,
        tileBounds: MapBoundingBox,
        tileSize: Double
    ) -> [UIImage]
}

extension DataSourceImage {
    static var imageCache: Kingfisher.ImageCache {
        Kingfisher.ImageCache(name: dataSource.key)
    }

    var TILE_SIZE: Double {
        return 512.0
    }

    static func defaultCircleImage() -> [UIImage] {
        var images: [UIImage] = []
        if let circleImage = CircleImage(color: dataSource.color, radius: 40 * UIScreen.main.scale, fill: true) {
            images.append(circleImage)
            if let image = dataSource.image,
                let dataSourceImage = image.aspectResize(
                    to: CGSize(width: circleImage.size.width / 1.5, height: circleImage.size.height / 1.5))
                .withRenderingMode(.alwaysTemplate)
                .maskWithColor(color: UIColor.white) {
                images.append(dataSourceImage)
            }
        }
        return images
    }

    func defaultMapImage(
        marker: Bool,
        zoomLevel: Int,
        pointCoordinate: CLLocationCoordinate2D? = nil,
        tileBounds3857: MapBoundingBox? = nil,
        context: CGContext? = nil,
        tileSize: Double
    ) -> [UIImage] {

        var images: [UIImage] = []
        var radius = CGFloat(zoomLevel) / 3.0 * UIScreen.main.scale * Self.dataSource.imageScale

        // zoom level 36 is a temporary hack to draw a large image for a real map marker
        if zoomLevel != 36 {
            if let tileBounds3857 = tileBounds3857, context != nil {
                // have to do this b/c an ImageRenderer will automatically do this
                radius *= UIScreen.main.scale
                let coordinate = pointCoordinate ?? {
                    if let point = SFGeometryUtils.centroid(of: feature) {
                        return CLLocationCoordinate2D(latitude: point.y.doubleValue, longitude: point.x.doubleValue)
                    }
                    return kCLLocationCoordinate2DInvalid
                }()
                if CLLocationCoordinate2DIsValid(coordinate) {
                    let pixel = coordinate.toPixel(
                        zoomLevel: zoomLevel,
                        tileBounds3857: tileBounds3857,
                        tileSize: tileSize)
                    let circle = UIBezierPath(
                        arcCenter: pixel,
                        radius: radius,
                        startAngle: 0,
                        endAngle: 2 * CGFloat.pi,
                        clockwise: true)
                    circle.lineWidth = 0.5
                    Self.dataSource.color.setStroke()
                    circle.stroke()
                    Self.dataSource.color.setFill()
                    circle.fill()
                    if let dataSourceImage = Self.dataSource.image?.aspectResize(
                        to: CGSize(width: radius * 2.0 / 1.5, height: radius * 2.0 / 1.5))
                        .withRenderingMode(.alwaysTemplate).maskWithColor(color: UIColor.white) {
                        dataSourceImage.draw(
                            at: CGPoint(
                                x: pixel.x - dataSourceImage.size.width / 2.0,
                                y: pixel.y - dataSourceImage.size.height / 2.0))
                    }
                }
            } else {
                if let image = CircleImage(color: Self.dataSource.color, radius: radius, fill: true) {
                    images.append(image)
                    if let dataSourceImage = Self.dataSource.image?.aspectResize(
                        to: CGSize(
                            width: image.size.width / 1.5,
                            height: image.size.height / 1.5)).withRenderingMode(.alwaysTemplate)
                        .maskWithColor(color: UIColor.white) {
                        images.append(dataSourceImage)
                    }
                }
            }
        } else {
            images.append(contentsOf: Self.defaultCircleImage())
        }
        return images
    }
}

protocol TileRepository {
    var dataSource: any DataSourceDefinition { get }
    var cacheSourceKey: String? { get }

    var imageCache: Kingfisher.ImageCache? { get }

    var filterCacheKey: String { get }

    func getTileableItems(
        minLatitude: Double,
        maxLatitude: Double,
        minLongitude: Double,
        maxLongitude: Double
    ) -> [DataSourceImage]

    func getItemKeys(
        minLatitude: Double,
        maxLatitude: Double,
        minLongitude: Double,
        maxLongitude: Double
    ) -> [String]

    func clearCache(completion: @escaping () -> Void)
}

extension TileRepository {
    func clearCache(completion: @escaping () -> Void) {
        if let imageCache = self.imageCache {
            imageCache.clearCache(completion: completion)
        } else {
            completion()
        }
    }
}
