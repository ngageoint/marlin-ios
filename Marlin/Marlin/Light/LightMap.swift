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
    var mapState: MapState?
    var cancellable = Set<AnyCancellable>()
    
    var lights: [Light]?
    var showLightsAsTiles: Bool = true
    var fetchRequest: NSFetchRequest<Light>?
    var lightOverlay: LightTileOverlay?
    
    public init(fetchRequest: NSFetchRequest<Light>? = nil, showLightsAsTiles: Bool = true) {
        self.fetchRequest = fetchRequest
        self.showLightsAsTiles = showLightsAsTiles
    }
    
    func setupMixin(marlinMap: MarlinMap, mapView: MKMapView) {
        mapState = marlinMap.mapState
        mapState?.drawLightTiles = showLightsAsTiles
        mapView.register(LightAnnotationView.self, forAnnotationViewWithReuseIdentifier: LightAnnotationView.ReuseID)
        
        NotificationCenter.default.publisher(for: .FocusLight)
            .compactMap {
                $0.object as? Light
            }
            .sink(receiveValue: { [weak self] in
                self?.focusLight(light: $0)
            })
            .store(in: &cancellable)

        let fetchRequest = Light.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Light.featureNumber, ascending: true)]
        
        marlinMap.mapState.lightFetchRequest = fetchRequest
        
        UserDefaults.standard
            .publisher(for: \.showOnMaplight)
            .removeDuplicates()
            .handleEvents(receiveOutput: { show in
                print("Show Lights: \(show)")
            })
            .sink() { [weak self] in
                marlinMap.mapState.showLights = $0
            }
            .store(in: &cancellable)
    }
    
    func updateMixin(mapView: MKMapView, marlinMap: MarlinMap) {
        print("xxx update light map mixin")
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
        if let lightOverlay = lightOverlay, lightOverlay.zoomLevel < 8 {
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
