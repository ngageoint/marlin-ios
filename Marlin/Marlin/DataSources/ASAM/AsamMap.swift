//
//  AsamMap.swift
//  Marlin
//
//  Created by Daniel Barela on 6/14/22.
//

import Foundation
import MapKit
import CoreData
import Combine

class AsamMap: NSObject, MapMixin {
    var minZoom = 0
    var mapState: MapState?
    var cancellable = Set<AnyCancellable>()
    
    var showAsamsAsTiles: Bool = true
    var fetchRequest: NSFetchRequest<Asam>?
    var asamOverlay: FetchRequestTileOverlay<Asam>?
    
    public init(fetchRequest: NSFetchRequest<Asam>? = nil, showAsamsAsTiles: Bool = true) {
        self.fetchRequest = fetchRequest
        self.showAsamsAsTiles = showAsamsAsTiles
    }
    
    func getFetchRequest(mapState: MapState) -> NSFetchRequest<Asam> {
        if let showAsams = mapState.showAsams, showAsams == true {
            let fetchRequest = self.fetchRequest ?? Asam.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Asam.date, ascending: true)]
            return fetchRequest
        } else {
            let nilFetchRequest = Asam.fetchRequest()
            nilFetchRequest.predicate = NSPredicate(value: false)
            nilFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Asam.date, ascending: true)]
            return nilFetchRequest
        }
    }
    
    func setupMixin(marlinMap: MarlinMap, mapView: MKMapView) {
        mapState = marlinMap.mapState
        mapView.register(AsamAnnotationView.self, forAnnotationViewWithReuseIdentifier: AsamAnnotationView.ReuseID)
        
        NotificationCenter.default.publisher(for: .FocusAsam)
            .compactMap {$0.object as? Asam}
            .sink(receiveValue: { [weak self] in
                self?.focusAsam(asam: $0)
            })
            .store(in: &cancellable)
        
        UserDefaults.standard.publisher(for: \.showOnMapasam)
            .removeDuplicates()
            .handleEvents(receiveOutput: { show in
                print("Show Asams: \(show)")
            })
            .sink() { [weak self] in
                marlinMap.mapState.showAsams = $0
                if let showAsamsAsTiles = self?.showAsamsAsTiles, showAsamsAsTiles {
                    if let asamOverlay = self?.asamOverlay {
                        marlinMap.mapState.overlays.removeAll { overlay in
                            if let overlay = overlay as? FetchRequestTileOverlay<Asam> {
                                return overlay == asamOverlay
                            }
                            return false
                        }
                    }
                    let newFetchRequest = self?.getFetchRequest(mapState: marlinMap.mapState)
                    let newOverlay = FetchRequestTileOverlay<Asam>()
                    
                    newOverlay.tileSize = CGSize(width: 512, height: 512)
                    newOverlay.minimumZ = self?.minZoom ?? 0
                    newOverlay.fetchRequest = newFetchRequest
                    self?.asamOverlay = newOverlay
                    marlinMap.mapState.overlays.append(newOverlay)
                } else {
                    marlinMap.mapState.fetchRequests[Asam.key] = self?.getFetchRequest(mapState: marlinMap.mapState) as? NSFetchRequest<NSFetchRequestResult>
                }
            }
            .store(in: &cancellable)
    }
    
    func focusAsam(asam: Asam) {
        mapState?.center = MKCoordinateRegion(center: asam.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
    }
    
    func viewForAnnotation(annotation: MKAnnotation, mapView: MKMapView) -> MKAnnotationView? {
        guard let asamAnnotation = annotation as? Asam else {
            return nil
        }
        
        let annotationView = asamAnnotation.view(on: mapView)
        annotationView.canShowCallout = false;
        annotationView.isEnabled = false;
        annotationView.accessibilityLabel = "Asam Annotation \(asamAnnotation.reference ?? "")";
        return annotationView;
    }
}
