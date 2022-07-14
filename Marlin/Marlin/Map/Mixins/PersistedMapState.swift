//
//  PersistedMapState.swift
//  Marlin
//
//  Created by Daniel Barela on 7/14/22.
//

import Foundation
import MapKit

class PersistedMapState: NSObject, MapMixin {
    var mapView: MKMapView?
    
//    @AppStorage("mapRegion") var mapRegion: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), latitudinalMeters: 20000, longitudinalMeters: 20000)
    
    func setupMixin(mapView: MKMapView, marlinMap: MarlinMap, scheme: MarlinScheme?) {
        self.mapView = mapView
        let region = UserDefaults.standard.mapRegion
        if CLLocationCoordinate2DIsValid(region.center) {
            mapView.region = region
        }
    }
    
    func regionDidChange(mapView: MKMapView, animated: Bool) {
        UserDefaults.standard.mapRegion = mapView.region
    }

}
