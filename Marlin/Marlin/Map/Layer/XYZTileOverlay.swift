//
//  XYZTileOverlay.swift
//  Marlin
//
//  Created by Daniel Barela on 3/14/23.
//

import Foundation
import MapKit
import Alamofire
import Combine

class XYZTileOverlay: MKTileOverlay {
    var cancellable = Set<AnyCancellable>()
    
    var layer: MapLayerViewModel?
    var mapLayer: MapLayer?
    var tms: Bool = false
    
    init(layer: MapLayerViewModel) {
        self.layer = layer
        super.init(urlTemplate: layer.urlTemplate)
        tileSize = CGSize(width: 512, height: 512)
        if layer.layerType == .tms {
            tms = true
        }
        self.minimumZ = layer.minimumZoom
        self.maximumZ = layer.maximumZoom
    }
    
    init(mapLayer: MapLayer) {
        self.mapLayer = mapLayer
        super.init(urlTemplate: "\(mapLayer.url ?? "")/{z}/{x}/{y}.png")
        tileSize = CGSize(width: 512, height: 512)
        if mapLayer.type == LayerType.tms.rawValue {
            tms = true
        }
        self.minimumZ = Int(mapLayer.minZoom)
        self.maximumZ = Int(mapLayer.maxZoom)
    }
    
    override func url(forTilePath path: MKTileOverlayPath) -> URL {
        if tms {
            let flippedY: NSDecimalNumber = NSDecimalNumber(decimal: pow(2.0, path.z) - 1.0 - (1.0 * Decimal(path.y)))
            return super.url(forTilePath: MKTileOverlayPath(x: path.x, y: flippedY.intValue, z: path.z, contentScaleFactor: path.contentScaleFactor))
        }
        return super.url(forTilePath: path)
    }
    
    override func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void) {
        let url = url(forTilePath: path)
        var headers: HTTPHeaders = [:]
        if let layer = layer, let username = layer.username, let password = layer.password {
            headers.add(.authorization(username: username, password: password))
        }
        URLCache.shared.removeAllCachedResponses()
        MSI.shared.capabilitiesSession.request(url, method: .get, headers: headers)
            .publishData()
            .sink { response in
                result(response.data, response.error)
            }
            .store(in: &cancellable)
    }
}
