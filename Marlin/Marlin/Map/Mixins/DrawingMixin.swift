//
//  DrawingMixin.swift
//  Marlin
//
//  Created by Daniel Barela on 3/6/24.
//

import Foundation
import MapKit

class DrawingMixin: NSObject, MapMixin {
    var uuid: UUID = UUID()

    func setupMixin(mapState: MapState, mapView: MKMapView) {

    }
    
    func removeMixin(mapView: MKMapView, mapState: MapState) {

    }
    
    func mapLongPress(mapView: MKMapView, coordinate: CLLocationCoordinate2D) {
        // put a marker on the map and then do a query for where they long pressed
        // this should show a bottom sheet which will provide actions:
        // save as user point, measure, create route, draw more points
        // if while drawing, the center of the map is close to a marlin feature
        // it will snap to that feature
    }
}
