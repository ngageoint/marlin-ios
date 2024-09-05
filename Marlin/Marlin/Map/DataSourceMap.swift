//
//  DataSourceMap.swift
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

    var repository: TileRepository?
    var mapFeatureRepository: MapFeatureRepository?

    var mapState: MapState?
    var lastChange: Date?
    var overlays: [MKOverlay] = []
    var annotations: [MKAnnotation] = []

    var focusNotificationName: Notification.Name?

    var userDefaultsShowPublisher: NSObject.KeyValueObservingPublisher<UserDefaults, Bool>?
    var orderPublisher: NSObject.KeyValueObservingPublisher<UserDefaults, Int>?

    var show = false
    var repositoryAlwaysShow: Bool {
        repository?.alwaysShow ?? mapFeatureRepository?.alwaysShow ?? false
    }

    var dataSourceKey: String {
        repository?.dataSource.key ?? mapFeatureRepository?.dataSource.key ?? ""
    }

    init(repository: TileRepository? = nil, mapFeatureRepository: MapFeatureRepository? = nil) {
        self.repository = repository
        self.mapFeatureRepository = mapFeatureRepository
    }

    func setupMixin(mapState: MapState, mapView: MKMapView) {
        self.mapState = mapState

        self.setupDataSourceUpdatedPublisher(mapState: mapState)
        self.setupUserDefaultsShowPublisher(mapState: mapState)
        self.setupOrderPublisher(mapState: mapState)

        LocationManager.shared().$current10kmMGRS
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.refreshOverlay(mapState: mapState)
            }
            .store(in: &cancellable)
    }

    func updateMixin(mapView: MKMapView, mapState: MapState) {
        let stateKey = "FetchRequestMixin\(dataSourceKey)DateUpdated"
        if lastChange == nil
            || lastChange != mapState.mixinStates[stateKey] as? Date {
            lastChange = mapState.mixinStates[stateKey] as? Date ?? Date()

            if mapState.mixinStates[stateKey] as? Date == nil {
                DispatchQueue.main.async {
                    mapState.mixinStates[stateKey] = self.lastChange
                }
            }

            for overlay in overlays {
                mapView.removeOverlay(overlay)
            }
            mapView.removeAnnotations(annotations)
            overlays = []
            annotations = []

            if !show && !repositoryAlwaysShow {
                return
            }
            if let repository = repository {
                let newOverlay = DataSourceTileOverlay(tileRepository: repository, key: dataSourceKey)
                newOverlay.tileSize = CGSize(width: 512, height: 512)
                newOverlay.minimumZ = self.minZoom

                overlays.append(newOverlay)
                addFeatures(features: AnnotationsAndOverlays(annotations: [], overlays: overlays), mapView: mapView)
            }

            Task {
                let features = await mapFeatureRepository?.getAnnotationsAndOverlays()
                if let features = features {
                    annotations.append(contentsOf: features.annotations)
                    overlays.append(contentsOf: features.overlays)
                    await MainActor.run {
                        addFeatures(features: features, mapView: mapView)
                    }
                }
            }
        }
    }

    func addFeatures(features: AnnotationsAndOverlays, mapView: MKMapView) {
        mapView.addAnnotations(features.annotations)
        // find the right place
        let mapOrder = UserDefaults.standard.dataSourceMapOrder(dataSourceKey)
        if mapView.overlays(in: .aboveLabels).isEmpty {
            for overlay in features.overlays {
                mapView.insertOverlay(overlay, at: 0, level: .aboveLabels)
            }
            return
        } else {
            for added in mapView.overlays(in: .aboveLabels) {
                if let added = added as? any DataSourceOverlay,
                   let key = added.key,
                   let addedOverlay = added as? MKTileOverlay {
                    let addedOrder = UserDefaults.standard.dataSourceMapOrder(key)
                    if addedOrder < mapOrder {
                        for overlay in features.overlays {
                            mapView.insertOverlay(overlay, below: addedOverlay)
                        }
                        return
                    }
                }
            }
        }

        for overlay in features.overlays {
            mapView.insertOverlay(overlay, at: mapView.overlays(in: .aboveLabels).count, level: .aboveLabels)
        }
    }

    func removeMixin(mapView: MKMapView, mapState: MapState) {
        for overlay in overlays {
            mapView.removeOverlay(overlay)
        }
        mapView.removeAnnotations(annotations)
    }

    func refreshOverlay(mapState: MapState) {
        DispatchQueue.main.async {
            self.mapState?.mixinStates[
                "FetchRequestMixin\(self.dataSourceKey)DateUpdated"
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
                let key = self.dataSourceKey
                if item.key == key {
                    NSLog("New data for \(key), refresh overlay, clear the cache")
                    self.repository?.clearCache(completion: {
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
                NSLog("Show \(self?.dataSourceKey ?? ""): \(show)")
                self?.refreshOverlay(mapState: mapState)
            }
            .store(in: &cancellable)
    }

    func setupOrderPublisher(mapState: MapState) {
        orderPublisher?
            .removeDuplicates()
            .sink { [weak self] order in
                NSLog("Order update \(self?.dataSourceKey ?? ""): \(order)")

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
    ) async -> [String: [String]] {
        if await mapView.zoomLevel < minZoom {
            return [:]
        }
        guard show == true else {
            return [:]
        }
        let screenPercentage = 0.03
        let tolerance = await mapView.region.span.longitudeDelta * Double(screenPercentage)
        let minLon = location.longitude - tolerance
        let maxLon = location.longitude + tolerance
        let minLat = location.latitude - tolerance
        let maxLat = location.latitude + tolerance

        return [
            dataSourceKey: await repository?.getItemKeys(
                minLatitude: minLat,
                maxLatitude: maxLat,
                minLongitude: minLon,
                maxLongitude: maxLon
            ) ?? []
        ]
    }

    func renderer(overlay: MKOverlay) -> MKOverlayRenderer? {
        standardRenderer(overlay: overlay)
    }

    func viewForAnnotation(annotation: MKAnnotation, mapView: MKMapView) -> MKAnnotationView? {
        return nil
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
