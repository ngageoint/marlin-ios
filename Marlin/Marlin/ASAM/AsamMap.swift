//
//  AsamMap.swift
//  Marlin
//
//  Created by Daniel Barela on 6/14/22.
//

import Foundation
import MapKit
import MaterialComponents
import CoreData
import Combine

class AsamMap: NSObject, MapMixin {
    var mapView: MKMapView?
    var cancellable = Set<AnyCancellable>()

    var fetchedResultsController: NSFetchedResultsController<Asam>?
    
    func cleanupMixin() {
    }
    
    func setupMixin(mapView: MKMapView, marlinMap: MarlinMap, scheme: MarlinScheme? = nil) {
        self.mapView = mapView
        mapView.register(AsamAnnotationView.self, forAnnotationViewWithReuseIdentifier: AsamAnnotationView.ReuseID)
        
        NotificationCenter.default.publisher(for: .FocusAsam)
            .compactMap {$0.object as? Asam}
            .sink(receiveValue: { [weak self] in
                self?.focusAsam(asam: $0)
            })
            .store(in: &cancellable)
        
        let fetchRequest = Asam.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Asam.date, ascending: true)]

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
            .publisher(for: \.showOnMapAsam)
            .removeDuplicates()
            .handleEvents(receiveOutput: { show in
                print("Show Asams: \(show)")
            })
            .sink() { [weak self] in
                self?.toggleAsams(showAsams: $0)
            }
            .store(in: &cancellable)
    }
    
    func toggleAsams(showAsams: Bool) {
        if let asams = fetchedResultsController?.fetchedObjects {
            if showAsams {
                mapView?.addAnnotations(asams)
            } else {
                mapView?.removeAnnotations(asams)
            }
        }
    }
    
    func focusAsam(asam: Asam) {
        mapView?.setRegion(MKCoordinateRegion(center: asam.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000), animated: true)
    }
    
    func addInitialAsams(asams: [Asam]?) {
        guard let asams = asams else {
            return
        }
        mapView?.addAnnotations(asams)
    }
    
    func addAsam(asam: Asam) {
        mapView?.addAnnotation(asam)
    }

    func updateAsam(asam: Asam) {
        mapView?.removeAnnotation(asam)
        mapView?.addAnnotation(asam)
    }

    func deleteAsam(asam: Asam) {
        let annotation = mapView?.annotations.first(where: { annotation in
            if let annotation = annotation as? Asam {
                return annotation.reference == asam.reference
            }
            return false
        })

        if let annotation = annotation {
            mapView?.removeAnnotation(annotation)
        }
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

extension AsamMap : NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let asam = anObject as? Asam else {
            return
        }
        switch(type) {

        case .insert:
            self.addAsam(asam: asam)
        case .delete:
            self.deleteAsam(asam: asam)
        case .move:
            self.updateAsam(asam: asam)
        case .update:
            self.updateAsam(asam: asam)
        @unknown default:
            break
        }
    }
}
