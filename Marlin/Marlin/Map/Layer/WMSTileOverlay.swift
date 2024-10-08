//
//  WMSTileOverlay.swift
//  Marlin
//
//  Created by Daniel Barela on 3/1/23.
//

import Foundation
import MapKit
import Alamofire
import Combine

class WMSTileOverlay: MKTileOverlay {
    var cancellable = Set<AnyCancellable>()

    var layer: MapLayerViewModel?
    var mapLayer: MapLayer?
    var username: String?
    var password: String?
    
    init(layer: MapLayerViewModel) {
        self.layer = layer
        super.init(urlTemplate: layer.urlTemplate)
        self.minimumZ = layer.minimumZoom
        self.maximumZ = layer.maximumZoom
        if !layer.username.isEmpty, !layer.password.isEmpty {
            username = layer.username
            password = layer.password
        }
    }
    
    init(mapLayer: MapLayer) {
        self.mapLayer = mapLayer
        super.init(urlTemplate: mapLayer.urlTemplate)
        self.minimumZ = Int(mapLayer.minZoom)
        self.maximumZ = Int(mapLayer.maxZoom)
        if let username = mapLayer.username, !username.isEmpty, let password = mapLayer.password {
            self.username = username
            self.password = password
        }
    }
    
    override func url(forTilePath path: MKTileOverlayPath) -> URL {
        let left = mercatorX(longitude: x(column: path.x, zoom: path.z))
        let right = mercatorX(longitude: x(column: path.x + 1, zoom: path.z))
        let bottom = mercatorY(latitude: y(row: path.y + 1, zoom: path.z))
        let top = mercatorY(latitude: y(row: path.y, zoom: path.z))
        return URL(string: "\(self.urlTemplate ?? "")&BBOX=\(left),\(bottom),\(right),\(top)")!
    }

    override func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void) {
        let url = url(forTilePath: path)
        var headers: HTTPHeaders = [:]
        if let username = username, let password = password {
            headers.add(.authorization(username: username, password: password))
        }
        MSI.shared.capabilitiesSession.request(url, method: .get, headers: headers)
            .publishData()
            .sink { response in
                result(response.data, response.error)
            }
            .store(in: &cancellable)
    }
    
    func mercatorX(longitude: Double) -> Double {
        return longitude * 20037508.34 / 180
    }
    
    func x(column: Int, zoom: Int) -> Double {
        return Double(column) / pow(2.0, Double(zoom)) * 360.0 - 180
    }
    
    func mercatorY(latitude: Double) -> Double {
        let y: Double = log(tan((90.0 + latitude) * .pi / 360.0)) / (.pi / 180.0)
        return y * 20037508.34 / 180
    }
    
    func y(row: Int, zoom: Int) -> Double {
        let yPosition: Double = .pi - 2.0 * .pi * Double(row) / pow(2.0, Double(zoom))
        return 180.0 / .pi * atan(0.5 * (exp(yPosition) - exp(-yPosition)))
    }
}
