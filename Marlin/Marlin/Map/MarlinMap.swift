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

protocol OverlayRenderable {
    var renderer: MKOverlayRenderer { get }
}

class MapSingleTap: UITapGestureRecognizer {
    var mapView: MKMapView?
}

class MapState: ObservableObject {
    @Published var userTrackingMode: Int = Int(MKUserTrackingMode.none.rawValue)
    @Published var center: MKCoordinateRegion?
    @Published var overlays: [MKOverlay] = []
    
    @Published var asamFetchRequest: NSFetchRequest<Asam>?
    @Published var showAsams: Bool?
    
    @Published var moduFetchRequest: NSFetchRequest<Modu>?
    @Published var showModus: Bool?
    
    @Published var lightFetchRequest: NSFetchRequest<Light>?
    @Published var showLights: Bool?
    @Published var drawLightTiles: Bool?
    
    @Published var portFetchRequest: NSFetchRequest<Port>?
    @Published var showPorts: Bool?
    @Published var drawPortTiles: Bool?
}

struct MarlinMap: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("mapType") var mapType: Int = Int(MKMapType.standard.rawValue)
    
    @ObservedObject var mapState: MapState

    var mixins: [MapMixin]?
    var name: String
    
    init(name: String, mixins: [MapMixin]? = [], mapState: MapState? = nil, annotationToShrink: EnlargableAnnotation? = nil, focusedAnnotation: AnnotationWithView? = nil) {
        self.name = name
        if let mapState = mapState {
            self.mapState = mapState
        } else {
            self.mapState = MapState()
        }
        self.mixins = mixins
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
        mapView.register(ClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.isPitchEnabled = false
        mapView.showsCompass = false
        
        context.coordinator.mapView = mapView

        if let mixins = mixins {
            for mixin in mixins {
                mixin.setupMixin(marlinMap: self, mapView: mapView)
            }
        }

        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        print("Update ui view")
        context.coordinator.mapView = mapView
        addDataToMap(context: context)
        
        if let center = mapState.center, center.center.latitude != context.coordinator.setCenter?.latitude, center.center.longitude != context.coordinator.setCenter?.longitude {
                mapView.setRegion(center, animated: true)
            context.coordinator.setCenter = center.center
        }
        
        if context.coordinator.trackingModeSet != MKUserTrackingMode(rawValue: mapState.userTrackingMode) {
            mapView.userTrackingMode = MKUserTrackingMode(rawValue: mapState.userTrackingMode) ?? .none
            context.coordinator.trackingModeSet = MKUserTrackingMode(rawValue: mapState.userTrackingMode)
        }
                
        if mapType == ExtraMapTypes.osm.rawValue {
            if context.coordinator.osmOverlay == nil {
                context.coordinator.osmOverlay = MKTileOverlay(urlTemplate: "https://osm.gs.mil/tiles/default/{z}/{x}/{y}.png")
                context.coordinator.osmOverlay?.tileSize = CGSize(width: 512, height: 512)
                context.coordinator.osmOverlay?.canReplaceMapContent = true
            }
            mapView.removeOverlay(context.coordinator.osmOverlay!)
            mapView.addOverlay(context.coordinator.osmOverlay!, level: .aboveRoads)
        } else if let mkmapType = MKMapType(rawValue: UInt(mapType)) {
            mapView.mapType = mkmapType
            if let osmOverlay = context.coordinator.osmOverlay {
                mapView.removeOverlay(osmOverlay)
            }
        }
        
        let overlaysToRemove = mapView.overlays.filter { overlay in
            if let overlay = overlay as? MKTileOverlay {
                return !mapState.overlays.contains(where: { stateOverlay in
                    if let stateOverlay = stateOverlay as? MKTileOverlay {
                        return overlay == stateOverlay
                    }
                    return false
                })
            }
            return false
        }

        let overlaysToAdd = mapState.overlays.filter { overlay in
            if let overlay = overlay as? MKTileOverlay {
                return !mapView.overlays.contains(where: { mapOverlay in
                    if let mapOverlay = mapOverlay as? MKTileOverlay {
                        return overlay == mapOverlay
                    }
                    return false
                })
            }
            return false
        }

        mapView.removeOverlays(overlaysToRemove)
        mapView.addOverlays(overlaysToAdd)
    }
    
    func addDataToMap(context: Context) {
        if let showAsams = mapState.showAsams, showAsams == true {
            context.coordinator.updateAsamFetchRequest(mapState.asamFetchRequest)
        } else {
            let nilFetchRequest = Asam.fetchRequest()
            nilFetchRequest.predicate = NSPredicate(value: false)
            nilFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Asam.date, ascending: true)]
            
            context.coordinator.updateAsamFetchRequest(nilFetchRequest)
        }
        
        if let showModus = mapState.showModus, showModus == true {
            context.coordinator.updateModuFetchRequest(mapState.moduFetchRequest)
        } else {
            let nilFetchRequest = Modu.fetchRequest()
            nilFetchRequest.predicate = NSPredicate(value: false)
            nilFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Modu.date, ascending: true)]
            
            context.coordinator.updateModuFetchRequest(nilFetchRequest)
        }
        
        context.coordinator.updateLightFetchRequest(mapState.lightFetchRequest)
    }
    
    func MKMapRectForCoordinateRegion(region:MKCoordinateRegion) -> MKMapRect {
        let topLeft = CLLocationCoordinate2D(latitude: region.center.latitude + (region.span.latitudeDelta/2), longitude: region.center.longitude - (region.span.longitudeDelta/2))
        let bottomRight = CLLocationCoordinate2D(latitude: region.center.latitude - (region.span.latitudeDelta/2), longitude: region.center.longitude + (region.span.longitudeDelta/2))
        
        let a = MKMapPoint(topLeft)
        let b = MKMapPoint(bottomRight)
        
        return MKMapRect(origin: MKMapPoint(x:min(a.x,b.x), y:min(a.y,b.y)), size: MKMapSize(width: abs(a.x-b.x), height: abs(a.y-b.y)))
    }
    
    func makeCoordinator() -> MarlinMapCoordinator {
        return MarlinMapCoordinator(self)
    }

}

