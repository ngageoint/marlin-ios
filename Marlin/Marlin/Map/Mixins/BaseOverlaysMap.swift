//
//  BaseOverlaysMap.swift
//  Marlin
//
//  Created by Daniel Barela on 3/9/23.
//

import Foundation
import MapKit
import SwiftUI
import CoreData
import Combine

class BaseOverlaysMap: NSObject, MapMixin {
    var uuid: UUID = UUID()
    var viewModel: MapLayerViewModel
    var overlays: [MKTileOverlay] = []
    
    var mapState: MapState?
    var lastChange: Date?
    var cancellable = Set<AnyCancellable>()
    
    init(viewModel: MapLayerViewModel) {
        self.viewModel = viewModel
    }
    func setupMixin(mapState: MapState, mapView: MKMapView) {
        self.mapState = mapState
        viewModel.$url
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.refreshOverlay(mapState: mapState)
            }
            .store(in: &cancellable)
        viewModel.$layerType
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.refreshOverlay(mapState: mapState)
            }
            .store(in: &cancellable)
        viewModel.$selectedLayers
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.refreshOverlay(mapState: mapState)
            }
            .store(in: &cancellable)
    }
    
    func refreshOverlay(mapState: MapState) {
        DispatchQueue.main.async {
            self.mapState?.mixinStates["\(String(describing: BaseOverlaysMap.self))DataUpdated"] = Date()
        }
    }
    
    func updateMixin(mapView: MKMapView, mapState: MapState) {
        if lastChange == nil 
            || lastChange != mapState.mixinStates["\(String(describing: BaseOverlaysMap.self))DataUpdated"] as? Date {
            lastChange = 
            mapState.mixinStates["\(String(describing: BaseOverlaysMap.self))DataUpdated"] as? Date ?? Date()

            if mapState.mixinStates["\(String(describing: BaseOverlaysMap.self))DataUpdated"] as? Date == nil {
                DispatchQueue.main.async {
                    mapState.mixinStates["\(String(describing: BaseOverlaysMap.self))DataUpdated"] = self.lastChange
                }
            }
            
            mapView.removeOverlays(self.overlays)

            var overlay: MKTileOverlay?
            if viewModel.layerType == .wms {
                guard viewModel.urlTemplate != nil else {
                    return
                }
                overlay = WMSTileOverlay(layer: viewModel)
            } else if viewModel.layerType == .xyz || viewModel.layerType == .tms {
                guard viewModel.urlTemplate != nil else {
                    return
                }
                overlay = XYZTileOverlay(layer: viewModel)
            } else if viewModel.layerType == .geopackage {
                overlay = GeopackageCompositeOverlay(layer: viewModel)
            }
            if let overlay = overlay {
                overlays.append(overlay)
                mapView.insertOverlay(overlay, at: 0)
            }
        }
    }
    
    func removeMixin(mapView: MKMapView, mapState: MapState) {
        mapView.removeOverlays(overlays)
    }
}
