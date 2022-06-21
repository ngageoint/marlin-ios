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
    
    var mutatingWrapper = MutatingWrapper()
    
    class MutatingWrapper {
        var mixins: [MapMixin] = []
        var mapView: MKMapView = MKMapView()
        var created = false
        var updated = false
    }
    
    func mixin(_ mixin: MapMixin) -> Self {
        mutatingWrapper.mixins.append(mixin)
        return self
    }
        
    func makeUIView(context: Context) -> MKMapView {
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.singleTapGensture(tapGestureRecognizer:)))
            singleTapGestureRecognizer.numberOfTapsRequired = 1
            singleTapGestureRecognizer.delaysTouchesBegan = true
            singleTapGestureRecognizer.cancelsTouchesInView = true
            singleTapGestureRecognizer.delegate = context.coordinator
        mutatingWrapper.mapView.addGestureRecognizer(singleTapGestureRecognizer)
        mutatingWrapper.mapView.register(ClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        mutatingWrapper.mapView.delegate = context.coordinator
        return mutatingWrapper.mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        if !mutatingWrapper.updated {
            mutatingWrapper.updated = true
            for mixin in mutatingWrapper.mixins {
                mixin.setupMixin(mapView: uiView, marlinMap: self, scheme: scheme)
            }
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

    
    init(_ marlinMap: MarlinMap) {
        self.marlinMap = marlinMap
        
        super.init()

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
            self.enlargedLocationView = nil
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

}
