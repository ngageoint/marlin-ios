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
        layer.name = viewModel.fileName
        layer.url = viewModel.url
        layer.refreshRate = Int64(viewModel.refreshRate)
        layer.displayName = viewModel.displayName
        layer.username = viewModel.username
        layer.password = viewModel.password
        layer.maxZoom = Int64(viewModel.maximumZoom)
        layer.minZoom = Int64(viewModel.minimumZoom)
        layer.type = viewModel.layerType.rawValue
        layer.visible = viewModel.visible
        layer.order = Int64((try? context.countOfObjects(MapLayer.self)) ?? 0)
        layer.layers = viewModel.layers.joined(separator: ",")
        layer.minLatitude = viewModel.minLatitude
        layer.maxLatitude = viewModel.maxLatitude
        layer.minLongitude = viewModel.minLongitude
        layer.maxLongitude = viewModel.maxLongitude
        layer.urlParameters = viewModel.urlParameters
        return layer
    }
    
    func update(viewModel: MapLayerViewModel, context: NSManagedObjectContext) {
        self.name = viewModel.fileName
        self.url = viewModel.url
        self.refreshRate = Int64(viewModel.refreshRate)
        self.displayName = viewModel.displayName
        self.username = viewModel.username
        self.password = viewModel.password
        self.maxZoom = Int64(viewModel.maximumZoom)
        self.minZoom = Int64(viewModel.minimumZoom)
        self.type = viewModel.layerType.rawValue
        self.visible = viewModel.visible
        self.layers = viewModel.layers.joined(separator: ",")
        self.minLatitude = viewModel.minLatitude
        self.maxLatitude = viewModel.maxLatitude
        self.minLongitude = viewModel.minLongitude
        self.maxLongitude = viewModel.maxLongitude
        self.urlParameters = viewModel.urlParameters
    }
    
    func toggleShow() {
        self.visible = !self.visible
        try? self.managedObjectContext?.save()
    }
    
    var urlTemplate: String? {
        guard let url = url, !url.isEmpty else {
            return nil
        }
        
        if type == LayerType.wms.rawValue {
            let urlParamString = urlParameters?.map({ (key: String, value: String) in
                "\(key)=\(value)"
            }).joined(separator: "&") ?? ""
            
            return "\(url)?\(urlParamString)"
        } else if type == LayerType.xyz.rawValue || type == LayerType.tms.rawValue {
            guard !url.isEmpty else {
                return nil
            }
            return "\(url)/{z}/{x}/{y}.png"
        }
        return nil
    }

    var showOnMap: Bool {
        get { self.visible }
        set {
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
            return URL(string: urlString)?.host
        }
        return nil
    }
    
    var layerNames: [String] {
        guard let layers = layers else {
            return []
        }
        return layers.components(separatedBy: ",")
    }
    
    var boundingBoxDisplay: String {
        return "(\(minLatitude.latitudeDisplay), \(minLongitude.longitudeDisplay)) - (\(maxLatitude.latitudeDisplay), \(maxLongitude.longitudeDisplay))"
    }
    
}
