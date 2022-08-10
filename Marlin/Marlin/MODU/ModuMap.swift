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
    var mapView: MKMapView?
    var cancellable = Set<AnyCancellable>()

    var fetchedResultsController: NSFetchedResultsController<Modu>?
    
    func setupMixin(mapView: MKMapView, marlinMap: MarlinMap) {
        self.mapView = mapView
        mapView.register(ModuAnnotationView.self, forAnnotationViewWithReuseIdentifier: ModuAnnotationView.ReuseID)
        
        NotificationCenter.default.publisher(for: .FocusModu)
            .compactMap {$0.object as? Modu}
            .sink(receiveValue: { [weak self] in
                self?.focusModu(modu: $0)
            })
            .store(in: &cancellable)

        let fetchRequest = Modu.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Modu.date, ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: PersistenceController.shared.container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        
        UserDefaults.standard
            .publisher(for: \.showOnMapmodu)
            .removeDuplicates()
            .handleEvents(receiveOutput: { show in
                print("Show Modus: \(show)")
            })
            .sink() { [weak self] in
                self?.toggleModus(showModus: $0)
            }
            .store(in: &cancellable)
    }
    
    func toggleModus(showModus: Bool) {
        if let modus = fetchedResultsController?.fetchedObjects {
            if showModus {
                mapView?.addAnnotations(modus)
            } else {
                mapView?.removeAnnotations(modus)
            }
        }
    }
    
    func focusModu(modu: Modu) {
        mapView?.setRegion(MKCoordinateRegion(center: modu.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000), animated: true)
    }
    
    func addInitialModus(modus: [Modu]?) {
        guard let modus = modus else {
            return
        }
        mapView?.addAnnotations(modus)
    }
    
    func addModu(modu: Modu) {
        mapView?.addAnnotation(modu)
    }
    
    func updateModu(modu: Modu) {
        mapView?.removeAnnotation(modu)
        mapView?.addAnnotation(modu)
    }
    
    func deleteModu(modu: Modu) {
        let annotation = mapView?.annotations.first(where: { annotation in
            if let annotation = annotation as? Modu {
                return annotation.name == modu.name
            }
            return false
        })
        
        if let annotation = annotation {
            mapView?.removeAnnotation(annotation)
        }
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

extension ModuMap : NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let modu = anObject as? Modu else {
            return
        }
        switch(type) {
            
        case .insert:
            self.addModu(modu: modu)
        case .delete:
            self.deleteModu(modu: modu)
        case .move:
            self.updateModu(modu: modu)
        case .update:
            self.updateModu(modu: modu)
        @unknown default:
            break
        }
    }
}
