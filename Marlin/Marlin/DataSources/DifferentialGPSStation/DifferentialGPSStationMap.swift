//
//  DifferentialGPSStationMap.swift
//  Marlin
//
//  Created by Daniel Barela on 8/30/22.
//

import Foundation
import MapKit
import CoreData
import Combine

class DifferentialGPSStationMap: NSObject, MapMixin {
    var minZoom = 4
    var mapState: MapState?
    var cancellable = Set<AnyCancellable>()
    
    var showAsTiles: Bool = true
    var fetchRequest: NSFetchRequest<DifferentialGPSStation>?
    var overlay: FetchRequestTileOverlay<DifferentialGPSStation>?
    
    public init(fetchRequest: NSFetchRequest<DifferentialGPSStation>? = nil, showAsTiles: Bool = true) {
        self.fetchRequest = fetchRequest
        self.showAsTiles = showAsTiles
    }
    
    func getFetchRequest(mapState: MapState) -> NSFetchRequest<DifferentialGPSStation> {
        if let showDifferentialGPSStations = mapState.showDifferentialGPSStations, showDifferentialGPSStations == true {
            let fetchRequest = self.fetchRequest ?? DifferentialGPSStation.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \DifferentialGPSStation.featureNumber, ascending: true)]
            return fetchRequest
        } else {
            let nilFetchRequest = DifferentialGPSStation.fetchRequest()
            nilFetchRequest.predicate = NSPredicate(value: false)
            nilFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \DifferentialGPSStation.featureNumber, ascending: true)]
            return nilFetchRequest
        }
    }
    
    func setupMixin(marlinMap: MarlinMap, mapView: MKMapView) {
        mapState = marlinMap.mapState
        
        mapView.register(DifferentialGPSStationAnnotationView.self, forAnnotationViewWithReuseIdentifier: DifferentialGPSStationAnnotationView.ReuseID)
        
        NotificationCenter.default.publisher(for: .FocusDifferentialGPSStation)
            .compactMap {
                $0.object as? DifferentialGPSStation
            }
            .sink(receiveValue: { [weak self] in
                self?.focus(differentialGPSStation: $0)
            })
            .store(in: &cancellable)
        
        UserDefaults.standard
            .publisher(for: \.showOnMapdifferentialGPSStation)
            .removeDuplicates()
            .handleEvents(receiveOutput: { show in
                print("Show Differential GPS Stations: \(show)")
            })
            .sink() { [weak self] in
                marlinMap.mapState.showDifferentialGPSStations = $0
                if let showAsTiles = self?.showAsTiles, showAsTiles {
                    if let differentialGPSStationOverlay = self?.overlay {
                        marlinMap.mapState.overlays.removeAll { overlay in
                            if let overlay = overlay as? FetchRequestTileOverlay<DifferentialGPSStation> {
                                return overlay == differentialGPSStationOverlay
                            }
                            return false
                        }
                    }
                    let newFetchRequest = self?.getFetchRequest(mapState: marlinMap.mapState)
                    let newOverlay = FetchRequestTileOverlay<DifferentialGPSStation>()
                    
                    newOverlay.tileSize = CGSize(width: 512, height: 512)
                    newOverlay.minimumZ = self?.minZoom ?? 0
                    newOverlay.fetchRequest = newFetchRequest
                    self?.overlay = newOverlay
                    marlinMap.mapState.overlays.append(newOverlay)
                } else {
                    marlinMap.mapState.fetchRequests[DifferentialGPSStation.key] = self?.getFetchRequest(mapState: marlinMap.mapState) as? NSFetchRequest<NSFetchRequestResult>
                }
                
            }
            .store(in: &cancellable)
    }
    
    func updateMixin(mapView: MKMapView, marlinMap: MarlinMap) {
    }
    
    func viewForAnnotation(annotation: MKAnnotation, mapView: MKMapView) -> MKAnnotationView? {
        guard let annotation = annotation as? DifferentialGPSStation else {
            return nil
        }
        
        let annotationView = annotation.view(on: mapView)
        annotationView.canShowCallout = false;
        annotationView.isEnabled = false;
        annotationView.accessibilityLabel = "Differential GPS Station Annotation \(annotation.featureNumber)";
        return annotationView;
    }
    
    func items(at location: CLLocationCoordinate2D, mapView: MKMapView) -> [DataSource]? {
        if mapView.zoomLevel < minZoom {
            return nil
        }
        guard let mapState = mapState, let showDifferentialGPSStations = mapState.showDifferentialGPSStations, showDifferentialGPSStations else {
            return nil
        }
        let screenPercentage = 0.03
        let tolerance = mapView.region.span.longitudeDelta * Double(screenPercentage)
        let minLon = location.longitude - tolerance
        let maxLon = location.longitude + tolerance
        let minLat = location.latitude - tolerance
        let maxLat = location.latitude + tolerance
        
        let fetchRequest: NSFetchRequest<DifferentialGPSStation>
        fetchRequest = DifferentialGPSStation.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(
            format: "latitude >= %lf AND latitude <= %lf AND longitude >= %lf AND longitude <= %lf", minLat, maxLat, minLon, maxLon
        )
        
        let context = PersistenceController.shared.container.viewContext
        return try? context.fetch(fetchRequest)
    }
    
    func focus(differentialGPSStation: DifferentialGPSStation) {
        mapState?.center = MKCoordinateRegion(center: differentialGPSStation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
    }
}

class DifferentialGPSStationAnnotationView: MKAnnotationView {
    static let ReuseID = DifferentialGPSStation.key
    
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
