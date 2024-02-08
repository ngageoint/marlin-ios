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

class DataSourceMap: MapMixin {
    var uuid: UUID = UUID()
    var cancellable = Set<AnyCancellable>()
    var minZoom = 2

    var repository: TileRepository

    var mapState: MapState?
    var lastChange: Date?
    var overlay: DataSourceTileOverlay?

    var focusNotificationName: Notification.Name?

    var userDefaultsShowPublisher: NSObject.KeyValueObservingPublisher<UserDefaults, Bool>?
    var orderPublisher: NSObject.KeyValueObservingPublisher<UserDefaults, Int>?

    var show = false
    var repositoryAlwaysShow = false

    init(repository: TileRepository) {
        self.repository = repository
        self.repositoryAlwaysShow = repository.alwaysShow
    }

    func setupMixin(mapState: MapState, mapView: MKMapView) {
        self.mapState = mapState

//        if let focusNotificationName = focusNotificationName {
//            NotificationCenter.default.publisher(for: focusNotificationName)
//                .compactMap {
//                    $0.object as? T
//                }
//                .sink(receiveValue: { [weak self] in
//                    self?.focus(item: $0)
//                })
//                .store(in: &cancellable)
//        }

        DispatchQueue.main.async {
            self.setupDataSourceUpdatedPublisher(mapState: mapState)
            self.setupUserDefaultsShowPublisher(mapState: mapState)
            self.setupOrderPublisher(mapState: mapState)
        }

        LocationManager.shared().$current10kmMGRS
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.refreshOverlay(mapState: mapState)
            }
            .store(in: &cancellable)
    }

    func updateMixin(mapView: MKMapView, mapState: MapState) {
        var stateKey = "FetchRequestMixin\(repository.dataSource.key)DateUpdated"
        if lastChange == nil
            || lastChange != mapState.mixinStates[stateKey] as? Date {
            lastChange = mapState.mixinStates[stateKey] as? Date ?? Date()

            if mapState.mixinStates[stateKey] as? Date == nil {
                DispatchQueue.main.async {
                    mapState.mixinStates[stateKey] = self.lastChange
                }
            }

            if let selfOverlay = self.overlay {
                mapView.removeOverlay(selfOverlay)
            }

            if !show && !repositoryAlwaysShow {
                return
            }
            let newOverlay = DataSourceTileOverlay(tileRepository: repository)
            newOverlay.tileSize = CGSize(width: 512, height: 512)
            newOverlay.minimumZ = self.minZoom

            self.overlay = newOverlay
            // find the right place
            var mapOrder = UserDefaults.standard.dataSourceMapOrder(self.repository.dataSource.key)
            if mapView.overlays(in: .aboveLabels).isEmpty {
                mapView.insertOverlay(newOverlay, at: 0, level: .aboveLabels)
            } else {
                for added in mapView.overlays(in: .aboveLabels) {
                    if let added = added as? any PredicateBasedTileOverlay,
                        let key = added.key,
                       let addedOverlay = added as? MKTileOverlay {
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
            self.mapState?.mixinStates[
                "FetchRequestMixin\(self.repository.dataSource.key)DateUpdated"
            ] = Date()
        }
    }

    func setupDataSourceUpdatedPublisher(mapState: MapState) {
        NotificationCenter.default.publisher(for: .DataSourceUpdated)
            .receive(on: RunLoop.main)
            .compactMap {
                $0.object as? DataSourceUpdatedNotification
            }
            .sink { item in
                let key = self.repository.dataSource.key
                if item.key == key {
                    NSLog("New data for \(key), refresh overlay, clear the cache")
                    self.repository.clearCache(completion: {
                        self.refreshOverlay(mapState: mapState)
                    })
                }
            }
            .store(in: &cancellable)
    }

    func setupUserDefaultsShowPublisher(mapState: MapState) {
        userDefaultsShowPublisher?
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] show in
                self?.show = show
                NSLog("Show \(self?.repository.dataSource.key ?? ""): \(show)")
                self?.refreshOverlay(mapState: mapState)
            }
            .store(in: &cancellable)
    }

    func setupOrderPublisher(mapState: MapState) {
        orderPublisher?
            .removeDuplicates()
            .sink { [weak self] order in
                NSLog("Order update \(self?.repository.dataSource.key ?? ""): \(order)")

                self?.refreshOverlay(mapState: mapState)
            }
            .store(in: &cancellable)
    }

    func items(
        at location: CLLocationCoordinate2D,
        mapView: MKMapView,
        touchPoint: CGPoint
    ) -> [any DataSource]? {
        return nil
    }

    func itemKeys(
        at location: CLLocationCoordinate2D,
        mapView: MKMapView,
        touchPoint: CGPoint
    ) -> [String: [String]] {
        if mapView.zoomLevel < minZoom {
            return [:]
        }
        guard show == true else {
            return [:]
        }
        let screenPercentage = 0.03
        let tolerance = mapView.region.span.longitudeDelta * Double(screenPercentage)
        let minLon = location.longitude - tolerance
        let maxLon = location.longitude + tolerance
        let minLat = location.latitude - tolerance
        let maxLat = location.latitude + tolerance

        return [
            repository.dataSource.key: repository.getItemKeys(
                minLatitude: minLat,
                maxLatitude: maxLat,
                minLongitude: minLon,
                maxLongitude: maxLon
            )
        ]
    }

}

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
        NSLog("def key \(T.definition.key)")
        orderPublisher = UserDefaults.standard.orderPublisher(key: T.definition.key)
    }
    
    func getFetchRequest(show: Bool) -> NSFetchRequest<NSManagedObject>? {
        guard let batchImportableType = T.self as? any BatchImportable.Type,
              let dataSourceType = T.self as? any DataSource.Type else {
            return nil
        }
        guard let fetchRequest: NSFetchRequest<NSManagedObject> =
                batchImportableType.fetchRequest() as? NSFetchRequest<NSManagedObject> else {
            return nil
        }
        fetchRequest.sortDescriptors = sortDescriptors

        var filterPredicates: [NSPredicate] = []
        
        if let presetPredicate = fetchPredicate {
            filterPredicates.append(presetPredicate)
        } else if show == true {
            let filters = UserDefaults.standard.filter(dataSourceType.definition)
            for filter in filters {
                if let predicate = filter.toPredicate(
                    dataSource: DataSources.filterableFromDefintion(dataSourceType.definition)
                ) {
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
            return dataSourceLocationType.getBoundingPredicate(
                minLat: minLat,
                maxLat: maxLat,
                minLon: minLon,
                maxLon: maxLon)
        }
        return NSPredicate(
            format: "latitude >= %lf AND latitude <= %lf AND longitude >= %lf AND longitude <= %lf",
            minLat, maxLat, minLon, maxLon
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
        
        setupDataSourceUpdatedPublisher(mapState: mapState)
        setupUserDefaultsShowPublisher(mapState: mapState)
        setupOrderPublisher(mapState: mapState)

        LocationManager.shared().$current10kmMGRS
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.refreshOverlay(mapState: mapState)
            }
            .store(in: &cancellable)
    }

    func setupDataSourceUpdatedPublisher(mapState: MapState) {
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
    }

    func setupUserDefaultsShowPublisher(mapState: MapState) {
        userDefaultsShowPublisher?
            .removeDuplicates()
            .handleEvents(receiveOutput: { show in
                print("Show \(T.self): \(show)")
            })
            .sink { [weak self] show in
                self?.show = show
                self?.refreshOverlay(mapState: mapState)
            }
            .store(in: &cancellable)
    }

    func setupOrderPublisher(mapState: MapState) {
        orderPublisher?
            .removeDuplicates()
            .handleEvents(receiveOutput: { order in
                print("Order update \(T.self): \(order)")
            })
            .sink { [weak self] _ in
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
            let newOverlay = PredicateTileOverlay<T>(
                predicate: newFetchRequest?.predicate,
                sortDescriptors: newFetchRequest?.sortDescriptors,
                boundingPredicate: getBoundingPredicate,
                objects: self.objects,
                imageCache: self.imageCache)

            newOverlay.tileSize = CGSize(width: 512, height: 512)
            newOverlay.minimumZ = self.minZoom
            
            self.overlay = newOverlay
            // find the right place
            let mapOrder = UserDefaults.standard.dataSourceMapOrder(T.key)
            if mapView.overlays(in: .aboveLabels).isEmpty {
                mapView.insertOverlay(newOverlay, at: 0, level: .aboveLabels)
            } else {
                for added in mapView.overlays(in: .aboveLabels) {
                    if let added = added as? any PredicateBasedTileOverlay, 
                        let key = added.key,
                        let addedOverlay = added as? MKTileOverlay {
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
            self.mapState?.center = MKCoordinateRegion(
                center: item.coordinate,
                latitudinalMeters: 1000,
                longitudinalMeters: 1000)
        }
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

    func itemKeys(at location: CLLocationCoordinate2D, mapView: MKMapView, touchPoint: CGPoint) -> [String: [String]] {
        return [:]
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
