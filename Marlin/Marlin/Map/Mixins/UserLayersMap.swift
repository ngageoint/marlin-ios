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
    var uuid: UUID = UUID()
    var viewModel: MapLayersViewModel = MapLayersViewModel()
    var overlays: [MKTileOverlay] = []
    
    var mapState: MapState?
    var lastChange: Date?
    var cancellable = Set<AnyCancellable>()
   
    func setupMixin(mapState: MapState, mapView: MKMapView) {
        self.mapState = mapState
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

            for (index, layer) in viewModel.layers.reversed().enumerated() where layer.showOnMap {
                var overlay: MKTileOverlay?
                if layer.type == LayerType.wms.rawValue {
                    overlay = WMSTileOverlay(mapLayer: layer)
                } else if layer.type == LayerType.xyz.rawValue || layer.type == LayerType.tms.rawValue {
                    overlay = XYZTileOverlay(mapLayer: layer)
                } else if layer.type == LayerType.geopackage.rawValue {
                    overlay = GeopackageCompositeOverlay(mapLayer: layer)
                }

                if let overlay = overlay {
                    mapView.insertOverlay(overlay, at: index)
                    overlays.append(overlay)
                }
            }
        }
    }
    
    func removeMixin(mapView: MKMapView, mapState: MapState) {
        for overlay in self.overlays {
            mapView.removeOverlay(overlay)
        }
    }
    
    func items(at location: CLLocationCoordinate2D, mapView: MKMapView, touchPoint: CGPoint) -> [DataSource]? {
        var featureItems: [GeoPackageFeatureItem] = []
        for layer in viewModel.layers.reversed() where layer.showOnMap {
            if layer.type == LayerType.geopackage.rawValue {
                if let geoPackageName = layer.name {
                    for table in layer.layerNames {
                        featureItems.append(
                            contentsOf: GeoPackage.shared.getFeaturesFromTable(
                                at: location,
                                mapView: mapView,
                                table: table,
                                geoPackageName: geoPackageName,
                                layerName: layer.displayName ?? "GeoPackage Layer"))
                    }
                }
            }
        }
        return featureItems
    }

}
