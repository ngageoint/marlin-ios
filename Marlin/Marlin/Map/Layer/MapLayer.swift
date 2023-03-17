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
    
    static func createFrom(viewModel: MapLayerViewModel, context: NSManagedObjectContext) -> MapLayer {
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
    
    var host: String? {
        guard let urlString = url else {
            return nil
        }
        
        if type == LayerType.wms.rawValue {
            return URL(string: urlString)?.host
        } else if type == LayerType.xyz.rawValue || type == LayerType.tms.rawValue {
            let currentURL = url?.replacingOccurrences(of: "{x}", with: "0").replacingOccurrences(of: "{y}", with: "0").replacingOccurrences(of: "{z}", with: "0") ?? ""
            return URL(string: currentURL)?.host
        }
        return nil
    }
    
}
