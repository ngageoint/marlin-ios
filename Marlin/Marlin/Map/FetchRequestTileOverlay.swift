//
//  LightTileOverlay.swift
//  Marlin
//
//  Created by Daniel Barela on 7/12/22.
//

import Foundation
import MapKit
import CoreData

protocol FetchRequestBasedTileOverlay {
    associatedtype T where T : NSManagedObject
    var fetchRequest: NSFetchRequest<T>? { get set }
}

struct MapBoundingBox {
    var swCorner: (x: Double, y: Double)
    var neCorner: (x: Double, y: Double)
}

class FetchRequestTileOverlay<T : NSManagedObject & MapImage>: MKTileOverlay, FetchRequestBasedTileOverlay {
    var fetchRequest: NSFetchRequest<T>?
    var zoomLevel: Int = 0
    
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

    convenience init(fetchRequest: NSFetchRequest<T>?) {
        self.init()
        self.fetchRequest = fetchRequest
    }
    
    override func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void) {
        zoomLevel = path.z
        
        let minTileLon = longitude(x: path.x, zoom: path.z)
        let maxTileLon = longitude(x: path.x+1, zoom: path.z)
        let minTileLat = latitude(y: path.y+1, zoom: path.z)
        let maxTileLat = latitude(y: path.y, zoom: path.z)
        let neCorner3857 = coord4326To3857(longitude: maxTileLon, latitude: maxTileLat)
        let swCorner3857 = coord4326To3857(longitude: minTileLon, latitude: minTileLat)
        let nwCorner3857 = coord4326To3857(longitude: minTileLon, latitude: maxTileLat)
        let seCorner3857 = coord4326To3857(longitude: maxTileLon, latitude: minTileLat)
        let minTileX = swCorner3857.x
        let minTileY = swCorner3857.y
        let maxTileX = neCorner3857.x
        let maxTileY = neCorner3857.y
        
        // border the tile by 20 miles since that is as far as any light i have seen.  if that is wrong, update
        // border has to be at least 30 pixels as well
        // miles to meters = miles * 1609.344
        let tolerance = max(30.0 * 1609.344, ((maxTileX - minTileX) / self.tileSize.width) * 30)
        
        let neCornerTolerance = coord3857To4326(y: maxTileY + tolerance, x: maxTileX + tolerance)
        let swCornerTolerance = coord3857To4326(y: minTileY - tolerance, x: minTileX - tolerance)
        
        DispatchQueue.main.async { [self] in
            drawTile(tileBounds3857: MapBoundingBox(swCorner: swCorner3857, neCorner: neCorner3857), queryBounds: MapBoundingBox(swCorner: (x: swCornerTolerance.lon, y: swCornerTolerance.lat), neCorner: (x: neCornerTolerance.lon, y: neCornerTolerance.lat)), result: result)
        }
    }
    
    func drawTile(tileBounds3857: MapBoundingBox, queryBounds: MapBoundingBox, result: @escaping (Data?, Error?) -> Void) {
        guard let fetchRequest = fetchRequest else {
            let data = clearImage.pngData()
            result(data ?? Data(), nil)
            return
        }
        
        let tileFetchRequest = T.fetchRequest()
        tileFetchRequest.sortDescriptors = fetchRequest.sortDescriptors
        
        let boundsPredicate = NSPredicate(
            format: "latitude >= %lf AND latitude <= %lf AND longitude >= %lf AND longitude <= %lf", queryBounds.swCorner.y, queryBounds.neCorner.y, queryBounds.swCorner.x, queryBounds.neCorner.x
        )
        
        if let predicate = fetchRequest.predicate {
            tileFetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, boundsPredicate])
        } else {
            tileFetchRequest.predicate = boundsPredicate
        }
                
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.automaticallyMergesChangesFromParent = false
        context.parent = PersistenceController.shared.container.viewContext
        let objects = try? context.fetch(tileFetchRequest)
        
        UIGraphicsBeginImageContext(self.tileSize)
        
        if objects == nil || objects?.count == 0 {
            let rect = CGRect(origin: .zero, size: self.tileSize)
            let layer = CALayer()
            layer.frame = rect
            layer.backgroundColor = UIColor.clear.cgColor
//            layer.borderColor = UIColor.red.cgColor
//            layer.borderWidth = 5
            UIGraphicsBeginImageContext(layer.bounds.size)
            layer.render(in: UIGraphicsGetCurrentContext()!)
        }
        
        
        if let objects = objects as? [MapImage] {
            for object in objects {
                // xxx here
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
        UIGraphicsEndImageContext()
        guard let cgImage = newImage.cgImage else {
            result(self.clearImage.pngData() ?? Data(), nil)
            return
        }
        let data = UIImage(cgImage: cgImage).pngData()
        result(data ?? Data(), nil)
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
