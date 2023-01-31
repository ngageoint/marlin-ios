//
//  SearchResultsMap.swift
//  Marlin
//
//  Created by Daniel Barela on 10/10/22.
//

import Foundation
import MapKit
import Combine
import SwiftUI

class SearchResultAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var mapItem: MKMapItem
    
    var title: String? {
                "\(mapItem.name ?? "")\n\(mapItem.placemark.country ?? "")\n\(mapItem.placemark.ocean ?? "")"
    }
    
    var subtitle: String? {
        self.mapItem.placemark.title
    }
    
    init(mapItem: MKMapItem) {
        coordinate = mapItem.placemark.coordinate
        self.mapItem = mapItem
    }
    
}

class SearchResultsMap: NSObject, MapMixin {
    var cancellable = Set<AnyCancellable>()
    var annotations: [SearchResultAnnotation] = []
    
    func setupMixin(marlinMap: MarlinMap, mapView: MKMapView) {
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "placemark")

        marlinMap.mapState.$searchResults
            .sink { items in
                guard let items = items else {
                    return
                }
                
                mapView.removeAnnotations(self.annotations)
                
                self.annotations = items.map { item in
                    SearchResultAnnotation(mapItem: item)
                }
                
                mapView.addAnnotations(self.annotations)
            }
            .store(in: &cancellable)
        // TODO: this seems like the wrong place for this
        let region = UserDefaults.standard.mapRegion
        if CLLocationCoordinate2DIsValid(region.center) {
            if MKUserTrackingMode(rawValue: marlinMap.mapState.userTrackingMode) ?? MKUserTrackingMode.none == .none {
                DispatchQueue.main.async {
                    marlinMap.mapState.center = region
                }
            }
        } else {
            DispatchQueue.main.async {
                marlinMap.mapState.center = MKCoordinateRegion(center: mapView.centerCoordinate, zoom: 4, bounds: UIScreen.main.bounds)
            }
        }
    }
    
    func regionDidChange(mapView: MKMapView, animated: Bool) {
        UserDefaults.standard.mapRegion = mapView.region
    }
    
    func viewForAnnotation(annotation: MKAnnotation, mapView: MKMapView) -> MKAnnotationView? {
        if let annotation = annotation as? SearchResultAnnotation {
            let mapItem = annotation.mapItem
            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "placemark", for: annotation) as? MKMarkerAnnotationView {
                annotationView.isEnabled = true
                annotationView.markerTintColor = Color.primaryUIColor
                if let category = mapItem.pointOfInterestCategory {
                    switch (category) {
                    case .airport:
                        annotationView.glyphImage = UIImage(systemName: "airplane")
                    case .amusementPark:
                        annotationView.glyphImage = UIImage(systemName: "hands.sparkles.fill")
                    case .aquarium:
                        annotationView.glyphImage = UIImage(systemName: "drop.fill")
                    case .atm, .bank:
                        annotationView.glyphImage = UIImage(systemName: "dollarsign.circle.fill")
                    case .beach:
                        annotationView.glyphImage = UIImage(systemName: "sun.dust.fill")
                    case .bakery, .brewery, .cafe, .foodMarket, .restaurant:
                        annotationView.glyphImage = UIImage(systemName: "fork.knife")
                    default:
                        annotationView.glyphImage = UIImage(systemName: "mappin")
                    }
                } else {
                    annotationView.glyphImage = UIImage(systemName: "mappin")
                }
                return annotationView
            }
        }
        return nil
    }
}
