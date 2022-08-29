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
    var minZoom = 4
    var mapState: MapState?
    var cancellable = Set<AnyCancellable>()
    
    var showLightsAsTiles: Bool = true
    var fetchRequest: NSFetchRequest<Light>?
    var lightOverlay: FetchRequestTileOverlay<Light>?
    
    public init(fetchRequest: NSFetchRequest<Light>? = nil, showLightsAsTiles: Bool = true) {
        self.fetchRequest = fetchRequest
        self.showLightsAsTiles = showLightsAsTiles
    }
    
    func getFetchRequest(mapState: MapState) -> NSFetchRequest<Light> {
        if let showLights = mapState.showLights, showLights == true {
            let fetchRequest = self.fetchRequest ?? Light.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Light.featureNumber, ascending: true)]
            return fetchRequest
        } else {
            let nilFetchRequest = Light.fetchRequest()
            nilFetchRequest.predicate = NSPredicate(value: false)
            nilFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Light.featureNumber, ascending: true)]
            return nilFetchRequest
        }
    }
    
    func setupMixin(marlinMap: MarlinMap, mapView: MKMapView) {
        mapState = marlinMap.mapState
        
        mapView.register(LightAnnotationView.self, forAnnotationViewWithReuseIdentifier: LightAnnotationView.ReuseID)
        
        NotificationCenter.default.publisher(for: .FocusLight)
            .compactMap {
                $0.object as? Light
            }
            .sink(receiveValue: { [weak self] in
                self?.focusLight(light: $0)
            })
            .store(in: &cancellable)
        
        UserDefaults.standard
            .publisher(for: \.showOnMaplight)
            .removeDuplicates()
            .handleEvents(receiveOutput: { show in
                print("Show Lights: \(show)")
            })
            .sink() { [weak self] in
                marlinMap.mapState.showLights = $0
                if let showLightsAsTiles = self?.showLightsAsTiles, showLightsAsTiles {
                    if let lightOverlay = self?.lightOverlay {
                        marlinMap.mapState.overlays.removeAll { overlay in
                            if let overlay = overlay as? FetchRequestTileOverlay<Light> {
                                return overlay == lightOverlay
                            }
                            return false
                        }
                    }
                    let newFetchRequest = self?.getFetchRequest(mapState: marlinMap.mapState)
                    let newOverlay = FetchRequestTileOverlay<Light>()
                    
                    newOverlay.tileSize = CGSize(width: 512, height: 512)
                    newOverlay.minimumZ = self?.minZoom ?? 0
                    newOverlay.fetchRequest = newFetchRequest
                    self?.lightOverlay = newOverlay
                    marlinMap.mapState.overlays.append(newOverlay)
                } else {
                    marlinMap.mapState.fetchRequests[Light.key] = self?.getFetchRequest(mapState: marlinMap.mapState) as? NSFetchRequest<NSFetchRequestResult>
                }
                
            }
            .store(in: &cancellable)
    }
    
    func updateMixin(mapView: MKMapView, marlinMap: MarlinMap) {
    }
    
    func viewForAnnotation(annotation: MKAnnotation, mapView: MKMapView) -> MKAnnotationView? {
        guard let lightAnnotation = annotation as? Light else {
            return nil
        }
        
        let annotationView = lightAnnotation.view(on: mapView)
        annotationView.canShowCallout = false;
        annotationView.isEnabled = false;
        annotationView.accessibilityLabel = "Light Annotation \(lightAnnotation.featureNumber ?? "")";
        return annotationView;
    }
    
    func items(at location: CLLocationCoordinate2D, mapView: MKMapView) -> [DataSource]? {
        if let lightOverlay = lightOverlay, lightOverlay.zoomLevel < minZoom {
            return nil
        }
        guard let mapState = mapState, let showLights = mapState.showLights, showLights else {
            return nil
        }
        let screenPercentage = 0.03
        let tolerance = mapView.region.span.longitudeDelta * Double(screenPercentage)
        let minLon = location.longitude - tolerance
        let maxLon = location.longitude + tolerance
        let minLat = location.latitude - tolerance
        let maxLat = location.latitude + tolerance
        
        let fetchRequest: NSFetchRequest<Light>
        fetchRequest = Light.fetchRequest()
                
        fetchRequest.predicate = NSPredicate(
            format: "characteristicNumber = 1 AND latitude >= %lf AND latitude <= %lf AND longitude >= %lf AND longitude <= %lf", minLat, maxLat, minLon, maxLon
        )
        
        let context = PersistenceController.shared.container.viewContext
        return try? context.fetch(fetchRequest)
    }

    func focusLight(light: Light) {
        mapState?.center = MKCoordinateRegion(center: light.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
    }
}

class LightAnnotationView: MKAnnotationView {
    static let ReuseID = "light"
    
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
