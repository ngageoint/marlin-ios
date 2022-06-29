//
//  ModuMap.swift
//  Marlin
//
//  Created by Daniel Barela on 6/17/22.
//

import Foundation
import MapKit
import MaterialComponents
import CoreData

class ModuMap: NSObject, MapMixin {
    var mapView: MKMapView?
    
    var fetchedResultsController: NSFetchedResultsController<Modu>?
    
    func setupMixin(mapView: MKMapView, marlinMap: MarlinMap, scheme: MarlinScheme? = nil) {
        self.mapView = mapView
        mapView.register(ModuAnnotationView.self, forAnnotationViewWithReuseIdentifier: ModuAnnotationView.ReuseID)

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
        addInitialModus(modus: fetchedResultsController?.fetchedObjects)
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
