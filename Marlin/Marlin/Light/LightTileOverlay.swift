//
//  LightTileOverlay.swift
//  Marlin
//
//  Created by Daniel Barela on 7/12/22.
//

import Foundation
import MapKit
import CoreData

class LightTileOverlay: MKTileOverlay {
    var zoomLevel: Int = 0
    var predicate: NSPredicate?
    
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
    
    override func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void) {
        zoomLevel = path.z
        DispatchQueue.main.async { [self] in

            let minTileLon = longitude(x: path.x, zoom: path.z)
            let maxTileLon = longitude(x: path.x+1, zoom: path.z)
            let minTileLat = latitude(y: path.y+1, zoom: path.z)
            let maxTileLat = latitude(y: path.y, zoom: path.z)
            let neCorner3857 = coord4326To3857(longitude: maxTileLon, latitude: maxTileLat)
            let swCorner3857 = coord4326To3857(longitude: minTileLon, latitude: minTileLat)
            let minTileX = swCorner3857.x
            let minTileY = swCorner3857.y
            let maxTileX = neCorner3857.x
            let maxTileY = neCorner3857.y

            // border the tile by 20 miles since that is as far as any light i have seen.  if that is wrong, update
            let tolerance = 20.0 * 1609.344 // miles to meters
            
            let neCornerTolerance = coord3857To4326(y: maxTileY + tolerance, x: maxTileX + tolerance)
            let swCornerTolerance = coord3857To4326(y: minTileY - tolerance, x: minTileX - tolerance)
            let minQueryLon = swCornerTolerance.lon
            let maxQueryLon = neCornerTolerance.lon
            let minQueryLat = swCornerTolerance.lat
            let maxQueryLat = neCornerTolerance.lat
            
            let fetchRequest: NSFetchRequest<Light>
            fetchRequest = Light.fetchRequest()
            
            if let predicate = predicate {
                fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, NSPredicate(
                    format: "latitude >= %lf AND latitude <= %lf AND longitude >= %lf AND longitude <= %lf", minQueryLat, maxQueryLat, minQueryLon, maxQueryLon
                )])
            } else {
                fetchRequest.predicate = NSPredicate(
                    format: "latitude >= %lf AND latitude <= %lf AND longitude >= %lf AND longitude <= %lf", minQueryLat, maxQueryLat, minQueryLon, maxQueryLon
                )
            }
            
                    
            let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            context.automaticallyMergesChangesFromParent = false
            context.parent = PersistenceController.shared.container.viewContext
            let objects = try? context.fetch(fetchRequest)
            print("xxx found \(objects?.count ?? 0) lights")

            UIGraphicsBeginImageContext(self.tileSize)

            if objects == nil || objects?.count == 0 {
                let rect = CGRect(origin: .zero, size: self.tileSize)
                let layer = CALayer()
                layer.frame = rect
                layer.backgroundColor = UIColor.clear.cgColor
                UIGraphicsBeginImageContext(layer.bounds.size)
                layer.render(in: UIGraphicsGetCurrentContext()!)
            }

        
            if let objects = objects {
                for object in objects {
                    let mapImages = object.mapImage(small: path.z < 13)
                    for mapImage in mapImages {
                        let object3857Locaton = coord4326To3857(longitude: object.longitude, latitude: object.latitude)
                        let xPosition = (((object3857Locaton.x - minTileX) / (maxTileX - minTileX)) * self.tileSize.width)
                        let yPosition = self.tileSize.height - (((object3857Locaton.y - minTileY) / (maxTileY - minTileY)) * self.tileSize.height)
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
