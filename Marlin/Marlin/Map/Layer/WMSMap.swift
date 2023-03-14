//
//  WMSMap.swift
//  Marlin
//
//  Created by Daniel Barela on 3/6/23.
//

import Foundation
import MapKit
import SwiftUI
import Combine

class WMSMap: NSObject, MapMixin {
    var cancellable = Set<AnyCancellable>()

    var viewModel: NewMapLayerViewModel
    var wmsOverlay: WMSTileOverlay?
    var mapState: MapState?
    
    init(viewModel: NewMapLayerViewModel) {
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
    }
    
    func refreshOverlay(marlinMap: MarlinMap) {
        DispatchQueue.main.async {
            if let wmsOverlay = self.wmsOverlay {
                marlinMap.mapState.overlays.removeAll { overlay in
                    if let overlay = overlay as? MKTileOverlay {
                        return overlay == wmsOverlay
                    }
                    return false
                }
            }
            
            guard let _ = self.viewModel.urlTemplate, let capabilities = self.viewModel.capabilities, !capabilities.selectedLayers.isEmpty else {
                print("xxx url is nil, returning")
                return
            }

            self.wmsOverlay = WMSTileOverlay(layer: self.viewModel)
            // insert at the correct spots
            if let wmsOverlay = self.wmsOverlay {
                marlinMap.mapState.overlays.insert(wmsOverlay, at: 0)
            }
        }
    }
}
