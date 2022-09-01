//
//  ModuMap.swift
//  Marlin
//
//  Created by Daniel Barela on 6/17/22.
//

import Foundation
import MapKit
import CoreData
import Combine

class ModuMap: NSObject, MapMixin {
    var mapState: MapState?
    var cancellable = Set<AnyCancellable>()
    
    var showAsTiles: Bool = true
    var fetchRequest: NSFetchRequest<Modu>?
    var moduOverlay: FetchRequestTileOverlay<Modu>?
    var minZoom = 0
    
    public init(fetchRequest: NSFetchRequest<Modu>? = nil, showAsTiles: Bool = true) {
        self.fetchRequest = fetchRequest
        self.showAsTiles = showAsTiles
    }
    
    func getFetchRequest(mapState: MapState) -> NSFetchRequest<Modu> {
        if let showModus = mapState.showModus, showModus == true {
            let fetchRequest = self.fetchRequest ?? Modu.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Modu.date, ascending: true)]
            return fetchRequest
        } else {
            let nilFetchRequest = Modu.fetchRequest()
            nilFetchRequest.predicate = NSPredicate(value: false)
            nilFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Modu.date, ascending: true)]
            return nilFetchRequest
        }
    }
    
    func setupMixin(marlinMap: MarlinMap, mapView: MKMapView) {
        mapState = marlinMap.mapState
        mapView.register(ModuAnnotationView.self, forAnnotationViewWithReuseIdentifier: ModuAnnotationView.ReuseID)
        
        NotificationCenter.default.publisher(for: .FocusModu)
            .compactMap {$0.object as? Modu}
            .sink(receiveValue: { [weak self] in
                self?.focusModu(modu: $0)
            })
            .store(in: &cancellable)
        
        UserDefaults.standard
            .publisher(for: \.showOnMapmodu)
            .removeDuplicates()
            .handleEvents(receiveOutput: { show in
                print("Show Modus: \(show)")
            })
            .sink() { [weak self] in
                marlinMap.mapState.showModus = $0
                if let showAsTiles = self?.showAsTiles, showAsTiles {
                    if let moduOverlay = self?.moduOverlay {
                        marlinMap.mapState.overlays.removeAll { overlay in
                            if let overlay = overlay as? FetchRequestTileOverlay<Modu> {
                                return overlay == moduOverlay
                            }
                            return false
                        }
                    }
                    let newFetchRequest = self?.getFetchRequest(mapState: marlinMap.mapState)
                    let newOverlay = FetchRequestTileOverlay<Modu>()
                    
                    newOverlay.tileSize = CGSize(width: 512, height: 512)
                    newOverlay.minimumZ = self?.minZoom ?? 0
                    newOverlay.fetchRequest = newFetchRequest
                    self?.moduOverlay = newOverlay
                    marlinMap.mapState.overlays.append(newOverlay)
                } else {
                    marlinMap.mapState.fetchRequests[Modu.key] = self?.getFetchRequest(mapState: marlinMap.mapState) as? NSFetchRequest<NSFetchRequestResult>
                }
            }
            .store(in: &cancellable)
    }
    
    func items(at location: CLLocationCoordinate2D, mapView: MKMapView) -> [DataSource]? {
        if mapView.zoomLevel < minZoom {
            return nil
        }
        guard let mapState = mapState, let showModus = mapState.showModus, showModus else {
            return nil
        }
        let screenPercentage = 0.03
        let tolerance = mapView.region.span.longitudeDelta * Double(screenPercentage)
        let minLon = location.longitude - tolerance
        let maxLon = location.longitude + tolerance
        let minLat = location.latitude - tolerance
        let maxLat = location.latitude + tolerance
        
        let fetchRequest: NSFetchRequest<Modu>
        fetchRequest = Modu.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(
            format: "latitude >= %lf AND latitude <= %lf AND longitude >= %lf AND longitude <= %lf", minLat, maxLat, minLon, maxLon
        )
        
        let context = PersistenceController.shared.container.viewContext
        return try? context.fetch(fetchRequest)
    }
    
    func focusModu(modu: Modu) {
        mapState?.center = MKCoordinateRegion(center: modu.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
    }
 
    func viewForAnnotation(annotation: MKAnnotation, mapView: MKMapView) -> MKAnnotationView? {
        guard let moduAnnotation = annotation as? Modu else {
            return nil
        }
        
        let annotationView = moduAnnotation.view(on: mapView)
        
        annotationView.canShowCallout = false;
        annotationView.isEnabled = false;
        annotationView.accessibilityLabel = "Modu Annotation \(moduAnnotation.name ?? "")";
        return annotationView;
    }

}
