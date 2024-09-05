//
//  MapFeatureRepository.swift
//  Marlin
//
//  Created by Daniel Barela on 2/23/24.
//

import Foundation
import MapKit
import geopackage_ios

struct AnnotationsAndOverlays {
    let annotations: [MKAnnotation]
    let overlays: [MKOverlay]
}

protocol MapFeatureRepository {
    var dataSource: any DataSourceDefinition { get }
    var alwaysShow: Bool { get }

    func getAnnotationsAndOverlays() async -> AnnotationsAndOverlays
    func getItemKeys(
        minLatitude: Double,
        maxLatitude: Double,
        minLongitude: Double,
        maxLongitude: Double,
        distanceTolerance: Double
    ) async -> [String]
}

extension MapFeatureRepository {
    func polygonHitTest(polygon: MKPolygon, location: CLLocationCoordinate2D) -> Bool {
        guard let renderer = standardRenderer(overlay: polygon) as? MKPolygonRenderer else {
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

    func polygonHitTest(closedPolyline: MKGeodesicPolyline, location: CLLocationCoordinate2D) -> Bool {
        guard let renderer = standardRenderer(overlay: closedPolyline) as? MKPolylineRenderer else {
            return false
        }
        let mapPoint = MKMapPoint.init(location)
        let point = renderer.point(for: mapPoint)
        let onShape = renderer.path?.contains(point) ?? false
        return onShape
    }

    func lineHitTest(line: MKPolyline, location: CLLocationCoordinate2D, distanceTolerance: Double) -> Bool {
        guard let renderer = standardRenderer(overlay: line) as? MKPolylineRenderer else {
            return false
        }
        renderer.invalidatePath()

        let mapPoint = MKMapPoint(location)
        let point = renderer.point(for: mapPoint)
        let bufferedPath = renderer.path.copy(
            strokingWithWidth: distanceTolerance * 2,
            lineCap: renderer.lineCap,
            lineJoin: renderer.lineJoin,
            miterLimit: renderer.miterLimit
        )
        let onShape = bufferedPath.contains(point)
        return onShape
    }

    func circleHitTest(circle: MKCircle, location: CLLocationCoordinate2D) -> Bool {
        guard let renderer = standardRenderer(overlay: circle) as? MKCircleRenderer else {
            return false
        }
        let mapPoint = MKMapPoint.init(location)
        let point = renderer.point(for: mapPoint)
        return renderer.path?.contains(point) ?? false
    }

    func standardRenderer(overlay: MKOverlay) -> MKOverlayRenderer? {
        if let renderable = overlay as? OverlayRenderable {
            return renderable.renderer
        }
        // standard renderers
        if let polygon = overlay as? MKPolygon, type(of: polygon) == MKPolygon.self {
            let renderer = MKPolygonRenderer(polygon: polygon)
            renderer.strokeColor = .black
            renderer.lineWidth = 1
            return renderer
        } else if let polyline = overlay as? MKPolyline, type(of: polyline) == MKPolyline.self {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .black
            renderer.lineWidth = 1
            return renderer
        } else if let polyline = overlay as? MKPolyline, type(of: polyline) == MKGeodesicPolyline.self {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .black
            renderer.lineWidth = 1
            return renderer
        } else if let circle = overlay as? MKCircle, type(of: circle) == MKCircle.self {
            let renderer = MKCircleRenderer(circle: circle)
            renderer.strokeColor = .black
            renderer.lineWidth = 1
            return renderer
        }
        return nil
    }
}
