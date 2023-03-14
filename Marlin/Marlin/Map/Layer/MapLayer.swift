//
//  MapLayer.swift
//  Marlin
//
//  Created by Daniel Barela on 2/27/23.
//

import Foundation
import SwiftUI
import CoreData

class MapLayer: NSManagedObject {
    
    static func createFrom(viewModel: NewMapLayerViewModel, context: NSManagedObjectContext) -> MapLayer {
        let layer = MapLayer(context: context)
        layer.name = viewModel.name
        layer.url = viewModel.urlTemplate
        layer.refreshRate = Int64(viewModel.refreshRate)
        layer.displayName = viewModel.displayName
        layer.username = viewModel.username
        layer.password = viewModel.password
        layer.maxZoom = Int64(viewModel.maximumZoom)
        layer.minZoom = Int64(viewModel.minimumZoom)
        layer.type = viewModel.layerType.rawValue
        layer.visible = true
        layer.order = Int64((try? context.countOfObjects(MapLayer.self)) ?? 0)
        return layer
    }
    
    func toggleShow() {
        self.visible = !self.visible
        try? self.managedObjectContext?.save()
    }

    var showOnMap: Bool {
        get { self.visible }
        set {
            print("changing value to \(newValue)")
            self.visible = newValue
            do {
                try self.managedObjectContext?.save()
            } catch {
                print("error \(error)")
            }
        }
    }
    
    
    
}
