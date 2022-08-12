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
        if path.z < 8 {
            let rect = CGRect(origin: .zero, size: self.tileSize)
            let layer = CALayer()
            layer.frame = rect
            layer.backgroundColor = UIColor.clear.cgColor

            UIGraphicsBeginImageContext(layer.bounds.size)
            layer.render(in: UIGraphicsGetCurrentContext()!)

            let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            guard let cgImage = newImage.cgImage else {
                result(clearImage.pngData(), nil)
                return
            }
            let data = UIImage(cgImage: cgImage).pngData()

            result(data, nil)
            return
        }
        UIGraphicsBeginImageContext(self.tileSize)

        let minTileLon = longitude(x: path.x, zoom: path.z)
        let maxTileLon = longitude(x: path.x+1, zoom: path.z)
        let minTileLat = latitude(y: path.y+1, zoom: path.z)
        let maxTileLat = latitude(y: path.y, zoom: path.z)
        
        let minQueryLon = longitude(x: path.x-1, zoom: path.z)
        let maxQueryLon = longitude(x: path.x+2, zoom: path.z)
        let minQueryLat = latitude(y: path.y+2, zoom: path.z)
        let maxQueryLat = latitude(y: path.y-1, zoom: path.z)
        
        let fetchRequest: NSFetchRequest<Light>
        fetchRequest = Light.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(
            format: "latitude >= %lf AND latitude <= %lf AND longitude >= %lf AND longitude <= %lf", minQueryLat, maxQueryLat, minQueryLon, maxQueryLon
        )
        
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.automaticallyMergesChangesFromParent = false
        context.parent = PersistenceController.shared.container.viewContext
        let objects = try? context.fetch(fetchRequest)
        
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
                    let xPosition = (((object.longitude - minTileLon) / (maxTileLon - minTileLon)) * self.tileSize.width)
                    let yPosition = self.tileSize.height - (((object.latitude - minTileLat) / (maxTileLat - minTileLat)) * self.tileSize.height)
                    mapImage.draw(in: CGRect(x: (xPosition - (mapImage.size.width / 2)), y: (yPosition - (mapImage.size.height / 2)), width: mapImage.size.width, height: mapImage.size.height))
                }
            }
        }
        
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        guard let cgImage = newImage.cgImage else {
            result(clearImage.pngData(), nil)
            return
        }
        let data = UIImage(cgImage: cgImage).pngData()
        
        result(data, nil)
    }
    
    func longitude(x: Int, zoom: Int) -> Double {
        return Double(x) / pow(2.0, Double(zoom)) * 360.0 - 180.0
    }
    
    func latitude(y: Int, zoom: Int) -> Double {
        let n = Double.pi - 2.0 * Double.pi * Double(y) / pow(2.0, Double(zoom))
        return 180.0 / Double.pi * atan(0.5 * (exp(n) - exp(-n)))
    }
}
