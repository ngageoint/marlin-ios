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
                    case .atm:
                        annotationView.glyphImage = UIImage(systemName: "dollarsign.circle.fill")
                    case .bakery:
                        annotationView.glyphImage = UIImage(systemName: "fork.knife")
                    case .bank:
                        annotationView.glyphImage = UIImage(systemName: "dollarsign.circle.fill")
                    case .beach:
                        annotationView.glyphImage = UIImage(systemName: "sun.dust.fill")
                    case .brewery:
                        annotationView.glyphImage = UIImage(systemName: "fork.knife")
                    case .cafe:
                        annotationView.glyphImage = UIImage(systemName: "fork.knife")
                    case .campground:
                        annotationView.glyphImage = UIImage(systemName: "mappin")
                    case .carRental:
                        annotationView.glyphImage = UIImage(systemName: "mappin")
                    case .evCharger:
                        annotationView.glyphImage = UIImage(systemName: "mappin")
                    case .fireStation:
                        annotationView.glyphImage = UIImage(systemName: "mappin")
                    case .fitnessCenter:
                        annotationView.glyphImage = UIImage(systemName: "mappin")
                    case .foodMarket:
                        annotationView.glyphImage = UIImage(systemName: "fork.knife")
                    case .gasStation:
                        annotationView.glyphImage = UIImage(systemName: "mappin")
                    case .hospital:
                        annotationView.glyphImage = UIImage(systemName: "mappin")
                    case .hotel:
                        annotationView.glyphImage = UIImage(systemName: "mappin")
                    case .laundry:
                        annotationView.glyphImage = UIImage(systemName: "mappin")
                    case .library:
                        annotationView.glyphImage = UIImage(systemName: "mappin")
                    case .marina:
                        annotationView.glyphImage = UIImage(systemName: "mappin")
                    case .movieTheater:
                        annotationView.glyphImage = UIImage(systemName: "mappin")
                    case .museum:
                        annotationView.glyphImage = UIImage(systemName: "mappin")
                    case .nationalPark:
                        annotationView.glyphImage = UIImage(systemName: "mappin")
                    case .nightlife:
                        annotationView.glyphImage = UIImage(systemName: "mappin")
                    case .park:
                        annotationView.glyphImage = UIImage(systemName: "mappin")
                    case .parking:
                        annotationView.glyphImage = UIImage(systemName: "mappin")
                    case .pharmacy:
                        annotationView.glyphImage = UIImage(systemName: "mappin")
                    case .police:
                        annotationView.glyphImage = UIImage(systemName: "mappin")
                    case .postOffice:
                        annotationView.glyphImage = UIImage(systemName: "mappin")
                    case .publicTransport:
                        annotationView.glyphImage = UIImage(systemName: "mappin")
                    case .restaurant:
                        annotationView.glyphImage = UIImage(systemName: "fork.knife")
                    case .restroom:
                        annotationView.glyphImage = UIImage(systemName: "mappin")
                    case .school:
                        annotationView.glyphImage = UIImage(systemName: "mappin")
                    case .stadium:
                        annotationView.glyphImage = UIImage(systemName: "mappin")
                    case .store:
                        annotationView.glyphImage = UIImage(systemName: "mappin")
                    case .theater:
                        annotationView.glyphImage = UIImage(systemName: "mappin")
                    case .university:
                        annotationView.glyphImage = UIImage(systemName: "mappin")
                    case .winery:
                        annotationView.glyphImage = UIImage(systemName: "mappin")
                    case .zoo:
                        annotationView.glyphImage = UIImage(systemName: "mappin")
                    default:
                        annotationView.glyphImage = UIImage(systemName: "mappin")
                    }
                }
                return annotationView
            }
        }
        return nil
    }
}
