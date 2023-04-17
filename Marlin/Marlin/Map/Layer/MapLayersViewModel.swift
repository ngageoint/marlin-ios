//
//  MapLayersViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 2/27/23.
//

import Foundation
import SwiftUI
import CoreData

class MapLayersViewModel: NSObject, ObservableObject {
    @Published var layers: [MapLayer] = []
    var controller: NSFetchedResultsController<MapLayer>?
    
    var fetchRequest: NSFetchRequest<MapLayer> {
        let fetchRequest = MapLayer.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \MapLayer.order, ascending: true)]
        return fetchRequest
    }
    
    override init() {
        super.init()
        controller = PersistenceController.current.fetchedResultsController(fetchRequest: fetchRequest,
                                                                            sectionNameKeyPath: nil,
                                                                            cacheName: nil)
        controller?.delegate = self
        updateLayers()
    }
    
    func updateLayers() {
        try? controller?.performFetch()
        self.layers = controller?.fetchedObjects ?? []
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
        
        var geopackagesToMaybeDelete: [String] = []
        
        PersistenceController.current.viewContext.performAndWait {
            _ = layersToDelete.compactMap { layer in
                if layer.type == LayerType.geopackage.rawValue, let fileName = layer.name {
                    geopackagesToMaybeDelete.append(fileName)
                }
                PersistenceController.current.viewContext.delete(layer)
            }
            try? PersistenceController.current.viewContext.save()
        }
        
        // check the deleted layers and delete their geopackages if necessary
        for geopackageToMaybeDelete in geopackagesToMaybeDelete {
            MapLayer.safeDeleteGeoPackage(name: geopackageToMaybeDelete)
        }
    }
}

extension MapLayersViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateLayers()
    }
}
