//
//  MKMapViewExtensions.swift
//  Marlin
//
//  Created by Daniel Barela on 7/25/22.
//

import Foundation
import MapKit

extension MKMapView {
    
    static let MAX_CLUSTER_ZOOM = 17
    
    var zoomLevel: Int {
        let maxZoom: Double = 20
        let zoomScale = self.visibleMapRect.size.width / Double(self.frame.size.width)
        let zoomExponent = log2(zoomScale)
        return Int(maxZoom - ceil(zoomExponent))
    }
    
}

extension MKCoordinateSpan {
    init(zoomLevel: Double, pixelWidth: Double) {
        self.init(latitudeDelta: 0, longitudeDelta: (360.0/pow(2.0, zoomLevel)) * pixelWidth/256.0)
    }
}

extension MKCoordinateRegion {
    init(center: CLLocationCoordinate2D, zoomLevel: Double, pixelWidth: Double) {
        self.init(center: center, span: MKCoordinateSpan(zoomLevel: zoomLevel, pixelWidth: pixelWidth))
    }
}
