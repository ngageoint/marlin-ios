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
    
    @discardableResult
    static func safeDeleteGeoPackage(name: String) -> Bool {
        if let mapLayers = try? PersistenceController.shared.viewContext.fetchObjects(
            MapLayer.self,
            predicate: NSPredicate(format: "name = %@ AND type = %@", name, LayerType.geopackage.rawValue)
        ) {
            if mapLayers.isEmpty {
                // safe to delete the geopackage
                return GeoPackage.shared.deleteGeoPackage(name: name)
            }
        }
        return false
    }
    
    static func createFrom(viewModel: MapLayerViewModel, context: NSManagedObjectContext) -> MapLayer {
        let layer = MapLayer(context: context)
        layer.name = viewModel.fileName
        layer.url = viewModel.plainUrl
        layer.refreshRate = Int64(viewModel.refreshRate)
        layer.displayName = viewModel.displayName
        layer.username = viewModel.username
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
        
        if viewModel.password != "" {
            Keychain().addOrUpdate(
                server: layer.url ?? "",
                credentials: Credentials(username: viewModel.username, password: viewModel.password)
            )
        }
        return layer
    }
    
    func update(viewModel: MapLayerViewModel, context: NSManagedObjectContext) {
        self.name = viewModel.fileName
        self.url = viewModel.plainUrl
        self.refreshRate = Int64(viewModel.refreshRate)
        self.displayName = viewModel.displayName
        self.username = viewModel.username
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
        
        if viewModel.password != "" {
            Keychain().addOrUpdate(
                server: url ?? "",
                credentials: Credentials(username: viewModel.username, password: viewModel.password)
            )
        }
    }
    
    func toggleShow() {
        self.visible = !self.visible
        try? self.managedObjectContext?.save()
    }
    
    var password: String? {
        if self.username != "", 
            let credentials = Keychain().getCredentials(server: self.url ?? "", account: self.username ?? ""
        ) {
            return credentials.password
        }
        return nil
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
            if let urlParameters = urlParameters, !urlParameters.isEmpty {
                let urlParamString = urlParameters.map({ (key: String, value: String) in
                    "\(key)=\(value)"
                }).joined(separator: "&")
                return "\(url)/{z}/{x}/{y}.png?\(urlParamString)"
            } else {
                return "\(url)/{z}/{x}/{y}.png"
            }
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
        return """
            (\(minLatitude.latitudeDisplay), \(minLongitude.longitudeDisplay)) \
            - (\(maxLatitude.latitudeDisplay), \(maxLongitude.longitudeDisplay))
        """
    }
    
}
