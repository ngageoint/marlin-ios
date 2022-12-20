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
    associatedtype T where T : MapImage
    var predicate: NSPredicate? { get set }
}

struct MapBoundingBox {
    var swCorner: (x: Double, y: Double)
    var neCorner: (x: Double, y: Double)
}

class PredicateTileOverlay<T : MapImage>: MKTileOverlay, PredicateBasedTileOverlay {
    var predicate: NSPredicate?
    var sortDescriptors: [NSSortDescriptor]?
    var objects: [T]?
    var zoomLevel: Int = 0
    var imageCache: Kingfisher.ImageCache?
    
    var clearImage: UIImage {
        let rect = CGRect(origin: CGPoint(x: 0, y:0), size: CGSize(width: 1, height: 1))
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        
        context.setFillColor(UIColor.clear.cgColor)
        context.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }

    convenience init(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]? = nil, objects: [T]? = nil, imageCache: Kingfisher.ImageCache? = nil) {
        self.init()
        self.predicate = predicate
        self.sortDescriptors = sortDescriptors
        self.objects = objects
        self.imageCache = imageCache
    }
    
    override func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void) {
        
        let options: KingfisherOptionsInfo? = T.cacheTiles ? (imageCache != nil ? [.targetCache(imageCache!)] : nil) : [.forceRefresh]
                
        KingfisherManager.shared.retrieveImage(with: .provider(DataSourceTileProvider<T>(path: path, predicate: predicate, sortDescriptors: sortDescriptors, objects: objects, tileSize: tileSize)), options: options) { imageResult in
            switch imageResult {
            case .success(let value):
                result(value.image.pngData(), nil)
                
            case .failure(_):
                break
            }
        }
    }
}
