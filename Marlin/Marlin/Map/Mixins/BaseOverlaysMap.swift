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
    var viewModel: MapLayerViewModel?
    var overlay: MKTileOverlay?
    
    var mapState: MapState?
    var controller: NSFetchedResultsController<MapLayer>?
    var lastChange: Date?
    var cancellable = Set<AnyCancellable>()
    
    init(viewModel: MapLayerViewModel? = nil) {
        self.viewModel = viewModel
    }

    var fetchRequest: NSFetchRequest<MapLayer> {
        let fetchRequest = MapLayer.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \MapLayer.order, ascending: false)]
        return fetchRequest
    }
    
    func setupMixin(marlinMap: MarlinMap, mapView: MKMapView) {
        mapState = marlinMap.mapState
        if let viewModel = self.viewModel {
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
        } else {
            controller = PersistenceController.current.fetchedResultsController(fetchRequest: fetchRequest,
                                                                                sectionNameKeyPath: nil,
                                                                                cacheName: nil)
            controller?.delegate = self
            try? controller?.performFetch()
        }
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
                        
            if let viewModel = self.viewModel {
                if let overlay = self.overlay {
                    mapView.removeOverlay(overlay)
                }
                
                guard let _ = viewModel.urlTemplate else {
                    return
                }
                if viewModel.layerType == .wms {
                    self.overlay = WMSTileOverlay(layer: viewModel)
                } else if viewModel.layerType != .unknown {
                    self.overlay = XYZTileOverlay(layer: viewModel)
                }
                if let overlay = self.overlay {
                    mapView.insertOverlay(overlay, at: 0)
                }
            } else {
                let mapLayers = PersistenceController.current.viewContext.fetch(request: fetchRequest) ?? []
                
                for layer in mapLayers {
                    let addedLayer = mapView.overlays.first { overlay in
                        if layer.type == LayerType.wms.rawValue, let overlay = overlay as? WMSTileOverlay {
                            return overlay.urlTemplate == layer.url
                        } else if layer.type != LayerType.unknown.rawValue, let overlay = overlay as? XYZTileOverlay {
                            return overlay.urlTemplate == layer.url
                        }
                        return false
                    }
                    
                    if let addedLayer = addedLayer {
                        mapView.removeOverlay(addedLayer)
                    }
                }
                for (index, layer) in mapLayers.enumerated() {
                    if layer.showOnMap {
                        if layer.type == LayerType.wms.rawValue {
                            mapView.insertOverlay(WMSTileOverlay(mapLayer: layer), at: index)
                        }
                    }
                }
            }
        }
    }
}

extension BaseOverlaysMap: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // this will trigger swiftUI to update the map and it has to go through that lifecycle
        mapState?.mixinStates["\(String(describing: BaseOverlaysMap.self))DataUpdated"] = Date()
    }
}