class MarlinMapCoordinator: NSObject, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    var osmOverlay: MKTileOverlay?

    var mapView: MKMapView?
    var marlinMap: MarlinMap
    var focusedAnnotation: AnnotationWithView?
    var mapAnnotationFocusedSink: AnyCancellable?
    
    var asamFetchedResultsController: NSFetchedResultsController<Asam>?
    var moduFetchedResultsController: NSFetchedResultsController<Modu>?
    var lightFetchedResultsController: NSFetchedResultsController<Light>?
    var portFetchedResultsController: NSFetchedResultsController<Port>?
    
    var setCenter: CLLocationCoordinate2D?
    var trackingModeSet: MKUserTrackingMode?

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
    
    func updatePortFetchRequest(_ fetchRequest: NSFetchRequest<Port>?) {
        guard let fetchRequest = fetchRequest else {
            return
        }
        
        if portFetchedResultsController == nil {
            portFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: PersistenceController.shared.container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        } else {
            // is predicate different?
            if portFetchedResultsController?.fetchRequest.predicate != fetchRequest.predicate {
                mapView?.removeAnnotations(portFetchedResultsController?.fetchedObjects ?? [])
            }
            portFetchedResultsController?.fetchRequest.predicate = fetchRequest.predicate
        }
        
        initiateFetchResultsController(fetchedResultsController: portFetchedResultsController as? NSFetchedResultsController<NSManagedObject>)
    }
    
    func updateLightFetchRequest(_ fetchRequest: NSFetchRequest<Light>?) {
        guard let fetchRequest = fetchRequest else {
            return
        }

        if lightFetchedResultsController == nil {
            lightFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: PersistenceController.shared.container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        } else {
            // is predicate different?
            if lightFetchedResultsController?.fetchRequest.predicate != fetchRequest.predicate {
                mapView?.removeAnnotations(lightFetchedResultsController?.fetchedObjects ?? [])
            }
            lightFetchedResultsController?.fetchRequest.predicate = fetchRequest.predicate
        }
        
        initiateFetchResultsController(fetchedResultsController: lightFetchedResultsController as? NSFetchedResultsController<NSManagedObject>)
    }
    
    func updateModuFetchRequest(_ fetchRequest: NSFetchRequest<Modu>?) {
        guard let fetchRequest = fetchRequest else {
            return
        }
        
        if moduFetchedResultsController == nil {
            moduFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: PersistenceController.shared.container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        } else {
            // is predicate different?
            if moduFetchedResultsController?.fetchRequest.predicate != fetchRequest.predicate {
                mapView?.removeAnnotations(moduFetchedResultsController?.fetchedObjects ?? [])
            }
            moduFetchedResultsController?.fetchRequest.predicate = fetchRequest.predicate
        }
        
        initiateFetchResultsController(fetchedResultsController: moduFetchedResultsController as? NSFetchedResultsController<NSManagedObject>)
    }
    
    func updateAsamFetchRequest(_ fetchRequest: NSFetchRequest<Asam>?) {
        guard let fetchRequest = fetchRequest else {
            return
        }

        if asamFetchedResultsController == nil {
            asamFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: PersistenceController.shared.container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        } else {
            // is predicate different?
            if asamFetchedResultsController?.fetchRequest.predicate != fetchRequest.predicate {
                mapView?.removeAnnotations(asamFetchedResultsController?.fetchedObjects ?? [])
            }
            asamFetchedResultsController?.fetchRequest.predicate = fetchRequest.predicate
        }
        
        initiateFetchResultsController(fetchedResultsController: asamFetchedResultsController as? NSFetchedResultsController<NSManagedObject>)
    }
    
    func initiateFetchResultsController(fetchedResultsController: NSFetchedResultsController<NSManagedObject>?) {
        fetchedResultsController?.delegate = self
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        if let annotations = fetchedResultsController?.fetchedObjects as? [MKAnnotation] {
            mapView?.addAnnotations(annotations)
        }
    }
    
    func addAnnotation(annotation: MKAnnotation) {
        mapView?.addAnnotation(annotation)
    }
    
    func updateAnnotation(annotation: MKAnnotation) {
        mapView?.removeAnnotation(annotation)
        mapView?.addAnnotation(annotation)
    }
    
    func deleteAnnotation(annotation: MKAnnotation) {
        var mapAnnotation: MKAnnotation?
        if let asam = annotation as? Asam {
            mapAnnotation = mapView?.annotations.first(where: { mapAnnotation in
                if let mapAnnotation = mapAnnotation as? Asam {
                    return mapAnnotation.reference == asam.reference
                }
                return false
            })
        }
        if let modu = annotation as? Modu {
            mapAnnotation = mapView?.annotations.first(where: { mapAnnotation in
                if let mapAnnotation = mapAnnotation as? Modu {
                    return mapAnnotation.name == modu.name
                }
                return false
            })
        }
        if let light = annotation as? Light {
            mapAnnotation = mapView?.annotations.first(where: { mapAnnotation in
                if let mapAnnotation = mapAnnotation as? Light {
                    return mapAnnotation.featureNumber == light.featureNumber && mapAnnotation.volumeNumber == light.volumeNumber && mapAnnotation.characteristicNumber == light.characteristicNumber
                }
                return false
            })
        }
        
        if let mapAnnotation = mapAnnotation {
            mapView?.removeAnnotation(mapAnnotation)
            mapView?.removeAnnotation(mapAnnotation)
        }
    }
    
    func focusAnnotation(notification: MapAnnotationFocusedNotification) {
        guard let annotation = notification.annotation as? AnnotationWithView, annotation.annotationView != nil else {
            if let focusedAnnotation = focusedAnnotation {
                self.focusedAnnotation = nil
                if let enlargedAnnotation = focusedAnnotation as? EnlargableAnnotation {
                    // shrink the old focused view
                    mapView?.removeAnnotation(enlargedAnnotation)
                    enlargedAnnotation.markForShrinking()
                    mapView?.addAnnotation(enlargedAnnotation)
                }
            }
            return
        }
        
        if annotation.annotationView == focusedAnnotation?.annotationView {
            // already focused, ignore
            return
        } else if let focusedAnnotation = focusedAnnotation, let enlargedAnnotation = focusedAnnotation as? EnlargableAnnotation  {
            // shrink the old focused view
            mapView?.removeAnnotation(enlargedAnnotation)
            enlargedAnnotation.markForShrinking()
            mapView?.addAnnotation(enlargedAnnotation)
        }
        
        if ((annotation as? MKClusterAnnotation) != nil) {
            return
        }
        
        self.focusedAnnotation = annotation
        mapView?.removeAnnotation(annotation)
        annotation.clusteringIdentifier = nil
        (annotation as? EnlargableAnnotation)?.markForEnlarging()
        mapView?.addAnnotation(annotation)

        let coordinate = annotation.coordinate
        let span = mapView?.region.span ?? MKCoordinateSpan(latitudeDelta: 1000, longitudeDelta: 1000)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        let rect = MKMapRectForCoordinateRegion(region: region)
        // Adjust padding here
        let insets = UIEdgeInsets(top: -140, left: 0, bottom: 150, right: 0)
        mapView?.setVisibleMapRect(rect, edgePadding: insets, animated: true)
    }
    
    func MKMapRectForCoordinateRegion(region:MKCoordinateRegion) -> MKMapRect {
        let topLeft = CLLocationCoordinate2D(latitude: region.center.latitude + (region.span.latitudeDelta/2), longitude: region.center.longitude - (region.span.longitudeDelta/2))
        let bottomRight = CLLocationCoordinate2D(latitude: region.center.latitude - (region.span.latitudeDelta/2), longitude: region.center.longitude + (region.span.longitudeDelta/2))
        
        let a = MKMapPoint(topLeft)
        let b = MKMapPoint(bottomRight)
        
        return MKMapRect(origin: MKMapPoint(x:min(a.x,b.x), y:min(a.y,b.y)), size: MKMapSize(width: abs(a.x-b.x), height: abs(a.y-b.y)))
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
        
        var items: [DataSource] = []
        if let mixins = marlinMap.mixins {
            for mixin in mixins {
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
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
    }
    
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        marlinMap.mapState.userTrackingMode = mode.rawValue
    }
    
    func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if let mixins = marlinMap.mixins {
            for mixin in mixins {
                mixin.traitCollectionUpdated(previous: previousTraitCollection)
            }
        }
    }

}

extension MarlinMapCoordinator: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let annotation = anObject as? MKAnnotation else {
            return
        }
        switch(type) {
            
        case .insert:
            self.addAnnotation(annotation: annotation)
        case .delete:
            self.deleteAnnotation(annotation: annotation)
        case .move:
            self.updateAnnotation(annotation: annotation)
        case .update:
            self.updateAnnotation(annotation: annotation)
        @unknown default:
            break
        }
    }
}
