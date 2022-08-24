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
    
    func getFetchRequest(mapState: MapState) -> NSFetchRequest<NSFetchRequestResult> {
        if let showModus = mapState.showModus, showModus == true {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Modu.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Modu.date, ascending: true)]
            return fetchRequest
        } else {
            let nilFetchRequest: NSFetchRequest<NSFetchRequestResult> = Modu.fetchRequest()
            nilFetchRequest.predicate = NSPredicate(value: false)
            nilFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Modu.date, ascending: true)]
            return nilFetchRequest
        }
    }
    
    
    func setupMixin(marlinMap: MarlinMap, mapView: MKMapView) {
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
                marlinMap.mapState.fetchRequests[Modu.key] = self?.getFetchRequest(mapState: marlinMap.mapState)
            }
            .store(in: &cancellable)
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
