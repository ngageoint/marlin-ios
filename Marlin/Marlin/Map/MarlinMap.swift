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

protocol OverlayRenderable {
    var renderer: MKOverlayRenderer { get }
}

struct MarlinMap: UIViewRepresentable {
    
    @EnvironmentObject var scheme: MarlinScheme
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
    
    func mixin(_ mixin: MapMixin) -> Self {
        mutatingWrapper.mixins.append(mixin)
        return self
    }
        
    func makeUIView(context: Context) -> UIView {
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.singleTapGensture(tapGestureRecognizer:)))
            singleTapGestureRecognizer.numberOfTapsRequired = 1
            singleTapGestureRecognizer.delaysTouchesBegan = true
            singleTapGestureRecognizer.cancelsTouchesInView = true
            singleTapGestureRecognizer.delegate = context.coordinator
        mutatingWrapper.mapView.addGestureRecognizer(singleTapGestureRecognizer)
        mutatingWrapper.mapView.register(ClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        mutatingWrapper.mapView.delegate = context.coordinator
        mutatingWrapper.mapView.showsUserLocation = true

        if !mutatingWrapper.created {
            mutatingWrapper.created = true
            for mixin in mutatingWrapper.mixins {
                mixin.setupMixin(mapView: mutatingWrapper.mapView, marlinMap: self, scheme: scheme)
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
    var enlargedLocationView: MKAnnotationView?
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
        guard let annotation = notification.annotation as? AnnotationWithView, let annotationView = annotation.annotationView else {
            if let enlargedLocationView = enlargedLocationView {
                self.enlargedLocationView = nil
                // shrink the old focused view
                UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut) {
                    enlargedLocationView.transform = enlargedLocationView.transform.scaledBy(x: 0.5, y: 0.5)
                    if let image = enlargedLocationView.image {
                        enlargedLocationView.centerOffset = CGPoint(x: 0, y: -(image.size.height / 2.0))
                    } else {
                        enlargedLocationView.center = CGPoint(x: 0, y: enlargedLocationView.center.y / 2.0)
                    }
                }
            }
            return
        }
        
        if annotationView == enlargedLocationView {
            // already focused, ignore
            return
        } else if let enlargedLocationView = enlargedLocationView {
            // shrink the old focused view
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut) {
                enlargedLocationView.transform = enlargedLocationView.transform.scaledBy(x: 0.5, y: 0.5)
                if let image = enlargedLocationView.image {
                    enlargedLocationView.centerOffset = CGPoint(x: 0, y: -(image.size.height / 2.0))
                } else {
                    enlargedLocationView.center = CGPoint(x: 0, y: enlargedLocationView.center.y / 2.0)
                }
            }
        }
        
        if ((annotation as? MKClusterAnnotation) != nil) {
            return
        }
        
        self.enlargedLocationView = annotationView
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut) {
            annotationView.transform = annotationView.transform.scaledBy(x: 2.0, y: 2.0)
            if let image = annotationView.image {
                annotationView.centerOffset = CGPoint(x: 0, y: -(image.size.height))
            } else {
                annotationView.centerOffset = CGPoint(x: 0, y: annotationView.center.y * 2.0)
            }
            if let mkannotation = annotation as? MKAnnotation {
                notification.mapView?.setCenter(mkannotation.coordinate, animated: false)
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
                        mapView.showAnnotations(annotation.memberAnnotations, animated: true)
                        return
                    } else {
                        annotationsTapped.append(annotation)
                    }
                }
            }
        }
        
        var items: [Any] = []
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
