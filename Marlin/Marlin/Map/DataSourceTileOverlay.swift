//
//  DataSourceTileOverlay.swift
//  Marlin
//
//  Created by Daniel Barela on 7/12/22.
//

import Foundation
import MapKit
import CoreData
import Kingfisher
import sf_proj_ios
import sf_ios

class MapBoundingBox: Codable, ObservableObject {
    @Published var swCorner: (x: Double, y: Double)
    @Published var neCorner: (x: Double, y: Double)
    
    enum CodingKeys: String, CodingKey {
        case swCornerX
        case swCornerY
        case neCornerX
        case neCornerY
    }
    
    init(swCorner: (x: Double, y: Double), neCorner: (x: Double, y: Double)) {
        self.swCorner = swCorner
        self.neCorner = neCorner
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let swCornerX = try values.decode(Double.self, forKey: .swCornerX)
        let swCornerY = try values.decode(Double.self, forKey: .swCornerY)
        swCorner = (x: swCornerX, y: swCornerY)
        
        let neCornerX = try values.decode(Double.self, forKey: .neCornerX)
        let neCornerY = try values.decode(Double.self, forKey: .neCornerY)
        neCorner = (x: neCornerX, y: neCornerY)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(swCorner.x, forKey: .swCornerX)
        try container.encode(swCorner.y, forKey: .swCornerY)
        try container.encode(neCorner.x, forKey: .neCornerX)
        try container.encode(neCorner.y, forKey: .neCornerY)
    }
    
    var swCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: swCorner.y, longitude: swCorner.x)
    }
    
    var seCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: swCorner.y, longitude: neCorner.x)
    }
    
    var neCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: neCorner.y, longitude: neCorner.x)
    }
    
    var nwCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: neCorner.y, longitude: swCorner.x)
    }
}

protocol DataSourceOverlay {
    var key: String? { get set }
}

class DataSourceTileOverlay: MKTileOverlay, DataSourceOverlay {
    var key: String?
    let tileRepository: TileRepository

    init(tileRepository: TileRepository, key: String) {
        self.tileRepository = tileRepository
        self.key = key
        super.init(urlTemplate: nil)
    }

    override func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void) {
        let options: KingfisherOptionsInfo? = 
        (tileRepository.cacheSourceKey != nil && tileRepository.imageCache != nil) ?
         [.targetCache(tileRepository.imageCache!)] : [.forceRefresh]

        KingfisherManager.shared.retrieveImage(
            with: .provider(
                DataSourceTileProvider(
                    tileRepository: tileRepository,
                    path: path
                )
            ),
            options: options
        ) { imageResult in
            switch imageResult {
            case .success(let value):
                result(value.image.pngData(), nil)

            case .failure:
                break
            }
        }
    }
}
