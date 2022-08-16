//
//  MarlinMap.swift
//  Marlin
//
//  Created by Daniel Barela on 6/14/22.
//

import Foundation
import UIKit
import SwiftUI
import MapKit
import Combine
import PureLayout

protocol OverlayRenderable {
    var renderer: MKOverlayRenderer { get }
}

struct MarlinMap: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("mapType") var mapType: Int = Int(MKMapType.standard.rawValue)
        
    var mutatingWrapper = MutatingWrapper()
    
    class MutatingWrapper {
        var osmOverlay: MKTileOverlay?

        var mixins: [MapMixin] = []
        var mapView: MKMapView = MKMapView()
        var containerView: UIView = UIView()
        var lowerRightButtonStack: UIStackView = {
            let buttonStack = UIStackView.newAutoLayout()
            buttonStack.alignment = .fill
            buttonStack.distribution = .fill
            buttonStack.spacing = 10
            buttonStack.axis = .vertical
            buttonStack.translatesAutoresizingMaskIntoConstraints = false
            buttonStack.isLayoutMarginsRelativeArrangement = true
            return buttonStack
        }()
        var upperRightButtonStack: UIStackView = {
            let buttonStack = UIStackView.newAutoLayout()
            buttonStack.alignment = .fill
            buttonStack.distribution = .fill
            buttonStack.spacing = 10
            buttonStack.axis = .vertical
            buttonStack.translatesAutoresizingMaskIntoConstraints = false
            buttonStack.isLayoutMarginsRelativeArrangement = true
            return buttonStack
        }()
        var created = false
        var updated = false
    }
    
    @discardableResult
    func mixin(_ mixin: MapMixin) -> Self {
        mutatingWrapper.mixins.append(mixin)
        return self
    }
        
    func makeUIView(context: Context) -> UIView {
        // double tap recognizer has no action
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: nil)
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        mutatingWrapper.mapView.addGestureRecognizer(doubleTapRecognizer)
        
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.singleTapGensture(tapGestureRecognizer:)))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.numberOfTouchesRequired = 1
        singleTapGestureRecognizer.delaysTouchesBegan = true
        singleTapGestureRecognizer.cancelsTouchesInView = true
        singleTapGestureRecognizer.delegate = context.coordinator
        singleTapGestureRecognizer.require(toFail: doubleTapRecognizer)

        mutatingWrapper.mapView.addGestureRecognizer(singleTapGestureRecognizer)
        mutatingWrapper.mapView.register(ClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        mutatingWrapper.mapView.delegate = context.coordinator
        mutatingWrapper.mapView.showsUserLocation = true
        mutatingWrapper.mapView.isPitchEnabled = false
        mutatingWrapper.mapView.showsCompass = false

        if !mutatingWrapper.created {
            mutatingWrapper.created = true
            for mixin in mutatingWrapper.mixins {
                mixin.setupMixin(mapView: mutatingWrapper.mapView, marlinMap: self)
            }
        }
        mutatingWrapper.containerView.addSubview(mutatingWrapper.mapView)
        mutatingWrapper.mapView.autoPinEdgesToSuperviewEdges()
        mutatingWrapper.containerView.addSubview(mutatingWrapper.lowerRightButtonStack)
        mutatingWrapper.lowerRightButtonStack.autoPinEdge(toSuperviewEdge: .right, withInset: 8)
        mutatingWrapper.lowerRightButtonStack.autoPinEdge(toSuperviewEdge: .bottom, withInset: 24)
        mutatingWrapper.containerView.addSubview(mutatingWrapper.upperRightButtonStack)
        mutatingWrapper.upperRightButtonStack.autoPinEdge(toSuperviewEdge: .right, withInset: 8)
        mutatingWrapper.upperRightButtonStack.autoPinEdge(toSuperviewEdge: .top, withInset: 8)
        return mutatingWrapper.containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if mapType == ExtraMapTypes.osm.rawValue {
            if mutatingWrapper.osmOverlay == nil {
                mutatingWrapper.osmOverlay = MKTileOverlay(urlTemplate: "https://osm.gs.mil/tiles/default/{z}/{x}/{y}.png")
                mutatingWrapper.osmOverlay?.tileSize = CGSize(width: 512, height: 512)
                mutatingWrapper.osmOverlay?.canReplaceMapContent = true
                mutatingWrapper.mapView.addOverlay(mutatingWrapper.osmOverlay!, level: .aboveRoads)
            }
        } else if let mkmapType = MKMapType(rawValue: UInt(mapType)) {
            mutatingWrapper.mapView.mapType = mkmapType
            if let osmOverlay = mutatingWrapper.osmOverlay {
                mutatingWrapper.mapView.removeOverlay(osmOverlay)
            }
        }
        for mixin in mutatingWrapper.mixins {
            mixin.updateMixin()
        }
    }
    
    func makeCoordinator() -> MarlinMapCoordinator {
        return MarlinMapCoordinator(self)
    }
}

