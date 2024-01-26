//
//  LightTileOverlay.swift
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

protocol PredicateBasedTileOverlay {
    associatedtype MapImageType where MapImageType: MapImage
    var predicate: NSPredicate? { get set }
    var key: String? { get set }
}

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

class PredicateTileOverlay<MapImageType: MapImage>: MKTileOverlay, PredicateBasedTileOverlay {
    var predicate: NSPredicate?
    var sortDescriptors: [NSSortDescriptor]?
    var objects: [MapImageType]?
    var zoomLevel: Int = 0
    var imageCache: Kingfisher.ImageCache?
    var key: String?
    var boundingPredicate: ((Double, Double, Double, Double) -> NSPredicate)?
    
    var clearImage: UIImage {
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 1, height: 1))
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        
        context.setFillColor(UIColor.clear.cgColor)
        context.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }

    convenience init(
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor]? = nil,
        boundingPredicate: @escaping (Double, Double, Double, Double) -> NSPredicate,
        objects: [MapImageType]? = nil,
        imageCache: Kingfisher.ImageCache? = nil) {
        self.init()
        self.predicate = predicate
        self.sortDescriptors = sortDescriptors
        self.objects = objects
        self.imageCache = imageCache
        self.key = MapImageType.key
        self.boundingPredicate = boundingPredicate
    }
    
    override func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void) {
        
        let options: KingfisherOptionsInfo? = MapImageType.cacheTiles ?
        (imageCache != nil ?
         [.targetCache(imageCache!)] : nil) : [.forceRefresh]

        guard let boundingPredicate = boundingPredicate else {
            return
        }
        KingfisherManager.shared.retrieveImage(
            with: .provider(DataSourceTileProvider<MapImageType>(
                path: path,
                predicate: predicate,
                sortDescriptors: sortDescriptors,
                boundingPredicate: boundingPredicate,
                objects: objects,
                tileSize: tileSize)),
            options: options) { imageResult in
            switch imageResult {
            case .success(let value):
                result(value.image.pngData(), nil)
                
            case .failure:
                break
            }
        }
    }
}

class DataSourceTileOverlay: MKTileOverlay {
    let tileRepository: TileRepository

    init(tileRepository: TileRepository) {
        self.tileRepository = tileRepository
        super.init(urlTemplate: nil)
    }

    override func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void) {
        let options: KingfisherOptionsInfo? = 
        (tileRepository.cacheSourceKey != nil && tileRepository.imageCache != nil) ?
         [.targetCache(tileRepository.imageCache!)] : [.forceRefresh]

        KingfisherManager.shared.retrieveImage(
            with: .provider(
                DataSourceTileProvider2(
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
