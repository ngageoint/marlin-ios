//
//  PersistedMapState.swift
//  Marlin
//
//  Created by Daniel Barela on 7/14/22.
//

import Foundation
import MapKit

class PersistedMapState: NSObject, MapMixin {
    var uuid: UUID = UUID()
    
    func setupMixin(mapState: MapState, mapView: MKMapView) {
        let region = UserDefaults.standard.mapRegion
        if CLLocationCoordinate2DIsValid(region.center) {
            if MKUserTrackingMode(rawValue: mapState.userTrackingMode) ?? MKUserTrackingMode.none == .none {
                DispatchQueue.main.async {
                    mapState.center = region
                }
            }
        } else {
            DispatchQueue.main.async {
                mapState.center = MKCoordinateRegion(center: mapView.centerCoordinate, zoom: 4, bounds: UIScreen.main.bounds)
            }
        }
    }
    
    func regionDidChange(mapView: MKMapView, animated: Bool) {
        UserDefaults.standard.mapRegion = mapView.region
    }

    func removeMixin(mapView: MKMapView, mapState: MapState) {
        
    }
}
