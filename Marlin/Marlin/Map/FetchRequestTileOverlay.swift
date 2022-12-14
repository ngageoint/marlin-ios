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
        var cacheKey = "\(T.self.key)/\(path.z)/\(path.x)/\(path.y)"
        if let predicate = predicate {
            cacheKey = "\(cacheKey)/\(predicate.debugDescription)"
        }

        if T.cacheTiles, let imageCache = imageCache, imageCache.isCached(forKey: cacheKey) {
            
            imageCache.retrieveImage(forKey: cacheKey) { cacheResult in
                switch cacheResult {
                case .success(let value):
                    result(value.image?.pngData(), nil)
                    
                case .failure(let error):
                    print(error)
                }
            }
            return
        } else {
            print("Cache miss \(T.self.key)")
        }
        
        zoomLevel = path.z
        
        let minTileLon = longitude(x: path.x, zoom: path.z)
        let maxTileLon = longitude(x: path.x+1, zoom: path.z)
        let minTileLat = latitude(y: path.y+1, zoom: path.z)
        let maxTileLat = latitude(y: path.y, zoom: path.z)
        
        guard let neCorner3857 = SFGeometryUtils.degreesToMetersWith(x: maxTileLon, andY: maxTileLat),
                let swCorner3857 = SFGeometryUtils.degreesToMetersWith(x: minTileLon, andY: minTileLat) else {
            return
        }
        
        let minTileX = swCorner3857.x.doubleValue
        let minTileY = swCorner3857.y.doubleValue
        let maxTileX = neCorner3857.x.doubleValue
        let maxTileY = neCorner3857.y.doubleValue
        
        // border the tile by 40 miles since that is as far as any light i have seen.  if that is wrong, update
        // border has to be at least 30 pixels as well
        let nauticalMilesMeasurement = NSMeasurement(doubleValue: 40.0, unit: UnitLength.nauticalMiles)
        let metersMeasurement = nauticalMilesMeasurement.converting(to: UnitLength.meters).value

        let tolerance = max(metersMeasurement, ((maxTileY - minTileY) / self.tileSize.width) * 30.0)
        
        guard let neCornerTolerance = SFGeometryUtils.metersToDegreesWith(x: maxTileX + tolerance, andY: maxTileY + tolerance),
              let swCornerTolerance = SFGeometryUtils.metersToDegreesWith(x: minTileX - tolerance, andY:minTileY - tolerance) else {
            return
        }

        DispatchQueue.main.async { [self] in
            drawTile(tileBounds3857: MapBoundingBox(swCorner: (x: swCorner3857.x.doubleValue, y: swCorner3857.y.doubleValue), neCorner: (x: neCorner3857.x.doubleValue, y: neCorner3857.y.doubleValue)), queryBounds: MapBoundingBox(swCorner: (x: swCornerTolerance.x.doubleValue, y: swCornerTolerance.y.doubleValue), neCorner: (x: neCornerTolerance.x.doubleValue, y: neCornerTolerance.y.doubleValue)), cacheKey: cacheKey, result: result)
        }
    }
    
    func getMatchingObjects(predicate: NSPredicate) -> [T]? {
        if let objects = objects {

            let filteredObjects: [T] = objects.filter { object in
                return predicate.evaluate(with: object)
            }

            return filteredObjects
        }
        
        if let M = T.self as? NSManagedObject.Type {
            
            let tileFetchRequest = M.fetchRequest()
            tileFetchRequest.sortDescriptors = sortDescriptors
            
            tileFetchRequest.predicate = predicate
            
            let context = PersistenceController.current.mainQueueContext()
            let objects = try? context.fetch(tileFetchRequest)
            return objects as? [T]
        }
        
        return nil
    }
    
    func drawTile(tileBounds3857: MapBoundingBox, queryBounds: MapBoundingBox, cacheKey: String, result: @escaping (Data?, Error?) -> Void) {

        var boundsPredicate: NSPredicate?
        
        if queryBounds.swCorner.x < -180 {
            boundsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
                NSPredicate(format: "latitude >= %lf AND latitude <= %lf AND longitude >= %lf AND longitude <= %lf", queryBounds.swCorner.y, queryBounds.neCorner.y, -180.0, queryBounds.neCorner.x),
                NSPredicate(format: "latitude >= %lf AND latitude <= %lf AND longitude >= %lf AND longitude <= %lf", queryBounds.swCorner.y, queryBounds.neCorner.y, queryBounds.swCorner.x + 360.0, 180.0)
                ])
        } else if queryBounds.neCorner.x > 180 {
            boundsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
                NSPredicate(format: "latitude >= %lf AND latitude <= %lf AND longitude >= %lf AND longitude <= %lf", queryBounds.swCorner.y, queryBounds.neCorner.y, queryBounds.swCorner.x, 180.0),
                NSPredicate(format: "latitude >= %lf AND latitude <= %lf AND longitude >= %lf AND longitude <= %lf", queryBounds.swCorner.y, queryBounds.neCorner.y, -180.0, queryBounds.neCorner.x - 360.0)
            ])
        } else {
            boundsPredicate = NSPredicate(
                format: "latitude >= %lf AND latitude <= %lf AND longitude >= %lf AND longitude <= %lf", queryBounds.swCorner.y, queryBounds.neCorner.y, queryBounds.swCorner.x, queryBounds.neCorner.x
            )
        }
        
        guard let boundsPredicate = boundsPredicate else {
            return
        }
        
        var finalPredicate: NSPredicate = boundsPredicate
        
        if let predicate = predicate {
            finalPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, boundsPredicate])
        }
        
        let objects = getMatchingObjects(predicate: finalPredicate)
        if objects == nil || objects?.count == 0 {
            result(Data(), nil)
            return
        }
        
        UIGraphicsBeginImageContext(self.tileSize)

        if let objects = objects {
            for object in objects {
                let mapImages = object.mapImage(marker: false, zoomLevel: zoomLevel, tileBounds3857: tileBounds3857, context: UIGraphicsGetCurrentContext())
                for mapImage in mapImages {
                    let object3857Location = coord4326To3857(longitude: object.longitude, latitude: object.latitude)
                    let xPosition = (((object3857Location.x - tileBounds3857.swCorner.x) / (tileBounds3857.neCorner.x - tileBounds3857.swCorner.x)) * self.tileSize.width)
                    let yPosition = self.tileSize.height - (((object3857Location.y - tileBounds3857.swCorner.y) / (tileBounds3857.neCorner.y - tileBounds3857.swCorner.y)) * self.tileSize.height)
                    mapImage.draw(in: CGRect(x: (xPosition - (mapImage.size.width / 2)), y: (yPosition - (mapImage.size.height / 2)), width: mapImage.size.width, height: mapImage.size.height))
                }
            }
        }
        
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!

        if T.cacheTiles {
            imageCache?.store(newImage, forKey: cacheKey)
        }
        
        UIGraphicsEndImageContext()
        guard let cgImage = newImage.cgImage else {
            result(Data(), nil)
            return
        }
        let data = UIImage(cgImage: cgImage).pngData()
        result(data, nil)
    }
    
    func coord4326To3857(longitude: Double, latitude: Double) -> (x: Double, y: Double) {
        let a = 6378137.0
        let lambda = longitude / 180 * Double.pi;
        let phi = latitude / 180 * Double.pi;
        let x = a * lambda;
        let y = a * log(tan(Double.pi / 4 + phi / 2));
        
        return (x:x, y:y);
    }
    
    func coord3857To4326(y: Double, x: Double) -> (lat: Double, lon: Double) {
        let a = 6378137.0
        let d = -y / a
        let phi = Double.pi / 2 - 2 * atan(exp(d))
        let lambda = x / a
        let lat = phi / Double.pi * 180
        let lon = lambda / Double.pi * 180
        
        return (lat: lat, lon: lon)
    }
    
    func longitude(x: Int, zoom: Int) -> Double {
        return Double(x) / pow(2.0, Double(zoom)) * 360.0 - 180.0
    }
    
    func latitude(y: Int, zoom: Int) -> Double {
        let n = Double.pi - 2.0 * Double.pi * Double(y) / pow(2.0, Double(zoom))
        return 180.0 / Double.pi * atan(0.5 * (exp(n) - exp(-n)))
    }
}
