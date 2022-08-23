//
//  PersistedMapState.swift
//  Marlin
//
//  Created by Daniel Barela on 7/14/22.
//

import Foundation
import MapKit

class PersistedMapState: NSObject, MapMixin {
    
    func updateMixin(mapView: MKMapView, marlinMap: MarlinMap) {
        
    }
    
    func setupMixin(marlinMap: MarlinMap, mapView: MKMapView) {
        let region = UserDefaults.standard.mapRegion
        if CLLocationCoordinate2DIsValid(region.center) {
            marlinMap.mapState.center = region
        }
    }
    
    func regionDidChange(mapView: MKMapView, animated: Bool) {
        UserDefaults.standard.mapRegion = mapView.region
    }

}
