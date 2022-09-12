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
            
    init(center: CLLocationCoordinate2D, zoom: Double, bounds: CGRect) {
        let zoom = min(zoom, 20)
        let span = MKCoordinateSpan(center: center, zoom: zoom, bounds: bounds)
        self.init(center: center, span: span)
    }
}

extension MKCoordinateSpan {
    
    static var mercatorOffset: Double {
        return 268435456.0
    }
    
    static var mercatorRadius: Double {
        return 85445659.44705395
    }
    
    private static func longitudeToPixelSpaceX(longitude: Double) -> Double {
        return round(mercatorOffset + mercatorRadius * longitude * Double.pi / 180.0)
    }
    
    private static func latitudeToPixelSpaceY(latitude: Double) -> Double {
        return round(mercatorOffset - mercatorRadius * log((1 + sin(latitude * Double.pi / 180.0)) / (1 - sin(latitude * Double.pi / 180.0))) / 2.0)
    }
    
    private static func pixelSpaceXToLongitude(pixelX: Double) -> Double {
        return ((round(pixelX) - mercatorOffset) / mercatorRadius) * 180.0 / Double.pi
    }
    
    private static func pixelSpaceYToLatitude(pixelY: Double) -> Double {
        return (Double.pi / 2.0 - 2.0 * atan(exp((round(pixelY) - mercatorOffset) / mercatorRadius))) * 180.0 / Double.pi
    }
    
    init(center: CLLocationCoordinate2D, zoom: Double, bounds: CGRect) {
        
        let centerPixelX = MKCoordinateSpan.longitudeToPixelSpaceX(longitude: center.longitude)
        let centerPixelY = MKCoordinateSpan.latitudeToPixelSpaceY(latitude: center.latitude)
        
        let zoomExponent = Double(20 - zoom)
        let zoomScale = pow(2.0, zoomExponent)
        
        let mapSizeInPixels = bounds.size
        let scaledMapWidth =  Double(mapSizeInPixels.width) * zoomScale
        let scaledMapHeight = Double(mapSizeInPixels.height) * zoomScale
        
        let topLeftPixelX = centerPixelX - (scaledMapWidth / 2)
        let topLeftPixelY = centerPixelY - (scaledMapHeight / 2)
        
        // find delta between left and right longitudes
        let minLng = MKCoordinateSpan.pixelSpaceXToLongitude(pixelX: topLeftPixelX)
        let maxLng = MKCoordinateSpan.pixelSpaceXToLongitude(pixelX: topLeftPixelX + scaledMapWidth)
        let longitudeDelta = maxLng - minLng
        
        let minLat = MKCoordinateSpan.pixelSpaceYToLatitude(pixelY: topLeftPixelY)
        let maxLat = MKCoordinateSpan.pixelSpaceYToLatitude(pixelY: topLeftPixelY + scaledMapHeight)
        let latitudeDelta = -1 * (maxLat - minLat)
        
        self.init(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
    }
}
