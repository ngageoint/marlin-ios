//
//  DrawingMixin.swift
//  Marlin
//
//  Created by Daniel Barela on 3/6/24.
//

import Foundation
import MapKit

class DrawingMixin: NSObject, MapMixin {
    let searchRepository: SearchRepository
    var uuid: UUID = UUID()
    var mapState: MapState?

    init(searchRepository: SearchRepository) {
        self.searchRepository = searchRepository
    }

    func setupMixin(mapState: MapState, mapView: MKMapView) {
        self.mapState = mapState
    }
    
    func removeMixin(mapView: MKMapView, mapState: MapState) {

    }
    
    func mapLongPress(mapView: MKMapView, coordinate: CLLocationCoordinate2D) {
        // put a marker on the map and then do a query for where they long pressed
        // this should show a bottom sheet which will provide actions:
        // save as user point, measure, create route, draw more points
        // if while drawing, the center of the map is close to a marlin feature
        // it will snap to that feature
        Task {
            let screenPercentage = 0.03
            let tolerance = await mapView.region.span.longitudeDelta * Double(screenPercentage)
            let minLon = coordinate.longitude - tolerance
            let maxLon = coordinate.longitude + tolerance
            let minLat = coordinate.latitude - tolerance
            let maxLat = coordinate.latitude + tolerance
            let results = await searchRepository.performSearchNear(
                region: MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(
                        latitudeDelta: maxLat - minLat,
                        longitudeDelta: maxLon - minLon
                    )
                ),
                zoom: mapView.zoomLevel
            )
            if let itemKeys = results?.map({ model in
                "\(model.id)"
            }) {
                await MainActor.run {
                    NotificationCenter.default.post(
                        name: .MapItemsTapped,
                        object: MapItemsTappedNotification(
                            itemKeys: [DataSources.search.key: itemKeys]
                        )
                    )
                }
            }
        }
    }
}
