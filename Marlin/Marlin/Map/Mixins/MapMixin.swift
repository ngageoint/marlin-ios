//
//  MapMixin.swift
//  Marlin
//
//  Created by Daniel Barela on 6/14/22.
//

import Foundation
import MapKit
import SwiftUI
//import geopackage_ios

protocol MapMixin: AnyObject {
    func setupMixin(marlinMap: MarlinMap, mapView: MKMapView)
    func updateMixin(mapView: MKMapView, marlinMap: MarlinMap)
    func cleanupMixin()
    func renderer(overlay: MKOverlay) -> MKOverlayRenderer?
    func traitCollectionUpdated(previous: UITraitCollection?)
    func regionDidChange(mapView: MKMapView, animated: Bool)
    func regionWillChange(mapView: MKMapView, animated: Bool)
    func didChangeUserTrackingMode(mapView: MKMapView, animated: Bool)
    func viewForAnnotation(annotation: MKAnnotation, mapView: MKMapView) -> MKAnnotationView?
    func items(at location: CLLocationCoordinate2D, mapView: MKMapView) -> [DataSource]?
    func applyTheme(scheme: MarlinScheme?)
}

extension MapMixin {
    
    func cleanupMixin() {
    }
    
    func renderer(overlay: MKOverlay) -> MKOverlayRenderer? {
        return standardRenderer(overlay: overlay)
    }
    
    func standardRenderer(overlay: MKOverlay) -> MKOverlayRenderer? {
        if let renderable = overlay as? OverlayRenderable {
            return renderable.renderer
        }
        // standard renderers
        if let polygon = overlay as? MKPolygon {
            let renderer = MKPolygonRenderer(polygon: polygon)
            renderer.strokeColor = .black
            renderer.lineWidth = 1
            return renderer
        } else if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .black
            renderer.lineWidth = 1
            return renderer
        }
        return nil
    }
    
    func traitCollectionUpdated(previous: UITraitCollection?){ }
    func regionDidChange(mapView: MKMapView, animated: Bool) { }
    func regionWillChange(mapView: MKMapView, animated: Bool) { }
    func didChangeUserTrackingMode(mapView: MKMapView, animated: Bool) { }
    
    func viewForAnnotation(annotation: MKAnnotation, mapView: MKMapView) -> MKAnnotationView? {
        return nil
    }
    
    func items(at location: CLLocationCoordinate2D, mapView: MKMapView) -> [DataSource]? {
        return nil
    }
    
    func applyTheme(scheme: MarlinScheme?) {
    }
}
