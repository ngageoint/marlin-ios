//
//  DFRSMap.swift
//  Marlin
//
//  Created by Daniel Barela on 8/30/22.
//

import Foundation
import MapKit
import CoreData
import Combine

class DFRSMap: NSObject, MapMixin {
    var minZoom = 4
    var mapState: MapState?
    var cancellable = Set<AnyCancellable>()
    
    var showAsTiles: Bool = true
    var fetchRequest: NSFetchRequest<DFRS>?
    var overlay: FetchRequestTileOverlay<DFRS>?
    
    public init(fetchRequest: NSFetchRequest<DFRS>? = nil, showAsTiles: Bool = true) {
        self.fetchRequest = fetchRequest
        self.showAsTiles = showAsTiles
    }
    
    func getFetchRequest(mapState: MapState) -> NSFetchRequest<DFRS> {
        if let showDFRS = mapState.showDFRS, showDFRS == true {
            let fetchRequest = self.fetchRequest ?? DFRS.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "rxPosition != nil OR txPosition != nil")
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \DFRS.stationNumber, ascending: true)]
            return fetchRequest
        } else {
            let nilFetchRequest = DFRS.fetchRequest()
            nilFetchRequest.predicate = NSPredicate(value: false)
            nilFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \DFRS.stationNumber, ascending: true)]
            return nilFetchRequest
        }
    }
    
    func setupMixin(marlinMap: MarlinMap, mapView: MKMapView) {
        mapState = marlinMap.mapState
        
        mapView.register(DFRSAnnotationView.self, forAnnotationViewWithReuseIdentifier: DFRSAnnotationView.ReuseID)
        
        NotificationCenter.default.publisher(for: .FocusDFRS)
            .compactMap {
                $0.object as? DFRS
            }
            .sink(receiveValue: { [weak self] in
                self?.focus(dfrs: $0)
            })
            .store(in: &cancellable)
        
        UserDefaults.standard
            .publisher(for: \.showOnMapdfrs)
            .removeDuplicates()
            .handleEvents(receiveOutput: { show in
                print("Show DFRS: \(show)")
            })
            .sink() { [weak self] in
                marlinMap.mapState.showDFRS = $0
                if let showAsTiles = self?.showAsTiles, showAsTiles {
                    if let dfrsOverlay = self?.overlay {
                        marlinMap.mapState.overlays.removeAll { overlay in
                            if let overlay = overlay as? FetchRequestTileOverlay<DFRS> {
                                return overlay == dfrsOverlay
                            }
                            return false
                        }
                    }
                    let newFetchRequest = self?.getFetchRequest(mapState: marlinMap.mapState)
                    let newOverlay = FetchRequestTileOverlay<DFRS>()
                    
                    newOverlay.tileSize = CGSize(width: 512, height: 512)
                    newOverlay.minimumZ = self?.minZoom ?? 0
                    newOverlay.fetchRequest = newFetchRequest
                    self?.overlay = newOverlay
                    marlinMap.mapState.overlays.append(newOverlay)
                } else {
                    marlinMap.mapState.fetchRequests[DFRS.key] = self?.getFetchRequest(mapState: marlinMap.mapState) as? NSFetchRequest<NSFetchRequestResult>
                }
                
            }
            .store(in: &cancellable)
    }
    
    func viewForAnnotation(annotation: MKAnnotation, mapView: MKMapView) -> MKAnnotationView? {
        guard let annotation = annotation as? DFRS else {
            return nil
        }
        
        let annotationView = annotation.view(on: mapView)
        annotationView.canShowCallout = false;
        annotationView.isEnabled = false;
        annotationView.accessibilityLabel = "DFRS Annotation \(annotation.stationNumber ?? "")";
        return annotationView;
    }
    
    func items(at location: CLLocationCoordinate2D, mapView: MKMapView) -> [DataSource]? {
        if mapView.zoomLevel < minZoom {
            return nil
        }
        guard let mapState = mapState, let showDFRS = mapState.showDFRS, showDFRS else {
            return nil
        }
        let screenPercentage = 0.03
        let tolerance = mapView.region.span.longitudeDelta * Double(screenPercentage)
        let minLon = location.longitude - tolerance
        let maxLon = location.longitude + tolerance
        let minLat = location.latitude - tolerance
        let maxLat = location.latitude + tolerance
        
        let fetchRequest: NSFetchRequest<DFRS>
        fetchRequest = DFRS.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(
            format: "(rxPosition != nil AND rxLatitude >= %lf AND rxLatitude <= %lf AND rxLongitude >= %lf AND rxLongitude <= %lf) OR (txPosition != nil AND txLatitude >= %lf AND txLatitude <= %lf AND txLongitude >= %lf AND txLongitude <= %lf)", minLat, maxLat, minLon, maxLon, minLat, maxLat, minLon, maxLon
        )
        
        let context = PersistenceController.shared.container.viewContext
        return try? context.fetch(fetchRequest)
    }
    
    func focus(dfrs: DFRS) {
        mapState?.center = MKCoordinateRegion(center: dfrs.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
    }
}

class DFRSAnnotationView: MKAnnotationView {
    static let ReuseID = DFRS.key
    
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
