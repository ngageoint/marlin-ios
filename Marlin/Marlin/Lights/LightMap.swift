//
//  LightMap.swift
//  Marlin
//
//  Created by Daniel Barela on 7/11/22.
//

import Foundation
import MapKit
import CoreData
import Combine

class LightMap: NSObject, MapMixin {
    var mapView: MKMapView?
    var cancellable = Set<AnyCancellable>()
    
    var light: Lights?
    var showLightsAsTiles: Bool = true
    var fetchedResultsController: NSFetchedResultsController<Lights>?
    var lightOverlay: LightTileOverlay?
    
    public init(light: Lights? = nil, showLightsAsTiles: Bool = true) {
        self.light = light
        self.showLightsAsTiles = showLightsAsTiles
    }
    
    func setupMixin(mapView: MKMapView, marlinMap: MarlinMap, scheme: MarlinScheme?) {
        self.mapView = mapView
        mapView.register(LightAnnotationView.self, forAnnotationViewWithReuseIdentifier: LightAnnotationView.ReuseID)
        
        NotificationCenter.default.publisher(for: .FocusLight)
            .compactMap {$0.object as? Lights}
            .sink(receiveValue: { [weak self] in
                self?.focusLight(light: $0)
            })
            .store(in: &cancellable)
        
        if let light = light {
            mapView.setRegion(MKCoordinateRegion(center: light.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)), animated: true)
        }
        if let light = light {
            mapView.addAnnotation(light)
        } else {
            UserDefaults.standard
                .publisher(for: \.showOnMapLights)
                .removeDuplicates()
                .handleEvents(receiveOutput: { show in
                    print("Show Lights: \(show)")
                })
                .sink() { [weak self] in
                    self?.toggleLights(showLights: $0)
                }
                .store(in: &cancellable)
        }
    }
    
    func viewForAnnotation(annotation: MKAnnotation, mapView: MKMapView) -> MKAnnotationView? {
        guard let lightAnnotation = annotation as? Lights else {
            return nil
        }
        
        let annotationView = lightAnnotation.view(on: mapView)
        annotationView.canShowCallout = false;
        annotationView.isEnabled = false;
        annotationView.accessibilityLabel = "Light Annotation \(lightAnnotation.featureNumber ?? "")";
        return annotationView;
    }
    
    func items(at location: CLLocationCoordinate2D) -> [Any]? {
        let screenPercentage = 0.03
        let tolerance = (self.mapView?.region.span.longitudeDelta ?? 0.0) * Double(screenPercentage)
        let minLon = location.longitude - tolerance
        let maxLon = location.longitude + tolerance
        let minLat = location.latitude - tolerance
        let maxLat = location.latitude + tolerance
        
        let fetchRequest: NSFetchRequest<Lights>
        fetchRequest = Lights.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(
            format: "latitude >= %lf AND latitude <= %lf AND longitude >= %lf AND longitude <= %lf", minLat, maxLat, minLon, maxLon
        )
        
        let context = PersistenceController.shared.container.viewContext
        return try? context.fetch(fetchRequest)
    }
    
    func toggleLights(showLights: Bool) {
        if showLightsAsTiles {
            if showLights {
                let lightOverlay = LightTileOverlay()
                lightOverlay.minimumZ = 6
                mapView?.addOverlay(lightOverlay)
                self.lightOverlay = lightOverlay
            } else {
                if let lightOverlay = lightOverlay {
                    mapView?.removeOverlay(lightOverlay)
                }
            }
        } else {
            if fetchedResultsController == nil {
                let fetchRequest = Lights.fetchRequest()
                fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Lights.featureNumber, ascending: true)]
                
                fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: PersistenceController.shared.container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
                fetchedResultsController?.delegate = self
                do {
                    try fetchedResultsController?.performFetch()
                } catch {
                    let fetchError = error as NSError
                    print("Unable to Perform Fetch Request")
                    print("\(fetchError), \(fetchError.localizedDescription)")
                }
            }
            if let lights = fetchedResultsController?.fetchedObjects {
                if showLights {
                    mapView?.addAnnotations(lights)
                } else {
                    mapView?.removeAnnotations(lights)
                }
            }
        }
    }
    
    func focusLight(light: Lights) {
        mapView?.setRegion(MKCoordinateRegion(center: light.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000), animated: true)
    }
    
    func addInitialLights(lights: [Lights]?) {
        guard let lights = lights else {
            return
        }
        mapView?.addAnnotations(lights)
    }
    
    func addLight(light: Lights) {
        mapView?.addAnnotation(light)
    }
    
    func updateLight(light: Lights) {
        mapView?.removeAnnotation(light)
        mapView?.addAnnotation(light)
    }
    
    func deleteLight(light: Lights) {
        let annotation = mapView?.annotations.first(where: { annotation in
            if let annotation = annotation as? Lights {
                return annotation.featureNumber == light.featureNumber && annotation.volumeNumber == light.volumeNumber
            }
            return false
        })
        
        if let annotation = annotation {
            mapView?.removeAnnotation(annotation)
        }
    }
}

extension LightMap : NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let light = anObject as? Lights else {
            return
        }
        switch(type) {
            
        case .insert:
            self.addLight(light: light)
        case .delete:
            self.deleteLight(light: light)
        case .move:
            self.updateLight(light: light)
        case .update:
            self.updateLight(light: light)
        @unknown default:
            break
        }
    }
}

class LightAnnotationView: MKAnnotationView {
    static let ReuseID = "light"
    
    /// - Tag: ClusterIdentifier
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
//        clusteringIdentifier = "msi"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var combinedImage: UIImage? {
        didSet {
            updateImage()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            updateImage()
        }
    }
    
    private func updateImage() {
        image = combinedImage?.imageAsset?.image(with: traitCollection) ?? combinedImage
    }

    
//    override var annotation: MKAnnotation? {
//        willSet {
//            clusteringIdentifier = "msi"
//        }
//    }
}
