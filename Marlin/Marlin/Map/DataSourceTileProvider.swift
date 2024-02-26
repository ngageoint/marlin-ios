//
//  DataSourceTileProvider.swift
//  Marlin
//
//  Created by Daniel Barela on 12/19/22.
//

import Foundation
import Kingfisher
import CoreData
import MapKit
import sf_proj_ios
import sf_ios

enum DataTileError: Error {
    case zeroObjects
    case notFound
    case unexpected(code: Int)
}

extension DataTileError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .zeroObjects:
            return "There were no objects for this image."
        case .notFound:
            return "The specified item could not be found."
        case .unexpected:
            return "An unexpected error occurred."
        }
    }
}

extension DataTileError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .zeroObjects:
            return NSLocalizedString(
                "There were no objects for this image.",
                comment: "Zero Objects"
            )
        case .notFound:
            return NSLocalizedString(
                "The specified item could not be found.",
                comment: "Resource Not Found"
            )
        case .unexpected:
            return NSLocalizedString(
                "An unexpected error occurred.",
                comment: "Unexpected Error"
            )
        }
    }
}

struct DataSourceTileProvider2: ImageDataProvider {
    let tileRepository: TileRepository
    let path: MKTileOverlayPath
    var tileSize: CGSize = CGSize(width: 512, height: 512)

    var cacheKey: String {
        "\(tileRepository.cacheSourceKey ?? "_dc")/\(path.z)/\(path.x)/\(path.y)/\(tileRepository.filterCacheKey)"
    }

    func data(handler: @escaping (Result<Data, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let zoomLevel = path.z

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

            guard let neCornerTolerance = SFGeometryUtils.metersToDegreesWith(
                x: maxTileX + tolerance,
                andY: maxTileY + tolerance),
                  let swCornerTolerance = SFGeometryUtils.metersToDegreesWith(
                    x: minTileX - tolerance,
                    andY: minTileY - tolerance) else {
                return
            }

            drawTile(
                tileBounds3857: MapBoundingBox(
                    swCorner: (x: swCorner3857.x.doubleValue, y: swCorner3857.y.doubleValue),
                    neCorner: (x: neCorner3857.x.doubleValue, y: neCorner3857.y.doubleValue)),
                queryBounds: MapBoundingBox(
                    swCorner: (x: swCornerTolerance.x.doubleValue, y: swCornerTolerance.y.doubleValue),
                    neCorner: (x: neCornerTolerance.x.doubleValue, y: neCornerTolerance.y.doubleValue)),
                zoomLevel: zoomLevel,
                cacheKey: cacheKey,
                handler: handler)
        }
    }

    func drawTile(
        tileBounds3857: MapBoundingBox,
        queryBounds: MapBoundingBox,
        zoomLevel: Int,
        cacheKey: String,
        handler: @escaping (Result<Data, Error>) -> Void
    ) {

        Task {
            let items = await tileRepository.getTileableItems(
                minLatitude: queryBounds.swCorner.y,
                maxLatitude: queryBounds.neCorner.y,
                minLongitude: queryBounds.swCorner.x,
                maxLongitude: queryBounds.neCorner.x
            )

            UIGraphicsBeginImageContext(self.tileSize)

            items.forEach { dataSourceImage in
                dataSourceImage.image(
                    context: UIGraphicsGetCurrentContext(),
                    zoom: zoomLevel,
                    tileBounds: tileBounds3857,
                    tileSize: tileSize.width
                )
            }

            let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!

            UIGraphicsEndImageContext()

            guard let cgImage = newImage.cgImage else {
                handler(.failure(DataTileError.notFound))
                return
            }
            let data = UIImage(cgImage: cgImage).pngData()
            if let data = data {
                handler(.success(data))
            } else {
                handler(.failure(DataTileError.notFound))
            }
        }
    }

    func longitude(x: Int, zoom: Int) -> Double {
        return Double(x) / pow(2.0, Double(zoom)) * 360.0 - 180.0
    }

