//
//  FetchRequestMap.swift
//  Marlin
//
//  Created by Daniel Barela on 9/1/22.
//

import Foundation
import MapKit
import CoreData
import Combine

class FetchRequestMap<T: NSManagedObject & MapImage & DataSource>: NSObject, MapMixin {
    var minZoom = 4
    var mapState: MapState?
    var cancellable = Set<AnyCancellable>()
    
    var showAsTiles: Bool = true
    var fetchRequest: NSFetchRequest<T>?
    var tilePredicate: NSPredicate?
    var overlay: FetchRequestTileOverlay<T>?
    
    var showKeyPath: ReferenceWritableKeyPath<MapState, Bool?>?
    var userDefaultsShowPublisher: NSObject.KeyValueObservingPublisher<UserDefaults, Bool>?
    var sortDescriptors: [NSSortDescriptor] = []
    
    var focusNotificationName: Notification.Name?
    
    public init(fetchRequest: NSFetchRequest<T>? = nil, showAsTiles: Bool = true) {
        self.fetchRequest = fetchRequest
        self.fetchRequest?.sortDescriptors = sortDescriptors
        self.showAsTiles = showAsTiles
    }
    
    func getFetchRequest(mapState: MapState) -> NSFetchRequest<T> {
        if let showKeyPath = showKeyPath, let showItems = mapState[keyPath: showKeyPath], showItems == true {
            let fetchRequest: NSFetchRequest<T> = self.fetchRequest ?? T.fetchRequest() as! NSFetchRequest<T>
            if let tilePredicate = tilePredicate {
                fetchRequest.predicate = tilePredicate
            }
            fetchRequest.sortDescriptors = sortDescriptors
            return fetchRequest
        } else {
            let nilFetchRequest = T.fetchRequest()
            nilFetchRequest.predicate = NSPredicate(value: false)
            nilFetchRequest.sortDescriptors = sortDescriptors
            return nilFetchRequest as! NSFetchRequest<T>
        }
    }
    
    func getBoundingPredicate(minLat: Double, maxLat: Double, minLon: Double, maxLon: Double) -> NSPredicate {
        return NSPredicate(
            format: "latitude >= %lf AND latitude <= %lf AND longitude >= %lf AND longitude <= %lf", minLat, maxLat, minLon, maxLon
        )
    }
    
    func setupMixin(marlinMap: MarlinMap, mapView: MKMapView) {
        mapState = marlinMap.mapState
        
        if let focusNotificationName = focusNotificationName {
            NotificationCenter.default.publisher(for: focusNotificationName)
                .compactMap {
                    $0.object as? T
                }
                .sink(receiveValue: { [weak self] in
                    self?.focus(item: $0)
                })
                .store(in: &cancellable)
        }
        
        NotificationCenter.default.publisher(for: .DataSourceUpdated)
            .receive(on: RunLoop.main)
            .compactMap {
                $0.object as? DataSourceItem
            }
            .sink { item in
                if item.key == T.key {
                    print("New data for \(T.key), refresh overlay")
                    self.refreshOverlay(marlinMap: marlinMap)
                }
            }
            .store(in: &cancellable)
        
        userDefaultsShowPublisher?
            .removeDuplicates()
            .handleEvents(receiveOutput: { show in
                print("Show \(T.self): \(show)")
            })
            .sink() { [weak self] show in
                if let showKeyPath = self?.showKeyPath {
                    DispatchQueue.main.async {
                        marlinMap.mapState[keyPath: showKeyPath] = show
                    }
                }
                if let showAsTiles = self?.showAsTiles, showAsTiles {
                    self?.refreshOverlay(marlinMap: marlinMap)
                } else {
                    DispatchQueue.main.async {
                        marlinMap.mapState.fetchRequests[T.key] = self?.getFetchRequest(mapState: marlinMap.mapState) as? NSFetchRequest<NSFetchRequestResult>
                    }
                }
            }
            .store(in: &cancellable)
        
    }
    
    func refreshOverlay(marlinMap: MarlinMap) {
        DispatchQueue.main.async {
            if let overlay = self.overlay {
                marlinMap.mapState.overlays.removeAll { mapOverlay in
                    if let mapOverlay = mapOverlay as? FetchRequestTileOverlay<T> {
                        return mapOverlay == overlay
                    }
                    return false
                }
            }
            let newFetchRequest = self.getFetchRequest(mapState: marlinMap.mapState)
            let newOverlay = FetchRequestTileOverlay<T>()
            
            newOverlay.tileSize = CGSize(width: 512, height: 512)
            newOverlay.minimumZ = self.minZoom
            newOverlay.fetchRequest = newFetchRequest
            self.overlay = newOverlay
            marlinMap.mapState.overlays.append(newOverlay)
        }
    }
    
    func focus(item: T) {
        if let coordinate = item.coordinate {
            DispatchQueue.main.async {
                self.mapState?.center = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            }
        }
    }
    
    func viewForAnnotation(annotation: MKAnnotation, mapView: MKMapView) -> MKAnnotationView? {
        guard let annotation = annotation as? DataSource, let annotationView = annotation.view(on: mapView) else {
            return nil
        }
        
        annotationView.canShowCallout = false
        annotationView.isEnabled = false
        return annotationView
    }
    
    func items(at location: CLLocationCoordinate2D, mapView: MKMapView) -> [DataSource]? {
        if mapView.zoomLevel < minZoom {
            return nil
        }
        guard let mapState = mapState, let showKeyPath = showKeyPath, let showItems = mapState[keyPath: showKeyPath], showItems == true else {
            return nil
        }
        let screenPercentage = 0.03
        let tolerance = mapView.region.span.longitudeDelta * Double(screenPercentage)
        let minLon = location.longitude - tolerance
        let maxLon = location.longitude + tolerance
        let minLat = location.latitude - tolerance
        let maxLat = location.latitude + tolerance
        
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        
        fetchRequest.predicate = getBoundingPredicate(minLat: minLat, maxLat: maxLat, minLon: minLon, maxLon: maxLon)
        
        let context = PersistenceController.shared.container.viewContext
        return try? context.fetch(fetchRequest)
    }
    
}

class ImageAnnotationView: MKAnnotationView {
    
    /// - Tag: ClusterIdentifier
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
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
}
