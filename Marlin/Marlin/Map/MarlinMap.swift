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
import CoreData
import gars_ios
import mgrs_ios

protocol OverlayRenderable {
    var renderer: MKOverlayRenderer { get }
}

class MapSingleTap: UITapGestureRecognizer {
    var mapView: MKMapView?
}

class MapState: ObservableObject {
    @Published var userTrackingMode: Int = Int(MKUserTrackingMode.none.rawValue)
    @Published var center: MKCoordinateRegion?
    @Published var forceCenter: MKCoordinateRegion? {
        didSet {
            forceCenterDate = Date()
        }
    }
    var forceCenterDate: Date?
    
    @Published var searchResults: [MKMapItem]?
    
    @AppStorage("mapType") var mapType: Int = Int(MKMapType.standard.rawValue)
    @AppStorage("showGARS") var showGARS: Bool = false
    @AppStorage("showMGRS") var showMGRS: Bool = false
    @AppStorage("showMapScale") var showMapScale = false
    
    @Published var mixinStates: [String: Any] = [:]
}

struct MarlinMap: UIViewRepresentable {
    @ObservedObject var mapState: MapState

    @State var mixins: [MapMixin]?
    @State var name: String
    
    init(name: String, mixins: [MapMixin]? = [], mapState: MapState? = nil) {
        self.name = name
        if let mapState = mapState {
            self.mapState = mapState
        } else {
            self.mapState = MapState()
        }
        self._mixins = State(wrappedValue: mixins)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: UIScreen.main.bounds)
        // double tap recognizer has no action
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: nil)
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        mapView.addGestureRecognizer(doubleTapRecognizer)
                
        let singleTapGestureRecognizer = MapSingleTap(target: context.coordinator, action: #selector(context.coordinator.singleTapGensture(tapGestureRecognizer:)))
        singleTapGestureRecognizer.mapView = mapView
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.numberOfTouchesRequired = 1
        singleTapGestureRecognizer.delaysTouchesBegan = true
        singleTapGestureRecognizer.cancelsTouchesInView = true
        singleTapGestureRecognizer.delegate = context.coordinator
        singleTapGestureRecognizer.require(toFail: doubleTapRecognizer)

        mapView.addGestureRecognizer(singleTapGestureRecognizer)
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.isPitchEnabled = false
        mapView.showsCompass = false
        mapView.tintColor = UIColor(Color.primaryColorVariant)
        mapView.isAccessibilityElement = true
        mapView.accessibilityLabel = name
        
        context.coordinator.mapView = mapView
    
        mapView.register(EnlargedAnnotationView.self, forAnnotationViewWithReuseIdentifier: EnlargedAnnotationView.ReuseID)

        if let mixins = mixins {
            for mixin in mixins {
                mixin.setupMixin(marlinMap: self, mapView: mapView)
            }
        }
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        context.coordinator.mapView = mapView
        
        let scale = context.coordinator.mapScale ?? mapView.subviews.first { view in
            return (view as? MKScaleView) != nil
        }
        
        if mapState.showMapScale {
            if scale == nil {
                let scale = MKScaleView(mapView: mapView)
                scale.scaleVisibility = .visible // always visible
                scale.isAccessibilityElement = true
                scale.accessibilityLabel = "Map Scale"
                mapView.addSubview(scale)
                context.coordinator.mapScale = scale
            } else if let scale = scale {
                mapView.addSubview(scale)
            }
        } else if let scale = scale {
            scale.removeFromSuperview()
        }

        if let center = mapState.center, center.center.latitude != context.coordinator.setCenter?.latitude, center.center.longitude != context.coordinator.setCenter?.longitude {
            mapView.setRegion(center, animated: true)
            context.coordinator.setCenter = center.center
        }
        
        if let center = mapState.forceCenter, context.coordinator.forceCenterDate != mapState.forceCenterDate {
            mapView.setRegion(center, animated: true)
            context.coordinator.forceCenterDate = mapState.forceCenterDate
        }
        
        if context.coordinator.trackingModeSet != MKUserTrackingMode(rawValue: mapState.userTrackingMode) {
            mapView.userTrackingMode = MKUserTrackingMode(rawValue: mapState.userTrackingMode) ?? .none
            context.coordinator.trackingModeSet = MKUserTrackingMode(rawValue: mapState.userTrackingMode)
        }
                
        if mapState.mapType == ExtraMapTypes.osm.rawValue {
            if context.coordinator.osmOverlay == nil {
                context.coordinator.osmOverlay = MKTileOverlay(urlTemplate: "https://osm.gs.mil/tiles/default/{z}/{x}/{y}.png")
                context.coordinator.osmOverlay?.tileSize = CGSize(width: 512, height: 512)
                context.coordinator.osmOverlay?.canReplaceMapContent = true
            }
            mapView.removeOverlay(context.coordinator.osmOverlay!)
            mapView.insertOverlay(context.coordinator.osmOverlay!, at: 0, level: .aboveRoads)
        } else if let mkmapType = MKMapType(rawValue: UInt(mapState.mapType)) {
            mapView.mapType = mkmapType
            if let osmOverlay = context.coordinator.osmOverlay {
                mapView.removeOverlay(osmOverlay)
            }
        }
        
        if mapState.showGARS {
            if context.coordinator.garsOverlay == nil {
                context.coordinator.garsOverlay = GARSTileOverlay(512, 512)
            }
            mapView.addOverlay(context.coordinator.garsOverlay!, level: .aboveRoads)
        } else {
            if let garsOverlay = context.coordinator.garsOverlay {
                mapView.removeOverlay(garsOverlay)
            }
        }
        
        if mapState.showMGRS {
            if context.coordinator.mgrsOverlay == nil {
                context.coordinator.mgrsOverlay = MGRSTileOverlay(512, 512)
            }
            mapView.addOverlay(context.coordinator.mgrsOverlay!, level: .aboveRoads)
        } else {
            if let mgrsOverlay = context.coordinator.mgrsOverlay {
                mapView.removeOverlay(mgrsOverlay)
            }
        }
        
        if let mixins = mixins {
            for mixin in mixins {
                mixin.updateMixin(mapView: mapView, mapState: mapState)
            }
        }
    }
 
    func makeCoordinator() -> MarlinMapCoordinator {
        return MarlinMapCoordinator(self)
    }

}

