//
//  AnnotationWithView.swift
//  Marlin
//
//  Created by Daniel Barela on 7/26/22.
//

import Foundation
import MapKit

protocol AnnotationWithView: MKAnnotation {
    var annotationView: MKAnnotationView? { get set }
    var color: UIColor { get }
    var clusteringIdentifier: String? { get set }
}

protocol MapImage {
    func mapImage(marker: Bool, zoomLevel: Int, tileBounds3857: MapBoundingBox?, context: CGContext?) -> [UIImage]
    var latitude: Double { get }
    var longitude: Double { get }
    var coordinate: CLLocationCoordinate2D { get }
}

extension MapImage {
    func defaultMapImage(marker: Bool, zoomLevel: Int, tileBounds3857: MapBoundingBox? = nil, context: CGContext? = nil, tileSize: Double) -> [UIImage] {
        var images: [UIImage] = []
        if let dataSource = self as? DataSource {
            var radius = CGFloat(zoomLevel) / 3.0 * UIScreen.main.scale * type(of:dataSource).imageScale
            
            // zoom level 36 is a temporary hack to draw a large image for a real map marker
            if zoomLevel != 36 {
                if let tileBounds3857 = tileBounds3857, let _ = context {
                    // have to do this b/c an ImageRenderer will automatically do this
                    radius *= UIScreen.main.scale
                    let pixel = coordinate.toPixel(zoomLevel: zoomLevel, tileBounds3857: tileBounds3857, tileSize: tileSize)
                    let circle = UIBezierPath(arcCenter: pixel, radius: radius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
                    circle.lineWidth = 0.5
                    dataSource.color.setStroke()
                    circle.stroke()
                    dataSource.color.setFill()
                    circle.fill()
                    if let cachedImage = type(of:dataSource).cachedImage(zoomLevel: zoomLevel) {
                        cachedImage.draw(at: CGPoint(x: pixel.x - cachedImage.size.width / 2.0, y: pixel.y - cachedImage.size.height / 2.0))
                    } else if let dataSourceImage = type(of:dataSource).image?.aspectResize(to: CGSize(width: radius * 2.0 / 1.5, height: radius * 2.0 / 1.5)).withRenderingMode(.alwaysTemplate).maskWithColor(color: UIColor.white){
                        type(of:dataSource).cacheImage(zoomLevel: zoomLevel, image: dataSourceImage)
                        dataSourceImage.draw(at: CGPoint(x: pixel.x - dataSourceImage.size.width / 2.0, y: pixel.y - dataSourceImage.size.height / 2.0))
                    }
                } else {
                    if let image = CircleImage(color: dataSource.color, radius: radius, fill: true) {
                        images.append(image)
                        if let dataSourceImage = type(of:dataSource).image?.aspectResize(to: CGSize(width: image.size.width / 1.5, height: image.size.height / 1.5)).withRenderingMode(.alwaysTemplate).maskWithColor(color: UIColor.white){
                            images.append(dataSourceImage)
                        }
                    }
                }
            } else {
                if let image = CircleImage(color: dataSource.color, radius: 100 * UIScreen.main.scale, fill: true) {
                    images.append(image)
                    if let dataSourceImage = type(of:dataSource).image?.aspectResize(to: CGSize(width: image.size.width / 1.5, height: image.size.height / 1.5)).withRenderingMode(.alwaysTemplate).maskWithColor(color: UIColor.white){
                        images.append(dataSourceImage)
                    }
                }
            }
        }
        
        return images
    }
}
