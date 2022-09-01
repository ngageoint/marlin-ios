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
    func mapImage(marker: Bool, zoomLevel: Int) -> [UIImage]
    var latitude: Double { get }
    var longitude: Double { get }
    var coordinate: CLLocationCoordinate2D { get }
}

extension MapImage {
    func mapImage(marker: Bool, zoomLevel: Int) -> [UIImage] {
        var images: [UIImage] = []
        let scale = UIScreen.main.scale
        if let dataSource = self as? DataSource {
//            var images: [UIImage] = []
            if zoomLevel == 100 {
                if let image = CircleImage(color: dataSource.color, radius: 100 * scale, fill: true) {
                    images.append(image)
                    if let dataSourceImage = type(of:dataSource).image?.aspectResize(to: CGSize(width: image.size.width / 1.5, height: image.size.height / 1.5)).withRenderingMode(.alwaysTemplate).maskWithColor(color: UIColor.white){
                        images.append(dataSourceImage)
                    }
                }
            } else if zoomLevel > 12 {
                if let image = CircleImage(color: dataSource.color, radius: 3 * scale * type(of:dataSource).imageScale, fill: true) {
                    images.append(image)
                    if let dataSourceImage = type(of:dataSource).image?.aspectResize(to: CGSize(width: image.size.width / 1.5, height: image.size.height / 1.5)).withRenderingMode(.alwaysTemplate).maskWithColor(color: UIColor.white){
                        images.append(dataSourceImage)
                    }
                }
            } else if zoomLevel > 5 {
                if let image = CircleImage(color: dataSource.color, radius: 2 * scale * type(of:dataSource).imageScale, fill: true) {
                    images.append(image)
                    if let dataSourceImage = type(of:dataSource).image?.aspectResize(to: CGSize(width: image.size.width / 1.5, height: image.size.height / 1.5)).withRenderingMode(.alwaysTemplate).maskWithColor(color: UIColor.white){
                        images.append(dataSourceImage)
                    }
                }
            } else {
                if let image = CircleImage(color: dataSource.color, radius: 1 * scale * type(of:dataSource).imageScale, fill: true) {
                    images.append(image)
                }
            }
        }
        
        return images
    }
}
