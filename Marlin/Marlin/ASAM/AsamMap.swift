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
    
    var fetchedResultsController: NSFetchedResultsController<Asam>?
    
    func cleanupMixin() {
    }
    
    func setupMixin(mapView: MKMapView, marlinMap: MarlinMap, scheme: MarlinScheme? = nil) {
        self.mapView = mapView
        mapView.register(AsamAnnotationView.self, forAnnotationViewWithReuseIdentifier: AsamAnnotationView.ReuseID)
        
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

        addInitialAsams(asams: fetchedResultsController?.fetchedObjects)
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
