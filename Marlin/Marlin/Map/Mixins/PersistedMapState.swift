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
    
    func setupMixin(mapView: MKMapView, marlinMap: MarlinMap) {
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
