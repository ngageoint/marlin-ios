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

protocol ModuMap {
    var mapView: MKMapView? { get set }
    var moduMapMixin: ModuMapMixin? { get set }
    func addFilteredModus()
}

extension ModuMap {
    func addFilteredUsers() {
        moduMapMixin?.addFilteredModus()
    }
}

class ModuMapMixin: NSObject, MapMixin {
    var mapAnnotationFocusedObserver: AnyObject?
    var moduMap: ModuMap?
    var mapView: MKMapView?
    var scheme: MarlinScheme?
    
    var enlargedLocationView: MKAnnotationView?
    var selectedUserAccuracy: MKOverlay?
    
    var fetchedResultsController: NSFetchedResultsController<Modu>?
    
    //    var locations: Locations?
    //    var user: User?
    
    init(moduMap: ModuMap, scheme: MarlinScheme?) {
        self.moduMap = moduMap
        self.mapView = moduMap.mapView
        //        self.user = user
        self.scheme = scheme
        moduMap.mapView?.register(ModuAnnotationView.self, forAnnotationViewWithReuseIdentifier: ModuAnnotationView.ReuseID)
    }
    
    func cleanupMixin() {
        if let mapAnnotationFocusedObserver = mapAnnotationFocusedObserver {
            NotificationCenter.default.removeObserver(mapAnnotationFocusedObserver)
        }
        mapAnnotationFocusedObserver = nil
        
        //        UserDefaults.standard.removeObserver(self, forKeyPath: #keyPath(UserDefaults.locationTimeFilter))
        //        UserDefaults.standard.removeObserver(self, forKeyPath: #keyPath(UserDefaults.locationTimeFilterUnit))
        //        UserDefaults.standard.removeObserver(self, forKeyPath: #keyPath(UserDefaults.locationTimeFilterNumber))
        //        UserDefaults.standard.removeObserver(self, forKeyPath: #keyPath(UserDefaults.hidePeople))
        //
        //        locations?.fetchedResultsController.delegate = nil
        //        locations = nil
    }
    
    func setupMixin() {
        //        UserDefaults.standard.addObserver(self, forKeyPath: #keyPath(UserDefaults.locationTimeFilter), options: [.new], context: nil)
        //        UserDefaults.standard.addObserver(self, forKeyPath: #keyPath(UserDefaults.locationTimeFilterUnit), options: [.new], context: nil)
        //        UserDefaults.standard.addObserver(self, forKeyPath: #keyPath(UserDefaults.locationTimeFilterNumber), options: [.new], context: nil)
        //        UserDefaults.standard.addObserver(self, forKeyPath: #keyPath(UserDefaults.hidePeople), options: [.new], context: nil)
        
        //        mapAnnotationFocusedObserver = NotificationCenter.default.addObserver(forName: .MapAnnotationFocused, object: nil, queue: .main) { [weak self] notification in
        //            if let notificationObject = (notification.object as? MapAnnotationFocusedNotification), notificationObject.mapView == self?.mapView {
        //                self?.focusAnnotation(annotation: notificationObject.annotation)
        //            } else if notification.object == nil {
        //                self?.focusAnnotation(annotation: nil)
        //            }
        //        }
        let fetchRequest = Modu.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: PersistenceController.shared.container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        addFilteredModus()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        addFilteredModus()
        //        NotificationCenter.default.post(name: .LocationFiltersChanged, object: nil)
    }
    
    func addFilteredModus() {
        //        mapView?.addAnnotation(MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 40, longitude: -104)))
        //        if let locations = locations, let fetchedLocations = locations.fetchedResultsController.fetchedObjects as? [Location] {
        //            for location in fetchedLocations {
        //                deleteLocation(location: location)
        //            }
        //        }
        //
        //        if let user = user {
        //            locations = Locations(for: user)
        //            locations?.delegate = self
        //        } else if let locations = locations,
        //                  let locationPredicates = Locations.getPredicatesForLocationsForMap() as? [NSPredicate] {
        //            locations.fetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: locationPredicates)
        //        } else {
        //            locations = Locations.forMap()
        //            locations?.delegate = self
        //        }
        //
        //        if let locations = locations {
        //            do {
        //                try locations.fetchedResultsController.performFetch()
        //                updateLocations(locations: locations.fetchedResultsController?.fetchedObjects as? [Location])
        //            } catch {
        //                NSLog("Failed to perform fetch in the MapDelegate for locations \(error), \((error as NSError).userInfo)")
        //            }
        //        }
        updateModus(modus: fetchedResultsController?.fetchedObjects)
    }
    
    func updateModus(modus: [Modu]?) {
        guard let modus = modus else {
            return
        }
        
        for modu in modus {
            DispatchQueue.main.async { [weak self] in
                self?.updateModu(modu: modu)
            }
        }
    }
    
