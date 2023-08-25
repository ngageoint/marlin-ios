//
//  LocationBoundsMixin.swift
//  Marlin
//
//  Created by Daniel Barela on 7/20/23.
//

import Foundation
import MapKit
import Combine
import SwiftUI

// just a class to key off of for drawing
class BoundsPolygon: MKPolygon {
    
}

class LocationBoundsMixin: NSObject, MapMixin, ObservableObject {
    var uuid: UUID = UUID()
    var mapState: MapState?
    var lastChange: Date?
    var cancellable = Set<AnyCancellable>()
    var polygon: MKPolygon?
    
    @Binding var region: MKCoordinateRegion
    
    @Binding var coordinateOne: ObservableCoordinate
    @Binding var coordinateTwo: ObservableCoordinate
    
    init(region: Binding<MKCoordinateRegion>, coordinateOne: Binding<ObservableCoordinate>, coordinateTwo: Binding<ObservableCoordinate>) {
        _region = region
        _coordinateOne = coordinateOne
        _coordinateTwo = coordinateTwo
    }

    func regionDidChange(mapView: MKMapView, animated: Bool) {
        self.triggerUpdate()
        region = mapView.region
    }
    
    func triggerUpdate() {
        DispatchQueue.main.async {
            self.mapState?.mixinStates["\(String(describing: LocationBoundsMixin.self))DataUpdated"] = Date()
        }
    }

    func setupMixin(mapState: MapState, mapView: MKMapView) {
        self.mapState = mapState
        coordinateOne.$latitude
            .receive(on: RunLoop.main)
            .sink() { [self] neCorner in
                self.triggerUpdate()
            }
            .store(in: &cancellable)
        coordinateOne.$longitude
            .receive(on: RunLoop.main)
            .sink() { [self] neCorner in
                self.triggerUpdate()
            }
            .store(in: &cancellable)
        coordinateTwo.$latitude
            .receive(on: RunLoop.main)
            .sink() { [self] neCorner in
                self.triggerUpdate()
            }
            .store(in: &cancellable)
        coordinateTwo.$longitude
            .receive(on: RunLoop.main)
            .sink() { [self] neCorner in
                self.triggerUpdate()
            }
            .store(in: &cancellable)
        triggerUpdate()
    }
    
    func removeMixin(mapView: MKMapView, mapState: MapState) {
        if let polygon = polygon {
            mapView.removeOverlay(polygon)
        }
    }
    
    func updateMixin(mapView: MKMapView, mapState: MapState) {
        if lastChange == nil || lastChange != mapState.mixinStates["\(String(describing: LocationBoundsMixin.self))DataUpdated"] as? Date {
            lastChange = mapState.mixinStates["\(String(describing: LocationBoundsMixin.self))DataUpdated"] as? Date ?? Date()
            
            if mapState.mixinStates["\(String(describing: LocationBoundsMixin.self))DataUpdated"] as? Date == nil {
                DispatchQueue.main.async {
                    mapState.mixinStates["\(String(describing: LocationBoundsMixin.self))DataUpdated"] = self.lastChange
                }
            }
            if let polygon = polygon {
                mapView.removeOverlay(polygon)
            }
            var points: [MKMapPoint] = []
            
            if let cornerOneLat = coordinateOne.latitude, let cornerOneLong = coordinateOne.longitude {
                points.append(MKMapPoint(CLLocationCoordinate2D(latitude: cornerOneLat, longitude: cornerOneLong)))
                if let cornerTwoLat = coordinateTwo.latitude, let cornerTwoLong = coordinateTwo.longitude {
                    points.append(MKMapPoint(CLLocationCoordinate2D(latitude: cornerOneLat, longitude: cornerTwoLong)))
                    points.append(MKMapPoint(CLLocationCoordinate2D(latitude: cornerTwoLat, longitude: cornerTwoLong)))
                    points.append(MKMapPoint(CLLocationCoordinate2D(latitude: cornerTwoLat, longitude: cornerOneLong)))
                } else {
                    points.append(MKMapPoint(CLLocationCoordinate2D(latitude: mapView.region.center.latitude, longitude: cornerOneLong)))
                    points.append(MKMapPoint(mapView.region.center))
                    points.append(MKMapPoint(CLLocationCoordinate2D(latitude: cornerOneLat, longitude: mapView.region.center.longitude)))
                }
            } else if let cornerTwoLat = coordinateTwo.latitude, let cornerTwoLong = coordinateTwo.longitude {
                points.append(MKMapPoint(CLLocationCoordinate2D(latitude: cornerTwoLat, longitude: cornerTwoLong)))
                points.append(MKMapPoint(CLLocationCoordinate2D(latitude: mapView.region.center.latitude, longitude: cornerTwoLong)))
                points.append(MKMapPoint(mapView.region.center))
                points.append(MKMapPoint(CLLocationCoordinate2D(latitude: cornerTwoLat, longitude: mapView.region.center.longitude)))
                
            } else {
                return
            }
            let polygon = BoundsPolygon(points: &points, count: points.count)
            mapView.addOverlay(polygon)
            self.polygon = polygon
        }
    }
    
    func renderer(overlay: MKOverlay) -> MKOverlayRenderer? {
        if let polygon = overlay as? BoundsPolygon {
            let renderer = MKPolygonRenderer(polygon: polygon)
            renderer.strokeColor = .red.withAlphaComponent(0.87)
            renderer.lineWidth = 2
            renderer.fillColor = .red.withAlphaComponent(0.2)
            return renderer
        }
        return nil
    }
}
