//
//  UserLayersMap.swift
//  Marlin
//
//  Created by Daniel Barela on 3/17/23.
//

import Foundation
import MapKit
import SwiftUI
import CoreData
import Combine

class UserLayersMap: MapMixin {
    var viewModel: MapLayersViewModel = MapLayersViewModel()
    var overlays: [MKTileOverlay] = []
    
    var mapState: MapState?
    var lastChange: Date?
    var cancellable = Set<AnyCancellable>()
   
    func setupMixin(marlinMap: MarlinMap, mapView: MKMapView) {
        mapState = marlinMap.mapState
        viewModel.$layers
            .receive(on: RunLoop.main)
            .sink() { [weak self] layers in
                self?.refresh()
            }
            .store(in: &cancellable)
    }
    
    func refresh() {
        DispatchQueue.main.async {
            self.mapState?.mixinStates["\(String(describing: UserLayersMap.self))DataUpdated"] = Date()
        }
    }
    
    func updateMixin(mapView: MKMapView, mapState: MapState) {
        if lastChange == nil || lastChange != mapState.mixinStates["\(String(describing: UserLayersMap.self))DataUpdated"] as? Date {
            lastChange = mapState.mixinStates["\(String(describing: UserLayersMap.self))DataUpdated"] as? Date ?? Date()
            
            if mapState.mixinStates["\(String(describing: UserLayersMap.self))DataUpdated"] as? Date == nil {
                DispatchQueue.main.async {
                    mapState.mixinStates["\(String(describing: UserLayersMap.self))DataUpdated"] = self.lastChange
                }
            }
            
            for overlay in self.overlays {
                mapView.removeOverlay(overlay)
            }

            for (index, layer) in viewModel.layers.reversed().enumerated() {
                if layer.showOnMap {
                    var overlay: MKTileOverlay?
                    if layer.type == LayerType.wms.rawValue {
                        overlay = WMSTileOverlay(mapLayer: layer)
                    } else if layer.type == LayerType.xyz.rawValue || layer.type == LayerType.tms.rawValue {
                        overlay = XYZTileOverlay(mapLayer: layer)
                    }
                    
                    if let overlay = overlay {
                        mapView.insertOverlay(overlay, at: index)
                        overlays.append(overlay)
                    }
                }
            }
        }
    }
}
