//
//  MapLayersViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 2/27/23.
//

import Foundation
import SwiftUI

class MapLayersViewModel: ObservableObject {
    @Published var layers: [MapLayer] = []
    
    init(layers: [MapLayer]? = nil) {
        self.layers = (try? PersistenceController.current.viewContext.fetchObjects(MapLayer.self, sortBy: [NSSortDescriptor(keyPath: \MapLayer.order, ascending: true)])) ?? []
    }
    
    func updateLayers() {
        self.layers = (try? PersistenceController.current.viewContext.fetchObjects(MapLayer.self, sortBy: [NSSortDescriptor(keyPath: \MapLayer.order, ascending: true)])) ?? []
    }
    
    func toggleVisibility(of layer: MapLayer) -> Binding<Bool> {
        let binding = Binding<Bool>(get: { () -> Bool in
            return layer.visible
            
        }) { (newValue) in
            layer.showOnMap = newValue
        }
        return binding
    }
    
    func reorderLayers(fromOffsets source: IndexSet, toOffset destination: Int) {
        layers.move(fromOffsets: source, toOffset: destination)
        PersistenceController.current.viewContext.performAndWait {
            for (index, layer) in self.layers.enumerated() {
                layer.order = Int64(index)
            }
            try? PersistenceController.current.viewContext.save()
        }
        
    }
    
    func deleteLayers(offsets: IndexSet) {
        let layersToDelete = offsets.map { self.layers[$0] }
        
        PersistenceController.current.viewContext.performAndWait {
            _ = layersToDelete.compactMap { layer in
                PersistenceController.current.viewContext.delete(layer)
            }
            try? PersistenceController.current.viewContext.save()
        }
        
        layers.remove(atOffsets: offsets)
    }
}
