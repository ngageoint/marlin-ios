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
    var uuid: UUID = UUID()
    
    var minZoom = 2
    var mapState: MapState?
    var cancellable = Set<AnyCancellable>()
    
    var showAsTiles: Bool = true
    var tilePredicate: NSPredicate?
    var fetchPredicate: NSPredicate?
    var objects: [T]?
    var overlay: PredicateTileOverlay<T>?
    
    var userDefaultsShowPublisher: NSObject.KeyValueObservingPublisher<UserDefaults, Bool>?
    var orderPublisher: NSObject.KeyValueObservingPublisher<UserDefaults, Int>?
    var sortDescriptors: [NSSortDescriptor] = []
    var lastChange: Date?
    
    var focusNotificationName: Notification.Name?
    
    var imageCache: Kingfisher.ImageCache
    var show: Bool = false
    
    public init(fetchPredicate: NSPredicate? = nil, objects: [T]? = nil, showAsTiles: Bool = true) {
        self.showAsTiles = showAsTiles
        self.fetchPredicate = fetchPredicate
        self.objects = objects
        imageCache = T.imageCache
        orderPublisher = UserDefaults.standard.orderPublisher(key: T.key)
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
            let filters = UserDefaults.standard.filter(D.definition)
            for filter in filters {
                if let predicate = filter.toPredicate(dataSource: DataSourceDefinitions.filterableFromDefintion(D.definition)) {
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
        if let dataSourceLocationType = T.self as? any Locatable.Type {
            return dataSourceLocationType.getBoundingPredicate(minLat: minLat, maxLat: maxLat, minLon: minLon, maxLon: maxLon)
        }
        return NSPredicate(
            format: "latitude >= %lf AND latitude <= %lf AND longitude >= %lf AND longitude <= %lf", minLat, maxLat, minLon, maxLon
        )
    }
    
    func setupMixin(mapState: MapState, mapView: MKMapView) {
        self.mapState = mapState
        
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
                            self.refreshOverlay(mapState: mapState)
                        })
                    } else {
                        self.refreshOverlay(mapState: mapState)
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
                self?.refreshOverlay(mapState: mapState)
            }
            .store(in: &cancellable)
        
        orderPublisher?
            .removeDuplicates()
            .handleEvents(receiveOutput: { order in
                print("Order update \(T.self): \(order)")
            })
            .sink() { [weak self] _ in
                self?.refreshOverlay(mapState: mapState)
            }
            .store(in: &cancellable)
        
        LocationManager.shared().$current10kmMGRS
            .receive(on: RunLoop.main)
            .sink() { [weak self] mgrsZone in
                self?.refreshOverlay(mapState: mapState)
            }
            .store(in: &cancellable)
    }
    
    func updateMixin(mapView: MKMapView, mapState: MapState) {
        if lastChange == nil || lastChange != mapState.mixinStates["FetchRequestMixin\(T.key)DateUpdated"] as? Date {
            lastChange = mapState.mixinStates["FetchRequestMixin\(T.key)DataUpdated"] as? Date ?? Date()
            
            if mapState.mixinStates["FetchRequestMixin\(T.key)DataUpdated"] as? Date == nil {
                DispatchQueue.main.async {
                    mapState.mixinStates["FetchRequestMixin\(T.key)DataUpdated"] = self.lastChange
                }
            }
            
            if let selfOverlay = self.overlay {
                mapView.removeOverlay(selfOverlay)
            }
            
            let newFetchRequest = self.getFetchRequest(show: self.show)
            let newOverlay = PredicateTileOverlay<T>(predicate: newFetchRequest?.predicate, sortDescriptors: newFetchRequest?.sortDescriptors, boundingPredicate: getBoundingPredicate, objects: self.objects, imageCache: self.imageCache)
            
            newOverlay.tileSize = CGSize(width: 512, height: 512)
            newOverlay.minimumZ = self.minZoom
            
            self.overlay = newOverlay
            // find the right place
            let mapOrder = UserDefaults.standard.dataSourceMapOrder(T.key)
            if mapView.overlays(in: .aboveLabels).isEmpty{
                mapView.insertOverlay(newOverlay, at: 0, level: .aboveLabels)
            } else {
                for added in mapView.overlays(in: .aboveLabels) {
                    if let added = added as? any PredicateBasedTileOverlay, let key = added.key, let addedOverlay = added as? MKTileOverlay {
                        let addedOrder = UserDefaults.standard.dataSourceMapOrder(key)
                        if addedOrder < mapOrder {
                            mapView.insertOverlay(newOverlay, below: addedOverlay)
                            return
                        }
                    }
                }
            }
            
            mapView.insertOverlay(newOverlay, at: mapView.overlays(in: .aboveLabels).count, level: .aboveLabels)
        }
    }
    
    func removeMixin(mapView: MKMapView, mapState: MapState) {
        if let overlay = self.overlay {
            mapView.removeOverlay(overlay)
        }
    }
    
    func refreshOverlay(mapState: MapState) {
        DispatchQueue.main.async {
            self.mapState?.mixinStates["FetchRequestMixin\(T.key)DateUpdated"] = Date()
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
    
    func items(at location: CLLocationCoordinate2D, mapView: MKMapView, touchPoint: CGPoint) -> [any DataSource]? {
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
