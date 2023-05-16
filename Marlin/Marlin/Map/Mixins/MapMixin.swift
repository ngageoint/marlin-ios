//
//  MapMixin.swift
//  Marlin
//
//  Created by Daniel Barela on 6/14/22.
//

import Foundation
import MapKit
import SwiftUI
import geopackage_ios

protocol MapMixin: AnyObject {
    func setupMixin(marlinMap: MarlinMap, mapView: MKMapView)
    func updateMixin(mapView: MKMapView, mapState: MapState)
    func renderer(overlay: MKOverlay) -> MKOverlayRenderer?
    func traitCollectionUpdated(previous: UITraitCollection?)
    func regionDidChange(mapView: MKMapView, animated: Bool)
    func viewForAnnotation(annotation: MKAnnotation, mapView: MKMapView) -> MKAnnotationView?
    func items(at location: CLLocationCoordinate2D, mapView: MKMapView, touchPoint: CGPoint) -> [any DataSource]?
}

extension MapMixin {
    
    func polygonHitTest(polygon: MKPolygon, location: CLLocationCoordinate2D) -> Bool {
        guard let renderer = (renderer(overlay: polygon) as? MKPolygonRenderer ?? standardRenderer(overlay: polygon) as? MKPolygonRenderer) else {
            return false
        }
        let mapPoint = MKMapPoint.init(location)
        let point = renderer.point(for: mapPoint)
        var onShape = renderer.path?.contains(point) ?? false
        // If not on the polygon, check the complementary polygon path in case it crosses -180 / 180 longitude
        if !onShape {
            if let complementaryPath: Unmanaged<CGPath> = GPKGMapUtils.complementaryWorldPath(of: polygon) {
                let retained = complementaryPath.takeRetainedValue()
                onShape = retained.contains(CGPoint(x: mapPoint.x, y: mapPoint.y))
            }
        }
        
        return onShape
    }
    
    func lineHitTest(line: MKPolyline, location: CLLocationCoordinate2D, tolerance: Double) -> Bool {
        guard let renderer = (renderer(overlay: line) as? MKPolylineRenderer ?? standardRenderer(overlay: line) as? MKPolylineRenderer) else {
            return false
        }
        let mapPoint = MKMapPoint.init(location)
        let point = renderer.point(for: mapPoint)
        let strokedPath = renderer.path?.copy(strokingWithWidth: tolerance, lineCap: .round, lineJoin: .round, miterLimit: 1)
        
        var onShape = strokedPath?.contains(point) ?? false
        // If not on the line, check the complementary polygon path in case it crosses -180 / 180 longitude
        if !onShape {
            if let complementaryPath: Unmanaged<CGPath> = GPKGMapUtils.complementaryWorldPath(of: line) {
                let retained = complementaryPath.takeRetainedValue()
                let complimentaryStrokedPath = retained.copy(strokingWithWidth: tolerance, lineCap: .round, lineJoin: .round, miterLimit: 1)
                onShape = complimentaryStrokedPath.contains(CGPoint(x: mapPoint.x, y: mapPoint.y))
            }
        }
        
        return onShape
    }
    
    func circleHitTest(circle: MKCircle, location: CLLocationCoordinate2D) -> Bool {
        guard let renderer = (renderer(overlay: circle) as? MKCircleRenderer ?? standardRenderer(overlay: circle) as? MKCircleRenderer) else {
            return false
        }
        let mapPoint = MKMapPoint.init(location)
        let point = renderer.point(for: mapPoint)
        var onShape = renderer.path?.contains(point) ?? false

        return onShape
    }
    
    func updateMixin(mapView: MKMapView, mapState: MapState) {
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
        } else if let circle = overlay as? MKCircle {
            let renderer = MKCircleRenderer(circle: circle)
            renderer.strokeColor = .black
            renderer.lineWidth = 1
            return renderer
        }
        return nil
    }
    
    func traitCollectionUpdated(previous: UITraitCollection?){ }

    func viewForAnnotation(annotation: MKAnnotation, mapView: MKMapView) -> MKAnnotationView? {
        return nil
    }
    
    func items(at location: CLLocationCoordinate2D, mapView: MKMapView, touchPoint: CGPoint) -> [any DataSource]? {
        return nil
    }
    
    func regionDidChange(mapView: MKMapView, animated: Bool) {
    }
}
