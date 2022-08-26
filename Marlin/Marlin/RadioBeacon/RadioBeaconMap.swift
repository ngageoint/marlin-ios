//
//  RadioBeaconMap.swift
//  Marlin
//
//  Created by Daniel Barela on 8/25/22.
//

import Foundation
import MapKit
import CoreData
import Combine

class RadioBeaconMap: NSObject, MapMixin {
    var minZoom = 4
    var mapState: MapState?
    var cancellable = Set<AnyCancellable>()
    
    var showRadioBeaconsAsTiles: Bool = true
    var fetchRequest: NSFetchRequest<RadioBeacon>?
    var radioBeaconOverlay: FetchRequestTileOverlay<RadioBeacon>?
    
    public init(fetchRequest: NSFetchRequest<RadioBeacon>? = nil, showRadioBeaconsAsTiles: Bool = true) {
        self.fetchRequest = fetchRequest
        self.showRadioBeaconsAsTiles = showRadioBeaconsAsTiles
    }
    
    func getFetchRequest(mapState: MapState) -> NSFetchRequest<RadioBeacon> {
        if let showRadioBeacons = mapState.showRadioBeacons, showRadioBeacons == true {
            let fetchRequest = self.fetchRequest ?? RadioBeacon.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \RadioBeacon.featureNumber, ascending: true)]
            return fetchRequest
        } else {
            let nilFetchRequest = RadioBeacon.fetchRequest()
            nilFetchRequest.predicate = NSPredicate(value: false)
            nilFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \RadioBeacon.featureNumber, ascending: true)]
            return nilFetchRequest
        }
    }
    
    func setupMixin(marlinMap: MarlinMap, mapView: MKMapView) {
        mapState = marlinMap.mapState
        
        mapView.register(RadioBeaconAnnotationView.self, forAnnotationViewWithReuseIdentifier: RadioBeaconAnnotationView.ReuseID)
        
        NotificationCenter.default.publisher(for: .FocusRadioBeacon)
            .compactMap {
                $0.object as? RadioBeacon
            }
            .sink(receiveValue: { [weak self] in
                self?.focusRadioBeacon(radioBeacon: $0)
            })
            .store(in: &cancellable)
        
        UserDefaults.standard
            .publisher(for: \.showOnMapradioBeacon)
            .removeDuplicates()
            .handleEvents(receiveOutput: { show in
                print("Show Radio Beacons: \(show)")
            })
            .sink() { [weak self] in
                marlinMap.mapState.showRadioBeacons = $0
                if let showRadioBeaconsAsTiles = self?.showRadioBeaconsAsTiles, showRadioBeaconsAsTiles {
                    if let radioBeaconOverlay = self?.radioBeaconOverlay {
                        marlinMap.mapState.overlays.removeAll { overlay in
                            if let overlay = overlay as? FetchRequestTileOverlay<RadioBeacon> {
                                return overlay == radioBeaconOverlay
                            }
                            return false
                        }
                    }
                    let newFetchRequest = self?.getFetchRequest(mapState: marlinMap.mapState)
                    let newOverlay = FetchRequestTileOverlay<RadioBeacon>()
                    
                    newOverlay.tileSize = CGSize(width: 512, height: 512)
                    newOverlay.minimumZ = self?.minZoom ?? 0
                    newOverlay.fetchRequest = newFetchRequest
                    self?.radioBeaconOverlay = newOverlay
                    marlinMap.mapState.overlays.append(newOverlay)
                } else {
                    marlinMap.mapState.fetchRequests[RadioBeacon.key] = self?.getFetchRequest(mapState: marlinMap.mapState) as? NSFetchRequest<NSFetchRequestResult>
                }
                
            }
            .store(in: &cancellable)
    }
    
    func updateMixin(mapView: MKMapView, marlinMap: MarlinMap) {
    }
    
    func viewForAnnotation(annotation: MKAnnotation, mapView: MKMapView) -> MKAnnotationView? {
        guard let radioBeaconAnnotation = annotation as? RadioBeacon else {
            return nil
        }
        
        let annotationView = radioBeaconAnnotation.view(on: mapView)
        annotationView.canShowCallout = false;
        annotationView.isEnabled = false;
        annotationView.accessibilityLabel = "Radio Beacon Annotation \(radioBeaconAnnotation.featureNumber)";
        return annotationView;
    }
    
    func items(at location: CLLocationCoordinate2D, mapView: MKMapView) -> [DataSource]? {
        if let radioBeaconOverlay = radioBeaconOverlay, radioBeaconOverlay.zoomLevel < minZoom {
            return nil
        }
        guard let mapState = mapState, let showRadioBeacons = mapState.showRadioBeacons, showRadioBeacons else {
            return nil
        }
        let screenPercentage = 0.03
        let tolerance = mapView.region.span.longitudeDelta * Double(screenPercentage)
        let minLon = location.longitude - tolerance
        let maxLon = location.longitude + tolerance
        let minLat = location.latitude - tolerance
        let maxLat = location.latitude + tolerance
        
        let fetchRequest: NSFetchRequest<RadioBeacon>
        fetchRequest = RadioBeacon.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(
            format: "latitude >= %lf AND latitude <= %lf AND longitude >= %lf AND longitude <= %lf", minLat, maxLat, minLon, maxLon
        )
        
        let context = PersistenceController.shared.container.viewContext
        return try? context.fetch(fetchRequest)
    }
    
    func focusRadioBeacon(radioBeacon: RadioBeacon) {
        mapState?.center = MKCoordinateRegion(center: radioBeacon.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
    }
}

class RadioBeaconAnnotationView: MKAnnotationView {
    static let ReuseID = RadioBeacon.key
    
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
