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
    func defaultMapImage(marker: Bool, zoomLevel: Int, tileBounds3857: MapBoundingBox? = nil) -> [UIImage] {
        var images: [UIImage] = []
        if let dataSource = self as? DataSource {
            let radius = CGFloat(zoomLevel) / 3.0 * UIScreen.main.scale * type(of:dataSource).imageScale
            
            // zoom level 36 is a temporary hack to draw a large image for a real map marker
            if zoomLevel != 36 {
                if let image = CircleImage(color: dataSource.color, radius: radius, fill: true) {
                    images.append(image)
                    if let dataSourceImage = type(of:dataSource).image?.aspectResize(to: CGSize(width: image.size.width / 1.5, height: image.size.height / 1.5)).withRenderingMode(.alwaysTemplate).maskWithColor(color: UIColor.white){
                        images.append(dataSourceImage)
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
