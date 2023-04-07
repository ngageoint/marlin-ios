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
    var viewModel: MapLayerViewModel
    var overlays: [MKTileOverlay] = []
    
    var mapState: MapState?
    var lastChange: Date?
    var cancellable = Set<AnyCancellable>()
    
    init(viewModel: MapLayerViewModel) {
        self.viewModel = viewModel
    }
    func setupMixin(marlinMap: MarlinMap, mapView: MKMapView) {
        mapState = marlinMap.mapState
        viewModel.$urlTemplate
            .receive(on: RunLoop.main)
            .sink() { [weak self] urlTemplate in
                self?.refreshOverlay(marlinMap: marlinMap)
            }
            .store(in: &cancellable)
        viewModel.$layerType
            .receive(on: RunLoop.main)
            .sink() { [weak self] urlTemplate in
                self?.refreshOverlay(marlinMap: marlinMap)
            }
            .store(in: &cancellable)
        viewModel.$selectedFileLayers
            .receive(on: RunLoop.main)
            .sink() { [weak self] urlTemplate in
                self?.refreshOverlay(marlinMap: marlinMap)
            }
            .store(in: &cancellable)
    }
    
    func refreshOverlay(marlinMap: MarlinMap) {
        DispatchQueue.main.async {
            self.mapState?.mixinStates["\(String(describing: BaseOverlaysMap.self))DataUpdated"] = Date()
        }
    }
    
    func updateMixin(mapView: MKMapView, mapState: MapState) {
        if lastChange == nil || lastChange != mapState.mixinStates["\(String(describing: BaseOverlaysMap.self))DataUpdated"] as? Date {
            lastChange = mapState.mixinStates["\(String(describing: BaseOverlaysMap.self))DataUpdated"] as? Date ?? Date()
            
            if mapState.mixinStates["\(String(describing: BaseOverlaysMap.self))DataUpdated"] as? Date == nil {
                DispatchQueue.main.async {
                    mapState.mixinStates["\(String(describing: BaseOverlaysMap.self))DataUpdated"] = self.lastChange
                }
            }
            
            for overlay in self.overlays {
                mapView.removeOverlay(overlay)
            }

            var overlay: MKTileOverlay?
            if viewModel.layerType == .wms {
                guard let _ = viewModel.urlTemplate else {
                    return
                }
                overlay = WMSTileOverlay(layer: viewModel)
            } else if viewModel.layerType == .xyz || viewModel.layerType == .tms {
                guard let _ = viewModel.urlTemplate else {
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
}
