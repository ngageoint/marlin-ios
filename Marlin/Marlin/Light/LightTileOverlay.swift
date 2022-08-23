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
                result(clearImage.pngData() ?? Data(), nil)
                return
            }
            let data = UIImage(cgImage: cgImage).pngData()
            result(data ?? Data(), nil)
        }
        DispatchQueue.main.async { [self] in

            let minTileLon = longitude(x: path.x, zoom: path.z)
            let maxTileLon = longitude(x: path.x+1, zoom: path.z)
            let minTileLat = latitude(y: path.y+1, zoom: path.z)
            let maxTileLat = latitude(y: path.y, zoom: path.z)
            let neCorner3857 = getCoordinatesInEPSG3857(longitudeInEPSG4326: maxTileLon, latitudeInEPSG4326: maxTileLat)
            let swCorner3857 = getCoordinatesInEPSG3857(longitudeInEPSG4326: minTileLon, latitudeInEPSG4326: minTileLat)
            let minTileX = swCorner3857.x
            let minTileY = swCorner3857.y
            let maxTileX = neCorner3857.x
            let maxTileY = neCorner3857.y

        
            let minQueryLon = longitude(x: path.x-1, zoom: path.z)
            let maxQueryLon = longitude(x: path.x+2, zoom: path.z)
            let minQueryLat = latitude(y: path.y+2, zoom: path.z)
            let maxQueryLat = latitude(y: path.y-1, zoom: path.z)
            
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
                        let object3857Locaton = getCoordinatesInEPSG3857(longitudeInEPSG4326: object.longitude, latitudeInEPSG4326: object.latitude)
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
    
    func getCoordinatesInEPSG3857(longitudeInEPSG4326: Double, latitudeInEPSG4326: Double) -> (x: Double, y: Double) {
        let longitudeInEPSG3857 = (longitudeInEPSG4326 * 20037508.34 / 180)
        let latitudeInEPSG3857 = (log(tan((90 + latitudeInEPSG4326) * Double.pi / 360)) / (Double.pi / 180)) * (20037508.34 / 180)
        
        return (longitudeInEPSG3857, latitudeInEPSG3857)
    }
    
    func longitude(x: Int, zoom: Int) -> Double {
        return Double(x) / pow(2.0, Double(zoom)) * 360.0 - 180.0
    }
    
    func latitude(y: Int, zoom: Int) -> Double {
        let n = Double.pi - 2.0 * Double.pi * Double(y) / pow(2.0, Double(zoom))
        return 180.0 / Double.pi * atan(0.5 * (exp(n) - exp(-n)))
    }
}
