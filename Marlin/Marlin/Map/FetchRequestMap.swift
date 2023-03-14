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
import Kingfisher

class FetchRequestMap<T: MapImage>: NSObject, MapMixin {
    var minZoom = 2
    var mapState: MapState?
    var cancellable = Set<AnyCancellable>()
    
    var showAsTiles: Bool = true
    var tilePredicate: NSPredicate?
    var fetchPredicate: NSPredicate?
    var objects: [T]?
    var overlay: PredicateTileOverlay<T>?
    
    var userDefaultsShowPublisher: NSObject.KeyValueObservingPublisher<UserDefaults, Bool>?
    var sortDescriptors: [NSSortDescriptor] = []
    
    var focusNotificationName: Notification.Name?
    
    var imageCache: Kingfisher.ImageCache
    var show: Bool = false
    
    public init(fetchPredicate: NSPredicate? = nil, objects: [T]? = nil, showAsTiles: Bool = true) {
        self.showAsTiles = showAsTiles
        self.fetchPredicate = fetchPredicate
        self.objects = objects
        imageCache = T.imageCache
    }
    
    func getFetchRequest(show: Bool) -> NSFetchRequest<NSManagedObject>? {
        guard let M = T.self as? any BatchImportable.Type, let D = T.self as? any DataSource.Type else {
            return nil
        }
        let fetchRequest: NSFetchRequest<NSManagedObject> = M.fetchRequest() as! NSFetchRequest<NSManagedObject>
        fetchRequest.sortDescriptors = sortDescriptors

        var filterPredicates: [NSPredicate] = []
        
        if let presetPredicate = fetchPredicate {
            filterPredicates.append(presetPredicate)
        } else if show == true {
            let filters = UserDefaults.standard.filter(D.self)
            for filter in filters {
                if let predicate = filter.toPredicate() {
                    filterPredicates.append(predicate)
                }
            }
        } else {
            filterPredicates.append(NSPredicate(value: false))
        }
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: filterPredicates)
        return fetchRequest
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
                $0.object as? DataSourceUpdatedNotification
            }
            .sink { item in
                if item.key == T.key {
                    if T.cacheTiles {
                        print("New data for \(T.key), refresh overlay, clear the cache")
                        // Clear the cache
                        self.imageCache.clearCache(completion: {
                            self.refreshOverlay(marlinMap: marlinMap)
                        })
                    } else {
                        self.refreshOverlay(marlinMap: marlinMap)
                    }
                }
            }
            .store(in: &cancellable)
        
        userDefaultsShowPublisher?
            .removeDuplicates()
            .handleEvents(receiveOutput: { show in
                print("Show \(T.self): \(show)")
            })
            .sink() { [weak self] show in
                self?.show = show
                self?.refreshOverlay(marlinMap: marlinMap)
            }
            .store(in: &cancellable)
        
        LocationManager.shared.$current10kmMGRS
            .receive(on: RunLoop.main)
            .sink() { [weak self] mgrsZone in
                self?.refreshOverlay(marlinMap: marlinMap)
            }
            .store(in: &cancellable)
    }
    
    func updateMixin(mapView: MKMapView, mapState: MapState) {
        if let selfOverlay = self.overlay {
            if let newOverlay = mapState.mixinStates["FetchRequestMixin\(T.key)"] as? PredicateTileOverlay<T> {
                if selfOverlay != newOverlay {
                    mapView.removeOverlay(selfOverlay)
                    mapView.addOverlay(newOverlay)
                    self.overlay = newOverlay
                }
            } else {
                mapView.removeOverlay(selfOverlay)
            }
        } else if let newOverlay = mapState.mixinStates["FetchRequestMixin\(T.key)"] as? PredicateTileOverlay<T> {
            mapView.addOverlay(newOverlay)
            self.overlay = newOverlay
        }
    }
    
    func refreshOverlay(marlinMap: MarlinMap) {
        DispatchQueue.main.async {
            let newFetchRequest = self.getFetchRequest(show: self.show)
            let newOverlay = PredicateTileOverlay<T>(predicate: newFetchRequest?.predicate, sortDescriptors: newFetchRequest?.sortDescriptors, objects: self.objects, imageCache: self.imageCache)
            
            newOverlay.tileSize = CGSize(width: 512, height: 512)
            newOverlay.minimumZ = self.minZoom
            marlinMap.mapState.mixinStates["FetchRequestMixin\(T.key)"] = newOverlay
        }
    }
    
    func focus(item: T) {
        DispatchQueue.main.async {
            self.mapState?.center = MKCoordinateRegion(center: item.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        }
    }
    
    func viewForAnnotation(annotation: MKAnnotation, mapView: MKMapView) -> MKAnnotationView? {
        guard let annotation = annotation as? (any DataSource), let annotationView = annotation.view(on: mapView) else {
            return nil
        }
        annotationView.canShowCallout = false
        annotationView.isEnabled = false
        return annotationView
    }
    
    func items(at location: CLLocationCoordinate2D, mapView: MKMapView) -> [any DataSource]? {
        if mapView.zoomLevel < minZoom {
            return nil
        }
        guard show == true else {
            return nil
        }
        let screenPercentage = 0.03
        let tolerance = mapView.region.span.longitudeDelta * Double(screenPercentage)
        let minLon = location.longitude - tolerance
        let maxLon = location.longitude + tolerance
        let minLat = location.latitude - tolerance
        let maxLat = location.latitude + tolerance
        
        guard let fetchRequest = self.getFetchRequest(show: self.show) else {
            return nil
        }
        var predicates: [NSPredicate] = []
        if let predicate = fetchRequest.predicate {
            predicates.append(predicate)
        }
        
        predicates.append(getBoundingPredicate(minLat: minLat, maxLat: maxLat, minLon: minLon, maxLon: maxLon))
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        return try? PersistenceController.current.fetch(fetchRequest: fetchRequest) as? [any DataSource]
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
