//
//  PortMap.swift
//  Marlin
//
//  Created by Daniel Barela on 8/23/22.
//

import Foundation
import MapKit
import CoreData
import Combine

class PortMap: NSObject, MapMixin {
    var minZoom = 4
    var mapState: MapState?
    var cancellable = Set<AnyCancellable>()
    
    var showPortsAsTiles: Bool = true
    var fetchRequest: NSFetchRequest<Port>?
    var portOverlay: FetchRequestTileOverlay<Port>?
    
    public init(fetchRequest: NSFetchRequest<Port>? = nil, showPortsAsTiles: Bool = true) {
        self.fetchRequest = fetchRequest
        self.showPortsAsTiles = showPortsAsTiles
    }
    
    func getFetchRequest(mapState: MapState) -> NSFetchRequest<Port> {
        if let showPorts = mapState.showPorts, showPorts == true {
            let fetchRequest = self.fetchRequest ?? Port.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Port.portNumber, ascending: true)]
            return fetchRequest
        } else {
            let nilFetchRequest = Port.fetchRequest()
            nilFetchRequest.predicate = NSPredicate(value: false)
            nilFetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Port.portNumber, ascending: true)]
            return nilFetchRequest
        }
    }
    
    func setupMixin(marlinMap: MarlinMap, mapView: MKMapView) {
        mapState = marlinMap.mapState
        mapView.register(PortAnnotationView.self, forAnnotationViewWithReuseIdentifier: PortAnnotationView.ReuseID)
        
        NotificationCenter.default.publisher(for: .FocusPort)
            .compactMap {
                $0.object as? Port
            }
            .sink(receiveValue: { [weak self] in
                self?.focusPort(port: $0)
            })
            .store(in: &cancellable)
        
        UserDefaults.standard
            .publisher(for: \.showOnMapport)
            .removeDuplicates()
            .handleEvents(receiveOutput: { show in
                print("Show Ports: \(show)")
            })
            .sink() { [weak self] in
                marlinMap.mapState.showPorts = $0
                if let showPortsAsTiles = self?.showPortsAsTiles, showPortsAsTiles {
                    if let portOverlay = self?.portOverlay {
                        marlinMap.mapState.overlays.removeAll { overlay in
                            if let overlay = overlay as? FetchRequestTileOverlay<Port> {
                                return overlay == portOverlay
                            }
                            return false
                        }
                    }
                    let newFetchRequest = self?.getFetchRequest(mapState: marlinMap.mapState)
                    let newOverlay = FetchRequestTileOverlay<Port>()
                    
                    newOverlay.tileSize = CGSize(width: 512, height: 512)
                    newOverlay.minimumZ = self?.minZoom ?? 0
                    newOverlay.fetchRequest = newFetchRequest
                    self?.portOverlay = newOverlay
                    marlinMap.mapState.overlays.append(newOverlay)
                } else {
                    marlinMap.mapState.fetchRequests[Light.key] = self?.getFetchRequest(mapState: marlinMap.mapState) as? NSFetchRequest<NSFetchRequestResult>
                }
            }
            .store(in: &cancellable)
    }
    
    func viewForAnnotation(annotation: MKAnnotation, mapView: MKMapView) -> MKAnnotationView? {
        guard let portAnnotation = annotation as? Port else {
            return nil
        }
        
        let annotationView = portAnnotation.view(on: mapView)
        annotationView.canShowCallout = false;
        annotationView.isEnabled = false;
        annotationView.accessibilityLabel = "Port Annotation \(portAnnotation.portNumber)";
        return annotationView;
    }
    
    func items(at location: CLLocationCoordinate2D, mapView: MKMapView) -> [DataSource]? {
        if let portOverlay = portOverlay, portOverlay.zoomLevel < minZoom {
            return nil
        }
        let screenPercentage = 0.03
        let tolerance = mapView.region.span.longitudeDelta * Double(screenPercentage)
        let minLon = location.longitude - tolerance
        let maxLon = location.longitude + tolerance
        let minLat = location.latitude - tolerance
        let maxLat = location.latitude + tolerance
        
        let fetchRequest: NSFetchRequest<Port>
        fetchRequest = Port.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(
            format: "latitude >= %lf AND latitude <= %lf AND longitude >= %lf AND longitude <= %lf", minLat, maxLat, minLon, maxLon
        )
        
        let context = PersistenceController.shared.container.viewContext
        return try? context.fetch(fetchRequest)
    }
    
    func focusPort(port: Port) {
        mapState?.center = MKCoordinateRegion(center: port.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
    }
}

class PortAnnotationView: MKAnnotationView {
    static let ReuseID = "port"
    
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
