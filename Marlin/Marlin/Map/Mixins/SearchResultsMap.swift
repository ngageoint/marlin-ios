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
    var model: SearchResultModel

    var title: String? {
        "\(model.displayName)\n\(model.address?.country ?? "")"
    }
    
    var subtitle: String? {
        nil
    }
    
    init(model: SearchResultModel) {
        coordinate = model.coordinate
        self.model = model
        super.init()
        self.accessibilityLabel = title
    }
    
}

class SearchResultsMap: NSObject, MapMixin {
    var uuid: UUID = UUID()
    var cancellable = Set<AnyCancellable>()
    var annotations: [SearchResultAnnotation] = []
    
    func setupMixin(mapState: MapState, mapView: MKMapView) {
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "placemark")

        mapState.$searchResults
            .sink { items in
                guard let items = items else {
                    return
                }
                
                mapView.removeAnnotations(self.annotations)
                
                self.annotations = items.map { item in
                    SearchResultAnnotation(model: item)
                }
                
                mapView.addAnnotations(self.annotations)
            }
            .store(in: &cancellable)
    }
    
    func removeMixin(mapView: MKMapView, mapState: MapState) {
        
    }

    func regionDidChange(mapView: MKMapView, animated: Bool, centerCoordinate: CLLocationCoordinate2D) {
        UserDefaults.standard.mapRegion = mapView.region
    }

    func viewForAnnotation(annotation: MKAnnotation, mapView: MKMapView) -> MKAnnotationView? {
        if let annotation = annotation as? SearchResultAnnotation {
//            let mapItem = annotation.mapItem
            if let annotationView = mapView.dequeueReusableAnnotationView(
                withIdentifier: "placemark", for: annotation
            ) as? MKMarkerAnnotationView {
                annotationView.isEnabled = true
                annotationView.markerTintColor = Color.primaryUIColor
//                if let category = mapItem.pointOfInterestCategory {
//                    switch category {
//                    case .airport:
//                        annotationView.glyphImage = UIImage(systemName: "airplane")
//                    case .amusementPark:
//                        annotationView.glyphImage = UIImage(systemName: "hands.sparkles.fill")
//                    case .aquarium:
//                        annotationView.glyphImage = UIImage(systemName: "drop.fill")
//                    case .atm, .bank:
//                        annotationView.glyphImage = UIImage(systemName: "dollarsign.circle.fill")
//                    case .beach:
//                        annotationView.glyphImage = UIImage(systemName: "sun.dust.fill")
//                    case .bakery, .brewery, .cafe, .foodMarket, .restaurant:
//                        annotationView.glyphImage = UIImage(systemName: "fork.knife")
//                    default:
//                        annotationView.glyphImage = UIImage(systemName: "mappin")
//                    }
//                } else {
                    annotationView.glyphImage = UIImage(systemName: "mappin")
//                }
                return annotationView
            }
        }
        return nil
    }
}