    func latitude(y: Int, zoom: Int) -> Double {
        let yLocation = Double.pi - 2.0 * Double.pi * Double(y) / pow(2.0, Double(zoom))
        return 180.0 / Double.pi * atan(0.5 * (exp(yLocation) - exp(-yLocation)))
    }
}

struct DataSourceTileProvider<T: MapImage>: ImageDataProvider {
    var cacheKey: String {
        var key = "\(T.self.key)/\(path.z)/\(path.x)/\(path.y)"
        if let predicate = predicate {
            key = "\(key)/\(predicate.debugDescription)"
        }
        return key
    }
    let predicate: NSPredicate?
    let sortDescriptors: [NSSortDescriptor]?
    let path: MKTileOverlayPath
    let tileSize: CGSize
    let objects: [T]?
    var boundingPredicate: ((Double, Double, Double, Double) -> NSPredicate)?
    
    init(
        path: MKTileOverlayPath,
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor]?,
        boundingPredicate: @escaping (Double, Double, Double, Double) -> NSPredicate,
        objects: [T]? = nil, tileSize: CGSize) {
        self.path = path
        self.predicate = predicate
        self.sortDescriptors = sortDescriptors
        self.tileSize = tileSize
        self.objects = objects
        self.boundingPredicate = boundingPredicate
    }
    
    func data(handler: @escaping (Result<Data, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let zoomLevel = path.z
            
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
            
            guard let neCornerTolerance = SFGeometryUtils.metersToDegreesWith(
                x: maxTileX + tolerance,
                andY: maxTileY + tolerance),
                  let swCornerTolerance = SFGeometryUtils.metersToDegreesWith(
                    x: minTileX - tolerance,
                    andY: minTileY - tolerance) else {
                return
            }
            
            drawTile(
                tileBounds3857: MapBoundingBox(
                    swCorner: (x: swCorner3857.x.doubleValue, y: swCorner3857.y.doubleValue),
                    neCorner: (x: neCorner3857.x.doubleValue, y: neCorner3857.y.doubleValue)),
                queryBounds: MapBoundingBox(
                    swCorner: (x: swCornerTolerance.x.doubleValue, y: swCornerTolerance.y.doubleValue),
                    neCorner: (x: neCornerTolerance.x.doubleValue, y: neCornerTolerance.y.doubleValue)),
                zoomLevel: zoomLevel,
                cacheKey: cacheKey,
                handler: handler)
        }
    }

    func createBoundsPredicate(queryBounds: MapBoundingBox) -> NSPredicate? {
        guard let boundingPredicate = boundingPredicate else {
            return nil
        }

        var boundsPredicate: NSPredicate?

        if queryBounds.swCorner.x < -180 {
            boundsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
                boundingPredicate(queryBounds.swCorner.y, queryBounds.neCorner.y, -180.0, queryBounds.neCorner.x),
                boundingPredicate(queryBounds.swCorner.y, queryBounds.neCorner.y, queryBounds.swCorner.x + 360.0, 180.0)
            ])
        } else if queryBounds.neCorner.x > 180 {
            boundsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
                boundingPredicate(
                    queryBounds.swCorner.y,
                    queryBounds.neCorner.y,
                    queryBounds.swCorner.x,
                    180.0),
                boundingPredicate(
                    queryBounds.swCorner.y,
                    queryBounds.neCorner.y,
                    -180.0,
                    queryBounds.neCorner.x - 360.0)
            ])
        } else {
            boundsPredicate = boundingPredicate(
                queryBounds.swCorner.y,
                queryBounds.neCorner.y,
                queryBounds.swCorner.x,
                queryBounds.neCorner.x)
        }

        return boundsPredicate
    }

    func drawImageIntoTile(
        mapImage: UIImage,
        object: T,
        tileBounds3857: MapBoundingBox
    ) {
        let object3857Location =
        coord4326To3857(
            longitude: object.longitude,
            latitude: object.latitude)
        let xPosition = (
            ((object3857Location.x - tileBounds3857.swCorner.x) /
             (tileBounds3857.neCorner.x - tileBounds3857.swCorner.x)
            )  * self.tileSize.width)
        let yPosition = self.tileSize.height - (
            ((object3857Location.y - tileBounds3857.swCorner.y)
             / (tileBounds3857.neCorner.y - tileBounds3857.swCorner.y)
            ) * self.tileSize.height)
        mapImage.draw(
            in: CGRect(
                x: (xPosition - (mapImage.size.width / 2)),
                y: (yPosition - (mapImage.size.height / 2)),
                width: mapImage.size.width,
                height: mapImage.size.height
            )
        )
    }

    func drawTile(
        tileBounds3857: MapBoundingBox,
        queryBounds: MapBoundingBox,
        zoomLevel: Int,
        cacheKey: String,
        handler: @escaping (Result<Data, Error>) -> Void) {
        let boundsPredicate: NSPredicate? = createBoundsPredicate(queryBounds: queryBounds)

        guard let boundsPredicate = boundsPredicate else {
            return
        }
        
        var finalPredicate: NSPredicate = boundsPredicate
        
        if let predicate = predicate {
            finalPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, boundsPredicate])
        }
        
        let context = PersistenceController.current.newTaskContext()
        context.perform {
            let objects = getMatchingObjects(predicate: finalPredicate, context: context)
            if objects == nil || objects?.count == 0 {
                handler(.failure(DataTileError.zeroObjects))
                return
            }
            
            UIGraphicsBeginImageContext(self.tileSize)
            
            if let objects = objects {
                for object in objects {
                    let mapImages = object.mapImage(
                        marker: false,
                        zoomLevel: zoomLevel,
                        tileBounds3857: tileBounds3857,
                        context: UIGraphicsGetCurrentContext())
                    for mapImage in mapImages {
                        drawImageIntoTile(mapImage: mapImage, object: object, tileBounds3857: tileBounds3857)
                    }
                }
            }
            
            let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!

            UIGraphicsEndImageContext()
            guard let cgImage = newImage.cgImage else {
                handler(.failure(DataTileError.notFound))
                return
            }
            let data = UIImage(cgImage: cgImage).pngData()
            if let data = data {
                handler(.success(data))
            } else {
                handler(.failure(DataTileError.notFound))
            }
        }
        
    }
    
    func getMatchingObjects(predicate: NSPredicate, context: NSManagedObjectContext) -> [T]? {
        if let objects = objects {
            return objects
        }
        if let managedObjectType = T.self as? NSManagedObject.Type {

            let tileFetchRequest = managedObjectType.fetchRequest()
            tileFetchRequest.sortDescriptors = sortDescriptors
            
            tileFetchRequest.predicate = predicate
            
            let objects = try? context.fetch(tileFetchRequest)
            return objects as? [T]
        }
        
        return nil
    }
    
    func coord4326To3857(longitude: Double, latitude: Double) -> (x: Double, y: Double) {
        let a = 6378137.0
        let lambda = longitude / 180 * Double.pi
        let phi = latitude / 180 * Double.pi
        let x = a * lambda
        let y = a * log(tan(Double.pi / 4 + phi / 2))
        
        return (x: x, y: y)
    }
    
    func coord3857To4326(y: Double, x: Double) -> (lat: Double, lon: Double) {
        let a = 6378137.0
        let distance = -y / a
        let phi = Double.pi / 2 - 2 * atan(exp(distance))
        let lambda = x / a
        let lat = phi / Double.pi * 180
        let lon = lambda / Double.pi * 180
        
        return (lat: lat, lon: lon)
    }
    
    func longitude(x: Int, zoom: Int) -> Double {
        return Double(x) / pow(2.0, Double(zoom)) * 360.0 - 180.0
    }
    
    func latitude(y: Int, zoom: Int) -> Double {
        let yLocation = Double.pi - 2.0 * Double.pi * Double(y) / pow(2.0, Double(zoom))
        return 180.0 / Double.pi * atan(0.5 * (exp(yLocation) - exp(-yLocation)))
    }
}