class MarlinMapCoordinator: NSObject, MKMapViewDelegate, UIGestureRecognizerDelegate {
    var marlinMap: MarlinMap
    var focusedAnnotation: AnnotationWithView?
    var mapAnnotationFocusedSink: AnyCancellable?
    var locationManager = CLLocationManager()
    
    init(_ marlinMap: MarlinMap) {
        self.marlinMap = marlinMap
        
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Check for Location Services
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }

        mapAnnotationFocusedSink =
        NotificationCenter.default.publisher(for: .MapAnnotationFocused)
            .compactMap {$0.object as? MapAnnotationFocusedNotification}
            .sink(receiveValue: { [weak self] in
                self?.focusAnnotation(notification:$0)
            })
    }
    
    func focusAnnotation(notification: MapAnnotationFocusedNotification) {
        guard let annotation = notification.annotation as? AnnotationWithView, annotation.annotationView != nil else {
            if let focusedAnnotation = focusedAnnotation {
                self.focusedAnnotation = nil
                if let enlargedAnnotation = focusedAnnotation as? EnlargableAnnotation {
                    // shrink the old focused view
                    marlinMap.mutatingWrapper.mapView.removeAnnotation(enlargedAnnotation)
                    enlargedAnnotation.markForShrinking()
                    marlinMap.mutatingWrapper.mapView.addAnnotation(enlargedAnnotation)
                }
            }
            return
        }
        
        if annotation.annotationView == focusedAnnotation?.annotationView {
            // already focused, ignore
            return
        } else if let focusedAnnotation = focusedAnnotation, let enlargedAnnotation = focusedAnnotation as? EnlargableAnnotation  {
            // shrink the old focused view
            marlinMap.mutatingWrapper.mapView.removeAnnotation(enlargedAnnotation)
            enlargedAnnotation.markForShrinking()
            marlinMap.mutatingWrapper.mapView.addAnnotation(enlargedAnnotation)
        }
        
        if ((annotation as? MKClusterAnnotation) != nil) {
            return
        }
        
        self.focusedAnnotation = annotation
        marlinMap.mutatingWrapper.mapView.removeAnnotation(annotation)
        annotation.clusteringIdentifier = nil
        (annotation as? EnlargableAnnotation)?.markForEnlarging()
        marlinMap.mutatingWrapper.mapView.addAnnotation(annotation)
        
        let coordinate = annotation.coordinate
        let span = self.marlinMap.mutatingWrapper.mapView.region.span
        let region = MKCoordinateRegion(center: coordinate, span: span)
        let rect = MKMapRectForCoordinateRegion(region: region)
        // Adjust padding here
        let insets = UIEdgeInsets(top: -140, left: 0, bottom: 150, right: 0)
        self.marlinMap.mutatingWrapper.mapView.setVisibleMapRect(rect, edgePadding: insets, animated: true)
    }
    
    func MKMapRectForCoordinateRegion(region:MKCoordinateRegion) -> MKMapRect {
        let topLeft = CLLocationCoordinate2D(latitude: region.center.latitude + (region.span.latitudeDelta/2), longitude: region.center.longitude - (region.span.longitudeDelta/2))
        let bottomRight = CLLocationCoordinate2D(latitude: region.center.latitude - (region.span.latitudeDelta/2), longitude: region.center.longitude + (region.span.longitudeDelta/2))
        
        let a = MKMapPoint(topLeft)
        let b = MKMapPoint(bottomRight)
        
        return MKMapRect(origin: MKMapPoint(x:min(a.x,b.x), y:min(a.y,b.y)), size: MKMapSize(width: abs(a.x-b.x), height: abs(a.y-b.y)))
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for view in views {
            
            guard let annotation = view.annotation as? EnlargableAnnotation else {
                continue
            }
            
            if annotation.shouldEnlarge {
                UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut) {
                    annotation.enlargeAnnoation()
                }
            }
            
            if annotation.shouldShrink {
                // have to enlarge it without animmation because it is added to the map at the original size
                annotation.enlargeAnnoation()
                UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut) {
                    annotation.shrinkAnnotation()
                }
            }
        }
        
    }
    
    @objc func singleTapGensture(tapGestureRecognizer: UITapGestureRecognizer) {
        if tapGestureRecognizer.state == .ended {
            self.mapTap(tapPoint: tapGestureRecognizer.location(in: marlinMap.mutatingWrapper.mapView), gesture: tapGestureRecognizer, mapView: marlinMap.mutatingWrapper.mapView)
        }
    }
    
    func mapTap(tapPoint:CGPoint, gesture: UITapGestureRecognizer, mapView: MKMapView?) {
        guard let mapView = mapView else {
            return
        }
        
        let tapCoord = mapView.convert(tapPoint, toCoordinateFrom: mapView)
        var annotationsTapped: [Any] = []
        let visibleMapRect = mapView.visibleMapRect
        let annotationsVisible = mapView.annotations(in: visibleMapRect)
        
        for annotation in annotationsVisible {
            if let mkAnnotation = annotation as? MKAnnotation, let view = mapView.view(for: mkAnnotation) {
                let location = gesture.location(in: view)
                if view.bounds.contains(location) {
                    if let annotation = annotation as? MKClusterAnnotation {
                        if mapView.zoomLevel >= MKMapView.MAX_CLUSTER_ZOOM {
                            annotationsTapped.append(contentsOf: annotation.memberAnnotations)
                        } else {
                            mapView.showAnnotations(annotation.memberAnnotations, animated: true)
                            return
                        }
                    } else {
                        annotationsTapped.append(annotation)
                    }
                }
            }
        }
        
        var items: [DataSource] = []
        for mixin in marlinMap.mutatingWrapper.mixins {
            if let matchedItems = mixin.items(at: tapCoord) {
                items.append(contentsOf: matchedItems)
            }
        }
        
        let notification = MapItemsTappedNotification(annotations: annotationsTapped, items: items, mapView: mapView)
        NotificationCenter.default.post(name: .MapItemsTapped, object: notification)
    }
        
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let renderableOverlay = overlay as? OverlayRenderable {
            return renderableOverlay.renderer
        }
        for mixin in marlinMap.mutatingWrapper.mixins {
            if let renderer = mixin.renderer(overlay: overlay) {
                return renderer
            }
        }
        return MKTileOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        for mixin in marlinMap.mutatingWrapper.mixins {
            if let view = mixin.viewForAnnotation(annotation: annotation, mapView: mapView){
                return view
            }
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        for mixin in marlinMap.mutatingWrapper.mixins {
            mixin.regionDidChange(mapView: mapView, animated: animated)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        for mixin in marlinMap.mutatingWrapper.mixins {
            mixin.regionWillChange(mapView: mapView, animated: animated)
        }
    }
    
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        for mixin in marlinMap.mutatingWrapper.mixins {
            mixin.didChangeUserTrackingMode(mapView: mapView, animated: animated)
        }
    }
    
    func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        for mixin in marlinMap.mutatingWrapper.mixins {
            mixin.traitCollectionUpdated(previous: previousTraitCollection)
        }
    }

}

extension MarlinMapCoordinator: CLLocationManagerDelegate {
    
    func checkLocationAuthorization(authorizationStatus: CLAuthorizationStatus? = nil) {
        switch (authorizationStatus) {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .restricted, .denied:
            // show alert instructing how to turn on permissions
            print("Location Servies: Denied / Restricted")
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .none:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            print("who knows")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.checkLocationAuthorization(authorizationStatus: status)
    }
}
