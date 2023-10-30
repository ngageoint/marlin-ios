//
//  AllRoutesMixin.swift
//  Marlin
//
//  Created by Daniel Barela on 10/9/23.
//

import Foundation
import Combine
import MapKit

class AllRoutesMixin: MapMixin {
    var uuid: UUID = UUID()
    var mapState: MapState?
    var cancellable = Set<AnyCancellable>()
    
    var currentLines: [MKGeodesicPolyline] = []
    
    var viewModel: RoutesViewModel
    
    init(repository: (any RouteRepository)) {
        self.viewModel = RoutesViewModel()
        self.viewModel.repository = repository
        self.viewModel.fetchRoutes()
    }
    
    func setupMixin(mapState: MapState, mapView: MKMapView) {
        self.mapState = mapState
        viewModel.$routes
            .receive(on: RunLoop.main)
            .sink() { [weak self] routes in
                self?.refreshLine()
            }
            .store(in: &cancellable)
    }
    
    func removeMixin(mapView: MKMapView, mapState: MapState) {
        mapView.removeOverlays(currentLines)
        currentLines = []
    }
    
    func refreshLine() {
        DispatchQueue.main.async {
            self.mapState?.mixinStates["\(String(describing: AllRoutesMixin.self))DataUpdated"] = Date()
        }
    }
    
    func updateMixin(mapView: MKMapView, mapState: MapState) {
        mapView.removeOverlays(currentLines)
        currentLines = []
        
        if UserDefaults.standard.showOnMaproute {
            for route in viewModel.routes {
                if let line = route.mkLine {
                    currentLines.append(line)
                }
            }
            mapView.addOverlays(currentLines)
        }
    }
    
    func items(at location: CLLocationCoordinate2D, mapView: MKMapView, touchPoint: CGPoint) -> [DataSource]? {
        guard UserDefaults.standard.showOnMaproute == true else {
            return nil
        }
        var matched: [RouteModel] = []
        let screenPercentage = 0.03
        let distanceTolerance = mapView.visibleMapRect.size.width * Double(screenPercentage)
        let longitudeTolerance = mapView.region.span.longitudeDelta * Double(screenPercentage)

        for route in viewModel.routes {
            if let line = route.mkLine, lineHitTest(line: line, location: location, distanceTolerance: distanceTolerance) {
                matched.append(route)
            }
        }
        return matched
    }
}