    func updateModu(modu: Modu) {
        
        //        guard let latitude = modu.latitude, let longitude = modu.longitude else {
        //            return
        //        }
        
        let annotation = ModuAnnotation(modu: modu)
        mapView?.addAnnotation(annotation)
        //        guard let coordinate = location.location?.coordinate else {
        //            return
        //        }
        //
        //        if let annotation: LocationAnnotation = mapView?.annotations.first(where: { annotation in
        //            if let annotation = annotation as? LocationAnnotation {
        //                return annotation.user?.remoteId == location.user?.remoteId
        //            }
        //            return false
        //        }) as? LocationAnnotation {
        //            annotation.coordinate = coordinate
        //        } else {
        //            if let annotation = LocationAnnotation(location: location) {
        //                mapView?.addAnnotation(annotation)
        //            }
        //        }
    }
    //
    //    func deleteLocation(location: Location) {
    //        let annotation = mapView?.annotations.first(where: { annotation in
    //            if let annotation = annotation as? LocationAnnotation {
    //                return annotation.user.remoteId == location.user?.remoteId
    //            }
    //            return false
    //        })
    //
    //        if let annotation = annotation {
    //            mapView?.removeAnnotation(annotation)
    //        }
    //    }
    
    func viewForAnnotation(annotation: MKAnnotation, mapView: MKMapView) -> MKAnnotationView? {
        guard let moduAnnotation = annotation as? ModuAnnotation else {
            return nil
        }
        
        let annotationView = moduAnnotation.view(on: mapView)
        
        // adjust the center offset if this is the enlargedPin
        if (annotationView == self.enlargedLocationView) {
            annotationView.transform = annotationView.transform.scaledBy(x: 2.0, y: 2.0)
            if let image = annotationView.image {
                annotationView.centerOffset = CGPoint(x: 0, y: -(image.size.height))
            } else {
                annotationView.centerOffset = CGPoint(x: 0, y: annotationView.centerOffset.y * 2.0)
            }
        }
        annotationView.canShowCallout = false;
        annotationView.isEnabled = false;
        //        annotationView.accessibilityLabel = "Location Annotation \(locationAnnotation.user?.objectID.uriRepresentation().absoluteString ?? "")";
        return annotationView;
    }
    
    func focusAnnotation(annotation: MKAnnotation?) {
        //        guard let annotation = annotation as? LocationAnnotation,
        //              let _ = annotation.user,
        //              let annotationView = annotation.view else {
        //            if let selectedUserAccuracy = selectedUserAccuracy {
        //                mapView?.removeOverlay(selectedUserAccuracy)
        //                self.selectedUserAccuracy = nil
        //            }
        //            if let enlargedLocationView = enlargedLocationView {
        //                // shrink the old focused view
        //                UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut) {
        //                    enlargedLocationView.transform = enlargedLocationView.transform.scaledBy(x: 0.5, y: 0.5)
        //                    if let image = enlargedLocationView.image {
        //                        enlargedLocationView.centerOffset = CGPoint(x: 0, y: -(image.size.height / 2.0))
        //                    } else {
        //                        enlargedLocationView.centerOffset = CGPoint(x: 0, y: enlargedLocationView.centerOffset.y / 2.0)
        //                    }
        //                } completion: { success in
        //                }
        //                self.enlargedLocationView = nil
        //            }
        //            return
        //        }
        //
        //        if annotationView == enlargedLocationView {
        //            // already focused ignore
        //            return
        //        } else if let enlargedLocationView = enlargedLocationView {
        //            // shrink the old focused view
        //            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut) {
        //                enlargedLocationView.transform = enlargedLocationView.transform.scaledBy(x: 0.5, y: 0.5)
        //                if let image = annotationView.image {
        //                    enlargedLocationView.centerOffset = CGPoint(x: 0, y: -(image.size.height / 2.0))
        //                } else {
        //                    enlargedLocationView.centerOffset = CGPoint(x: 0, y: annotationView.centerOffset.y / 2.0)
        //                }
        //            } completion: { success in
        //            }
        //        }
        //
        //        if let selectedUserAccuracy = selectedUserAccuracy {
        //            mapView?.removeOverlay(selectedUserAccuracy)
        //        }
        //
        //        enlargedLocationView = annotationView
        //        let accuracy = annotation.location.horizontalAccuracy
        //        let coordinate = annotation.location.coordinate
        //        selectedUserAccuracy = LocationAccuracy(center: coordinate, radius: accuracy)
        //        mapView?.addOverlay(selectedUserAccuracy!)
        //
        //        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut) {
        //            annotationView.transform = annotationView.transform.scaledBy(x: 2.0, y: 2.0)
        //            if let image = annotationView.image {
        //                annotationView.centerOffset = CGPoint(x: 0, y: -(image.size.height))
        //            } else {
        //                annotationView.centerOffset = CGPoint(x: 0, y: annotationView.centerOffset.y * 2.0)
        //            }
        //        } completion: { success in
        //        }
    }
    
    func renderer(overlay: MKOverlay) -> MKOverlayRenderer? {
        //        if let overlay = overlay as? LocationAccuracy {
        //            return LocationAccuracyRenderer(overlay: overlay)
        //        }
        //        return nil
        return nil
    }
}

extension ModuMapMixin : NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let modu = anObject as? Modu else {
            return
        }
        switch(type) {
            
        case .insert:
            if let latitude = modu.latitude, let longitude = modu.longitude {
                mapView?.addAnnotation(MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude: longitude.doubleValue)))
            }
            //            self.updateLocation(location: location)
        case .delete:
            print("delete")
            //            self.deleteLocation(location: location)
        case .move:
            print("move")
            //            self.updateLocation(location: location)
        case .update:
            print("update")
            //            self.updateLocation(location: location)
        @unknown default:
            break
        }
    }
}
