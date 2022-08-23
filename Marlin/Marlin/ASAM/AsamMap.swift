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
    var mapState: MapState?
    var cancellable = Set<AnyCancellable>()
    
    func cleanupMixin() {
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
        
        let fetchRequest = Asam.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Asam.date, ascending: true)]
        
        marlinMap.mapState.asamFetchRequest = fetchRequest

        UserDefaults.standard.publisher(for: \.showOnMapasam)
            .removeDuplicates()
            .handleEvents(receiveOutput: { show in
                print("Show Asams: \(show)")
            })
            .sink() {
                marlinMap.mapState.showAsams = $0
            }
            .store(in: &cancellable)
    }
    
    func focusAsam(asam: Asam) {
        mapState?.center = MKCoordinateRegion(center: asam.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
    }
    
    func updateMixin(mapView: MKMapView, marlinMap: MarlinMap) {
//        mapState = marlinMap.mapState
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