class MarlinMapCoordinator: NSObject, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    var osmOverlay: MKTileOverlay?
    var garsOverlay: GARSTileOverlay?
    var mgrsOverlay: MGRSTileOverlay?

    var mapView: MKMapView?
    var mapScale: MKScaleView?
    var marlinMap: MarlinMap
    var focusedAnnotation: EnlargableAnnotation?
    var focusMapOnItemSink: AnyCancellable?

    var setCenter: CLLocationCoordinate2D?
    var trackingModeSet: MKUserTrackingMode?
    
    var forceCenterDate: Date?

    init(_ marlinMap: MarlinMap) {
        self.marlinMap = marlinMap
        super.init()
        
        focusMapOnItemSink =
        NotificationCenter.default.publisher(for: .FocusMapOnItem)
            .compactMap {$0.object as? FocusMapOnItemNotification}
            .sink(receiveValue: { [weak self] in
                self?.focusItem(notification:$0)
            })
    }

    
    func addAnnotation(annotation: MKAnnotation) {
        mapView?.addAnnotation(annotation)
    }
    
    func focusItem(notification: FocusMapOnItemNotification) {
        if let focusedAnnotation = focusedAnnotation {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
                focusedAnnotation.shrinkAnnotation()
            }) { complete in
                self.mapView?.removeAnnotation(focusedAnnotation)
            }
            self.focusedAnnotation = nil
        }
        
        guard let mapItem = notification.item as? MapImage else {
            return
        }
        
        let coordinate = mapItem.coordinate
        let span = mapView?.region.span ?? MKCoordinateSpan(zoomLevel: 17, pixelWidth: Double(mapView?.frame.size.width ?? UIScreen.main.bounds.width))
        let adjustedCenter = CLLocationCoordinate2D(latitude: coordinate.latitude - (span.latitudeDelta / 4.0), longitude: coordinate.longitude)
        mapView?.setCenter(adjustedCenter, animated: true)
        
        let ea = EnlargedAnnotation(mapImage: mapItem)
        ea.markForEnlarging()
        focusedAnnotation = ea
        mapView?.addAnnotation(ea)
    }
    
    @objc func singleTapGensture(tapGestureRecognizer: UITapGestureRecognizer) {
        guard let mapGesture = tapGestureRecognizer as? MapSingleTap, let mapView = mapGesture.mapView else {
            return
        }
        if tapGestureRecognizer.state == .ended {
            self.mapTap(tapPoint: tapGestureRecognizer.location(in: mapView), gesture: tapGestureRecognizer, mapView: mapView)
        }
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
                    mapView.removeAnnotation(annotation)
                }
            }
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
        
        var items: [any DataSource] = []
        if let mixins = marlinMap.mixins {
            for mixin in mixins.reversed() {
                if let matchedItems = mixin.items(at: tapCoord, mapView: mapView) {
                    items.append(contentsOf: matchedItems)
                }
            }
        }

        let notification = MapItemsTappedNotification(annotations: annotationsTapped, items: items, mapView: mapView)
        NotificationCenter.default.post(name: .MapItemsTapped, object: notification)
    }
        
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let renderableOverlay = overlay as? OverlayRenderable {
            return renderableOverlay.renderer
        }
        if let mixins = marlinMap.mixins {
            for mixin in mixins {
                if let renderer = mixin.renderer(overlay: overlay) {
                    return renderer
                }
            }
        }
        return MKTileOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let enlarged = annotation as? EnlargedAnnotation {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: EnlargedAnnotationView.ReuseID, for: enlarged)
            let mapImage = enlarged.mapImage
            let mapImages = mapImage.mapImage(marker: true, zoomLevel: 36, tileBounds3857: nil, context: nil)
            var finalImage: UIImage?
            if mapImages.count > 0 {
                finalImage = mapImages.first
            }
            for mapImage in mapImages.suffix(from: 1) {
                finalImage = UIImage.combineCentered(image1: finalImage, image2: mapImage)
            }
            annotationView.image = finalImage
            var size = CGSize(width: 40, height: 40)
            let max = max(finalImage?.size.height ?? 40, finalImage?.size.width ?? 40)
            size.width = size.width * ((finalImage?.size.width ?? 40) / max)
            size.height = size.height * ((finalImage?.size.height ?? 40) / max)
            annotationView.frame.size = size
            annotationView.canShowCallout = false
            annotationView.isEnabled = false
            annotationView.accessibilityLabel = "Enlarged"
            (annotation as? EnlargableAnnotation)?.annotationView = annotationView
            return annotationView
        }
        if let mixins = marlinMap.mixins {
            for mixin in mixins {
                if let view = mixin.viewForAnnotation(annotation: annotation, mapView: mapView){
                    return view
                }
            }
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if let mixins = marlinMap.mixins {
            for mixin in mixins {
                mixin.regionDidChange(mapView: mapView, animated: animated)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
    }
    
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        DispatchQueue.main.async { [self] in
            marlinMap.mapState.userTrackingMode = mode.rawValue
        }
    }
    
    func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if let mixins = marlinMap.mixins {
            for mixin in mixins {
                mixin.traitCollectionUpdated(previous: previousTraitCollection)
            }
        }
    }

}

class EnlargedAnnotation: NSObject, MKAnnotation, EnlargableAnnotation {
    var enlarged: Bool = false
    
    var shouldEnlarge: Bool = false
    
    var shouldShrink: Bool = false
    
    var clusteringIdentifierWhenShrunk: String? = nil
    
    var clusteringIdentifier: String? = nil
    
    var annotationView: MKAnnotationView?
    
    var color: UIColor {
        return UIColor.clear
    }
    
    var coordinate: CLLocationCoordinate2D
    var mapImage: MapImage
    
    init(mapImage: MapImage) {
        coordinate = mapImage.coordinate
        self.mapImage = mapImage
    }
    
}

class EnlargedAnnotationView: MKAnnotationView {
    static let ReuseID = "enlarged"
    
    /// - Tag: ClusterIdentifier
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
