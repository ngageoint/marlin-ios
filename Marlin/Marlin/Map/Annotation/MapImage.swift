//
//  MapImage.swift
//  Marlin
//
//  Created by Daniel Barela on 11/29/22.
//

import Foundation
import UIKit
import MapKit
import Kingfisher

protocol MapImage {
    static var definition: any DataSourceDefinition { get }
    func mapImage(marker: Bool, zoomLevel: Int, tileBounds3857: MapBoundingBox?, context: CGContext?) -> [UIImage]
    var latitude: Double { get }
    var longitude: Double { get }
    var coordinate: CLLocationCoordinate2D { get }
    var TILE_SIZE: Double { get }
    static var key: String { get }
    static var cacheTiles: Bool { get }
    static var imageCache: Kingfisher.ImageCache { get }
    static var color: UIColor { get }
    static var image: UIImage? { get }
}

extension MapImage {
    static var imageCache: Kingfisher.ImageCache {
        Kingfisher.ImageCache(name: key)
    }

    var TILE_SIZE: Double {
        return 512.0
    }
    
    static func defaultCircleImage() -> [UIImage] {
        var images: [UIImage] = []
        if let circleImage = CircleImage(color: color, radius: 40 * UIScreen.main.scale, fill: true) {
            images.append(circleImage)
            if let image = image, 
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
        tileSize: Double) -> [UIImage] {

        var images: [UIImage] = []
//        if let dataSource = self as? (any DataSource) {
        var radius = CGFloat(zoomLevel) / 3.0 * UIScreen.main.scale * Self.definition.imageScale
            
            // zoom level 36 is a temporary hack to draw a large image for a real map marker
            if zoomLevel != 36 {
                if let tileBounds3857 = tileBounds3857, context != nil {
                    // have to do this b/c an ImageRenderer will automatically do this
                    radius *= UIScreen.main.scale
                    let coordinate = pointCoordinate ?? coordinate
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
                        Self.definition.color.setStroke()
                        circle.stroke()
                        Self.definition.color.setFill()
                        circle.fill()
                        if let dataSourceImage = Self.definition.image?.aspectResize(
                            to: CGSize(width: radius * 2.0 / 1.5, height: radius * 2.0 / 1.5))
                            .withRenderingMode(.alwaysTemplate).maskWithColor(color: UIColor.white) {
                            dataSourceImage.draw(
                                at: CGPoint(
                                    x: pixel.x - dataSourceImage.size.width / 2.0,
                                    y: pixel.y - dataSourceImage.size.height / 2.0))
                        }
                    }
                } else {
                    if let image = CircleImage(color: Self.definition.color, radius: radius, fill: true) {
                        images.append(image)
                        if let dataSourceImage = Self.definition.image?.aspectResize(
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
//        }
        return images
    }
}
