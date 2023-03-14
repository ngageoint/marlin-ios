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

class BaseOverlaysMap: NSObject, MapMixin {
    var mapState: MapState?
    var controller: NSFetchedResultsController<MapLayer>?
    var lastChange: Date?

    var fetchRequest: NSFetchRequest<MapLayer> {
        let fetchRequest = MapLayer.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \MapLayer.order, ascending: false)]
        return fetchRequest
    }
    
    func setupMixin(marlinMap: MarlinMap, mapView: MKMapView) {
        mapState = marlinMap.mapState
        controller = PersistenceController.current.fetchedResultsController(fetchRequest: fetchRequest,
                                                                            sectionNameKeyPath: nil,
                                                                            cacheName: nil)
        controller?.delegate = self
        try? controller?.performFetch()
    }
    
    func updateMixin(mapView: MKMapView, mapState: MapState) {
        if lastChange == nil || lastChange != mapState.mixinStates["\(String(describing: BaseOverlaysMap.self))DataUpdated"] as? Date {
            lastChange = mapState.mixinStates["\(String(describing: BaseOverlaysMap.self))DataUpdated"] as? Date
            let mapLayers = PersistenceController.current.viewContext.fetch(request: fetchRequest) ?? []
                        
            for layer in mapLayers {
                let addedLayer = mapView.overlays.first { overlay in
                    if let overlay = overlay as? WMSTileOverlay {
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
                    mapView.insertOverlay(WMSTileOverlay(mapLayer: layer), at: index)
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
