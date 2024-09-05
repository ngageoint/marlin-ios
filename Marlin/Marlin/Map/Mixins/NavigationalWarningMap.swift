//
//  NavigationWarningMap.swift
//  Marlin
//
//  Created by Daniel Barela on 5/1/23.
//

import Foundation
import MapKit
import CoreData
import Combine
import sf_wkt_ios

class NavigationalWarningPolygon: MKPolygon {
    var warning: NavigationalWarningModel?
}

class NavigationalWarningPolyline: MKPolyline {
    var warning: NavigationalWarningModel?
}

class NavigationalWarningGeodesicPolyline: MKGeodesicPolyline {
    var warning: NavigationalWarningModel?
}

class NavigationalWarningAnnotation: MKPointAnnotation {
    var warning: NavigationalWarningModel?
}

class NavigationalWarningCircle: MKCircle {
    var warning: NavigationalWarningModel?
}

class NavigationalWarningMap: DataSourceMap {

    override var minZoom: Int {
        get {
            return 2
        }
        set {

        }
    }

    override init(repository: TileRepository? = nil, mapFeatureRepository: MapFeatureRepository? = nil) {
        super.init(repository: repository, mapFeatureRepository: mapFeatureRepository)

        orderPublisher = UserDefaults.standard.orderPublisher(key: DataSources.navWarning.key)
        userDefaultsShowPublisher = UserDefaults.standard.publisher(for: \.showOnMapnavWarning)
    }

    override func setupMixin(mapState: MapState, mapView: MKMapView) {
        super.setupMixin(mapState: mapState, mapView: mapView)
        mapView.register(ImageAnnotationView.self, forAnnotationViewWithReuseIdentifier: NavigationalWarning.key)
    }

    override func viewForAnnotation(annotation: MKAnnotation, mapView: MKMapView) -> MKAnnotationView? {
        if annotation is NavigationalWarningAnnotation {
            let annotationView = mapView.dequeueReusableAnnotationView(
                withIdentifier: NavigationalWarning.key,
                for: annotation)
            if let systemImageName = DataSources.navWarning.systemImageName {
                let radius = CGFloat(2) / 3.0 * UIScreen.main.scale * DataSources.navWarning.imageScale
                if let image = CircleImage(color: DataSources.navWarning.color, radius: radius, fill: true) {
                    if let dataSourceImage = DataSources.navWarning.image?.aspectResize(
                        to: CGSize(
                            width: image.size.width / 1.5,
                            height: image.size.height / 1.5)).withRenderingMode(.alwaysTemplate)
                        .maskWithColor(color: UIColor.white) {
                        let combinedImage: UIImage? = UIImage.combineCentered(image1: image, image2: dataSourceImage)
                        annotationView.image = combinedImage ?? UIImage(systemName: systemImageName)
                    }
                }
            }
            return annotationView
        }
        return nil
    }

    override func renderer(overlay: MKOverlay) -> MKOverlayRenderer? {
        if let polygon = overlay as? NavigationalWarningPolygon {
            let renderer = MKPolygonRenderer(polygon: polygon)
            renderer.strokeColor = NavigationalWarning.color
            renderer.lineWidth = 3
            renderer.fillColor = NavigationalWarning.color.withAlphaComponent(0.3)
            return renderer
        } else if let polyline = overlay as? NavigationalWarningGeodesicPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = NavigationalWarning.color
            renderer.lineWidth = 3
            return renderer
        } else if let polyline = overlay as? NavigationalWarningPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = NavigationalWarning.color
            renderer.lineWidth = 3
            return renderer
        } else if let circle = overlay as? NavigationalWarningCircle {
            let renderer = MKCircleRenderer(circle: circle)
            renderer.strokeColor = NavigationalWarning.color
            renderer.fillColor = NavigationalWarning.color.withAlphaComponent(0.2)
            renderer.lineWidth = 3
            return renderer
        }
        return nil
    }

    override func itemKeys(
        at location: CLLocationCoordinate2D,
        mapView: MKMapView,
        touchPoint: CGPoint
    ) async -> [String: [String]] {
        if await mapView.zoomLevel < minZoom {
            return [:]
        }
        guard show == true else {
            return [:]
        }
        let screenPercentage = 0.03
        let tolerance = await mapView.region.span.longitudeDelta * Double(screenPercentage)
        let minLon = location.longitude - tolerance
        let maxLon = location.longitude + tolerance
        let minLat = location.latitude - tolerance
        let maxLat = location.latitude + tolerance

        let distanceTolerance = await mapView.visibleMapRect.size.width * Double(screenPercentage)

        return [
            dataSourceKey: await mapFeatureRepository?.getItemKeys(
                minLatitude: minLat,
                maxLatitude: maxLat,
                minLongitude: minLon,
                maxLongitude: maxLon,
                distanceTolerance: distanceTolerance
            ) ?? []
        ]
    }
}
