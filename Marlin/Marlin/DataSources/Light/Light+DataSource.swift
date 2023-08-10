//
//  Light+DataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import UIKit
import CoreData
import Alamofire
import MapKit
import sf_ios
import geopackage_ios
import ExceptionCatcher

extension Light: Bookmarkable {
    var itemKey: String? {
        return "\(featureNumber ?? "")--\(volumeNumber ?? "")--\(characteristicNumber)"
    }
    
    static func getItem(context: NSManagedObjectContext, itemKey: String?) -> Bookmarkable? {
        if let split = itemKey?.split(separator: "--"), split.count == 3 {
            return getLight(context: context, featureNumber: "\(split[0])", volumeNumber: "\(split[1])", characteristicNumber: Int64(split[2]) ?? 0)
        }
        
        return nil
    }
    
    static func getLight(context: NSManagedObjectContext, featureNumber: String?, volumeNumber: String?, characteristicNumber: Int64) -> Light? {
        if let featureNumber = featureNumber, let volumeNumber = volumeNumber {
            return try? context.fetchFirst(Light.self, predicate: NSPredicate(format: "featureNumber = %@ AND volumeNumber = %@ AND characteristicNumber = %d", argumentArray: [featureNumber, volumeNumber, characteristicNumber]))
        }
        return nil
    }
}

extension Light: DataSourceLocation, GeoPackageExportable {
    func sfGeometryByColor() -> [UIColor: SFGeometry?]? {
        var geometryByColor: [UIColor:SFGeometry] = [:]
        if let lightSectors = lightSectors {
            let sectorsByColor = Dictionary(grouping: lightSectors, by: \.color)
            for (color, sectors) in sectorsByColor {
                let collection = SFGeometryCollection()

                for sector in sectors {
                    if sector.obscured {
                        continue
                    }
                    let nauticalMilesMeasurement = NSMeasurement(doubleValue: sector.range ?? 0.0, unit: UnitLength.nauticalMiles)
                    let metersMeasurement = nauticalMilesMeasurement.converting(to: UnitLength.meters)
                    if sector.startDegrees >= sector.endDegrees {
                        // this could be an error in the data, or sometimes lights are defined as follows:
                        // characteristic Q.W.R.
                        // remarks R. 289°-007°, W.-007°.
                        // that would mean this light flashes between red and white over those angles
                        // TODO: figure out what to do with multi colored lights over the same sector
                        continue
                    }
                    let circleCoordinates = coordinate.circleCoordinates(radiusMeters: metersMeasurement.value, startDegrees: sector.startDegrees + 90.0, endDegrees: sector.endDegrees + 90.0)
                    
                    let ring = SFLineString()
                    ring?.addPoint(SFPoint(xValue: coordinate.longitude, andYValue: coordinate.latitude))
                    for circleCoordinate in circleCoordinates {
                        let point = SFPoint(xValue: circleCoordinate.longitude, andYValue: circleCoordinate.latitude)
                        ring?.addPoint(point)
                    }
                    let poly = SFPolygon(ring: ring)
                    if let poly = poly {
                        collection?.addGeometry(poly)
                    }
                }
                geometryByColor[color] = collection
            }
            
            return geometryByColor
        }
        return nil
    }
    
    var sfGeometry: SFGeometry? {
        if let geometryByColor = sfGeometryByColor() {
            
            let collection = SFGeometryCollection()
        
            for geometry in geometryByColor.values {
                collection?.addGeometry(geometry)
            }
            return collection
        } else {
            return SFPoint(xValue: coordinate.longitude, andYValue: coordinate.latitude)
        }
    }
    
    static func getBoundingPredicate(minLat: Double, maxLat: Double, minLon: Double, maxLon: Double) -> NSPredicate {
        return NSPredicate(
            format: "characteristicNumber = 1 AND latitude >= %lf AND latitude <= %lf AND longitude >= %lf AND longitude <= %lf", minLat, maxLat, minLon, maxLon
        )
    }
    
    static func createStyles(tableStyles: GPKGFeatureTableStyles) -> [GPKGStyleRow] {
        var styleRows: [GPKGStyleRow] = []
        
        let red = tableStyles.styleDao().newRow()
        red?.setName("RedLightStyle")
        red?.setColor(CLRColor(red: Int32(Light.redLight.redComponent * 255.0), andGreen: Int32(Light.redLight.greenComponent * 255.0), andBlue: Int32(Light.redLight.blueComponent * 255.0)))
        red?.setFillColor(CLRColor(red: Int32(Light.redLight.redComponent * 255.0), andGreen: Int32(Light.redLight.greenComponent * 255.0), andBlue: Int32(Light.redLight.blueComponent * 255.0)))
        red?.setFillOpacity(0.3)
        red?.setWidth(2.0)
        if let red = red {
            styleRows.append(red)
        }
        let green = tableStyles.styleDao().newRow()
        green?.setName("GreenLightStyle")
        green?.setColor(CLRColor(red: Int32(Light.greenLight.redComponent * 255.0), andGreen: Int32(Light.greenLight.greenComponent * 255.0), andBlue: Int32(Light.greenLight.blueComponent * 255.0)))
        green?.setFillColor(CLRColor(red: Int32(Light.greenLight.redComponent * 255.0), andGreen: Int32(Light.greenLight.greenComponent * 255.0), andBlue: Int32(Light.greenLight.blueComponent * 255.0)))
        green?.setFillOpacity(0.3)
        green?.setWidth(2.0)
        if let green = green {
            styleRows.append(green)
        }
        let blue = tableStyles.styleDao().newRow()
        blue?.setName("BlueLightStyle")
        blue?.setColor(CLRColor(red: Int32(Light.blueLight.redComponent * 255.0), andGreen: Int32(Light.blueLight.greenComponent * 255.0), andBlue: Int32(Light.blueLight.blueComponent * 255.0)))
        blue?.setFillColor(CLRColor(red: Int32(Light.blueLight.redComponent * 255.0), andGreen: Int32(Light.blueLight.greenComponent * 255.0), andBlue: Int32(Light.blueLight.blueComponent * 255.0)))
        blue?.setFillOpacity(0.3)
        blue?.setWidth(2.0)
        if let blue = blue {
            styleRows.append(blue)
        }
        let white = tableStyles.styleDao().newRow()
        white?.setName("WhiteLightStyle")
        white?.setColor(CLRColor(red: Int32(Light.whiteLight.redComponent * 255.0), andGreen: Int32(Light.whiteLight.greenComponent * 255.0), andBlue: Int32(Light.whiteLight.blueComponent * 255.0)))
        white?.setFillColor(CLRColor(red: Int32(Light.whiteLight.redComponent * 255.0), andGreen: Int32(Light.whiteLight.greenComponent * 255.0), andBlue: Int32(Light.whiteLight.blueComponent * 255.0)))
        white?.setFillOpacity(0.3)
        white?.setWidth(2.0)
        if let white = white {
            styleRows.append(white)
        }
        let yellow = tableStyles.styleDao().newRow()
        yellow?.setName("YellowLightStyle")
        yellow?.setColor(CLRColor(red: Int32(Light.yellowLight.redComponent * 255.0), andGreen: Int32(Light.yellowLight.greenComponent * 255.0), andBlue: Int32(Light.yellowLight.blueComponent * 255.0)))
        yellow?.setFillColor(CLRColor(red: Int32(Light.yellowLight.redComponent * 255.0), andGreen: Int32(Light.yellowLight.greenComponent * 255.0), andBlue: Int32(Light.yellowLight.blueComponent * 255.0)))
        yellow?.setFillOpacity(0.3)
        yellow?.setWidth(2.0)
        if let yellow = yellow {
            styleRows.append(yellow)
        }
        let violet = tableStyles.styleDao().newRow()
        violet?.setName("VioletLightStyle")
        violet?.setColor(CLRColor(red: Int32(Light.violetLight.redComponent * 255.0), andGreen: Int32(Light.violetLight.greenComponent * 255.0), andBlue: Int32(Light.violetLight.blueComponent * 255.0)))
        violet?.setFillColor(CLRColor(red: Int32(Light.violetLight.redComponent * 255.0), andGreen: Int32(Light.violetLight.greenComponent * 255.0), andBlue: Int32(Light.violetLight.blueComponent * 255.0)))
        violet?.setFillOpacity(0.3)
        violet?.setWidth(2.0)
        if let violet = violet {
            styleRows.append(violet)
        }
        let orange = tableStyles.styleDao().newRow()
        orange?.setName("OrangeLightStyle")
        orange?.setColor(CLRColor(red: Int32(Light.orangeLight.redComponent * 255.0), andGreen: Int32(Light.orangeLight.greenComponent * 255.0), andBlue: Int32(Light.orangeLight.blueComponent * 255.0)))
        orange?.setFillColor(CLRColor(red: Int32(Light.orangeLight.redComponent * 255.0), andGreen: Int32(Light.orangeLight.greenComponent * 255.0), andBlue: Int32(Light.orangeLight.blueComponent * 255.0)))
        orange?.setFillOpacity(0.3)
        orange?.setWidth(2.0)
        if let orange = orange {
            styleRows.append(orange)
        }

        return styleRows
    }
    
    func createFeature(geoPackage: GPKGGeoPackage, table: GPKGFeatureTable, styleRows: [GPKGStyleRow]) {
        
        guard let featureDao = geoPackage.featureDao(with: table), let featureTableStyles = GPKGFeatureTableStyles(geoPackage: geoPackage, andTable: table) else {
            return
        }
        if let geometryColors = sfGeometryByColor() {
            featureTableStyles.createStyleRelationship()
            for (color, geometry) in geometryColors {
                if let geometry = geometry, let row = featureDao.newRow() {
                    
                    let gpkgGeometry = GPKGGeometryData(geometry: geometry)
                    row.setValueWithColumnName("geometry", andValue: gpkgGeometry)
                    
                    let propertiesByName = Dictionary(grouping: Self.properties, by: \.key)
                    for (_, properties) in propertiesByName {
                        if let property = properties.filter({ property in
                            property.subEntityKey == nil
                        }).first {
                            if let value = self.value(forKey: property.key) as? NSObject {
                                row.setValueWithColumnName(property.key, andValue: value)
                            }
                        }
                    }
                    do {
                        try ExceptionCatcher.catch {
                            let rowId = featureDao.create(row)
                            if color == Light.redLight {
                                featureTableStyles.setStyleDefault(styleRows[0], withId: Int32(rowId))
                            } else if color == Light.greenLight {
                                featureTableStyles.setStyleDefault(styleRows[1], withId: Int32(rowId))
                            } else if color == Light.blueLight {
                                featureTableStyles.setStyleDefault(styleRows[2], withId: Int32(rowId))
                            }  else if color == Light.whiteLight {
                                featureTableStyles.setStyleDefault(styleRows[3], withId: Int32(rowId))
                            } else if color == Light.yellowLight {
                                featureTableStyles.setStyleDefault(styleRows[4], withId: Int32(rowId))
                            } else if color == Light.violetLight {
                                featureTableStyles.setStyleDefault(styleRows[5], withId: Int32(rowId))
                            } else if color == Light.orangeLight {
                                featureTableStyles.setStyleDefault(styleRows[6], withId: Int32(rowId))
                            }
                        }
                    } catch {
                        print("Excetion creating feature \(error.localizedDescription)")
                    }
                }
            }
            
        } else {
            guard let row = featureDao.newRow() else {
                return
            }
            if let sfGeometry = sfGeometry {
                let gpkgGeometry = GPKGGeometryData(geometry: sfGeometry)
                row.setValueWithColumnName("geometry", andValue: gpkgGeometry)
            }
            
            let propertiesByName = Dictionary(grouping: Self.properties, by: \.key)
            for (_, properties) in propertiesByName {
                if let property = properties.filter({ property in
                    property.subEntityKey == nil
                }).first {
                    if let value = self.value(forKey: property.key) as? NSObject {
                        row.setValueWithColumnName(property.key, andValue: value)
                    }
                }
            }
            do {
                try ExceptionCatcher.catch {
                    let rowId = featureDao.create(row)
                    
                }
            } catch {
                print("Excetion creating feature \(error.localizedDescription)")
            }
        }
    }
    
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }
    
    static var isMappable: Bool = true
    static var dataSourceName: String = NSLocalizedString("Lights", comment: "Lights data source display name")
    static var fullDataSourceName: String = NSLocalizedString("Lights", comment: "Lights data source display name")
    static var key: String = "light"
    static var metricsKey: String = "lights"
    static var imageName: String? = nil
    static var systemImageName: String? = "lightbulb.fill"
    static var color: UIColor = UIColor(argbValue: 0xFFFFC500)
    static var imageScale = UserDefaults.standard.imageScale(key) ?? 0.66
    
    static var defaultSort: [DataSourceSortParameter] = [DataSourceSortParameter(property:DataSourceProperty(name: "Region", key: #keyPath(Light.sectionHeader), type: .string), ascending: true), DataSourceSortParameter(property:DataSourceProperty(name: "Feature Number", key: #keyPath(Light.featureNumber), type: .int), ascending: true)]
    static var defaultFilter: [DataSourceFilterParameter] = []
    
    static var properties: [DataSourceProperty] = [
        DataSourceProperty(name: "Location", key: #keyPath(Light.mgrs10km), type: .location),
        DataSourceProperty(name: "Latitude", key: #keyPath(Light.latitude), type: .latitude),
        DataSourceProperty(name: "Longitude", key: #keyPath(Light.longitude), type: .longitude),
        DataSourceProperty(name: "Feature Number", key: #keyPath(Light.featureNumber), type: .string),
        DataSourceProperty(name: "International Feature Number", key: #keyPath(Light.internationalFeature), type: .string),
        DataSourceProperty(name: "Name", key: #keyPath(Light.name), type: .string),
        DataSourceProperty(name: "Structure", key: #keyPath(Light.structure), type: .string),
        DataSourceProperty(name: "Focal Plane Elevation (ft)", key: #keyPath(Light.heightFeet), type: .double),
        DataSourceProperty(name: "Focal Plane Elevation (m)", key: #keyPath(Light.heightMeters), type: .double),
        DataSourceProperty(name: "Range (nm)", key: #keyPath(Light.lightRange), type: .double, subEntityKey: #keyPath(LightRange.range)),
        DataSourceProperty(name: "Remarks", key: #keyPath(Light.remarks), type: .string),
        DataSourceProperty(name: "Characteristic", key: #keyPath(Light.characteristic), type: .string),
        DataSourceProperty(name: "Signal", key: #keyPath(Light.characteristic), type: .string),
        DataSourceProperty(name: "Notice Number", key: #keyPath(Light.noticeNumber), type: .int),
        DataSourceProperty(name: "Notice Week", key: #keyPath(Light.noticeWeek), type: .string),
        DataSourceProperty(name: "Notice Year", key: #keyPath(Light.noticeYear), type: .string),
        DataSourceProperty(name: "Volume Number", key: #keyPath(Light.volumeNumber), type: .string),
        DataSourceProperty(name: "Preceding Note", key: #keyPath(Light.precedingNote), type: .string),
        DataSourceProperty(name: "Post Note", key: #keyPath(Light.postNote), type: .string),
        DataSourceProperty(name: "Region", key: #keyPath(Light.sectionHeader), type: .string),
        DataSourceProperty(name: "Geopolitical Heading", key: #keyPath(Light.geopoliticalHeading), type: .string),
        DataSourceProperty(name: "Region Heading", key: #keyPath(Light.regionHeading), type: .string),
        DataSourceProperty(name: "Subregion Heading", key: #keyPath(Light.subregionHeading), type: .string),
        DataSourceProperty(name: "Local Heading", key: #keyPath(Light.localHeading), type: .string)
    ]
    
    var coordinateRegion: MKCoordinateRegion? {
        MKCoordinateRegion(center: self.coordinate, zoom: 14.5, bounds: CGRect(x: 0, y: 0, width: 600, height: 600))
    }
}

extension Light: BatchImportable {
    static var seedDataFiles: [String]? = ["lights"]
    static var decodableRoot: Decodable.Type = LightsPropertyContainer.self
    
    static func getRequeryRequest(initialRequest: URLRequestConvertible) -> URLRequestConvertible? {
        guard let url = initialRequest.urlRequest?.url else {
            return nil
        }
        let components = URLComponents(string: url.absoluteString)
        var volume: String? = nil
        if let queryItems = components?.queryItems {
            for queryItem in queryItems {
                if queryItem.name == "volume" {
                    volume = queryItem.value
                }
            }
        }
        if let volume = volume {
            return MSIRouter.readLights(volume: volume)
        }
        return nil
    }
    
    static func batchImport(value: Decodable?, initialLoad: Bool = false) async throws -> Int {
        guard let value = value as? LightsPropertyContainer else {
            return 0
        }
        let count = value.ngalol.count
        NSLog("Received \(count) \(Self.key) records.")
        // if this is not the first load and we got back records, re-query
        if count != 0 && !initialLoad {
            return -1
        }
        return try await Light.importRecords(from: value.ngalol, taskContext: PersistenceController.current.newTaskContext())
    }
    
    static func dataRequest() -> [MSIRouter] {
        var requests: [MSIRouter] = []
        
        for lightVolume in Light.lightVolumes {
            let context = PersistenceController.current.newTaskContext()
            context.performAndWait {
                let newestLight = try? PersistenceController.current.fetchFirst(Light.self, sortBy: [NSSortDescriptor(keyPath: \Light.noticeNumber, ascending: false)], predicate: NSPredicate(format: "volumeNumber = %@", lightVolume.volumeNumber), context: context)
                
                let noticeWeek = Int(newestLight?.noticeWeek ?? "0") ?? 0
                
                print("Query for lights in volume \(lightVolume) after year:\(newestLight?.noticeYear ?? "") week:\(noticeWeek)")
                
                requests.append(MSIRouter.readLights(volume: lightVolume.volumeQuery, noticeYear: newestLight?.noticeYear, noticeWeek: String(format: "%02d", noticeWeek + 1)))
            }
        }
        
        return requests
    }
    
    static func shouldSync() -> Bool {
        // sync once every week
        return UserDefaults.standard.dataSourceEnabled(Light.self) && (Date().timeIntervalSince1970 - (60 * 60 * 24 * 7)) > UserDefaults.standard.lastSyncTimeSeconds(Light.self)
    }
    
    static func newBatchInsertRequest(with propertyList: [LightsProperties]) -> NSBatchInsertRequest {
        var index = 0
        let total = propertyList.count
        NSLog("Creating batch insert request of lights for \(total) lights")
        
        struct PreviousLocation {
            var previousRegionHeading: String?
            var previousSubregionHeading: String?
            var previousLocalHeading: String?
        }
        
        var previousHeadingPerVolume: [String : PreviousLocation] = [:]
        // Provide one dictionary at a time when the closure is called.
        let batchInsertRequest = NSBatchInsertRequest(entity: Light.entity(), dictionaryHandler: { dictionary in
            guard index < total else { return true }
            let propertyDictionary = propertyList[index].dictionaryValue
            let volumeNumber = propertyDictionary["volumeNumber"] as? String ?? ""
            var previousLocation = previousHeadingPerVolume[volumeNumber]
            
            let region = propertyDictionary["regionHeading"] as? String ?? previousLocation?.previousRegionHeading
            let subregion = propertyDictionary["subregionHeading"] as? String ?? previousLocation?.previousSubregionHeading
            let local = propertyDictionary["localHeading"] as? String ?? previousLocation?.previousLocalHeading
            
            var correctedLocationDictionary: [String:String?] = [
                "regionHeading": propertyDictionary["regionHeading"] as? String ?? previousLocation?.previousRegionHeading,
                "subregionHeading": propertyDictionary["subregionHeading"] as? String ?? previousLocation?.previousSubregionHeading,
                "localHeading": propertyDictionary["localHeading"] as? String ?? previousLocation?.previousLocalHeading
            ]
            if let rh = correctedLocationDictionary["regionHeading"] as? String {
                correctedLocationDictionary["sectionHeader"] = "\(propertyDictionary["geopoliticalHeading"] as? String ?? ""): \(rh)"
            } else {
                correctedLocationDictionary["sectionHeader"] = "\(propertyDictionary["geopoliticalHeading"] as? String ?? "")"
            }
            
            if previousLocation?.previousRegionHeading != region {
                previousLocation?.previousRegionHeading = region
                previousLocation?.previousSubregionHeading = nil
                previousLocation?.previousLocalHeading = nil
            } else if previousLocation?.previousSubregionHeading != subregion {
                previousLocation?.previousSubregionHeading = subregion
                previousLocation?.previousLocalHeading = nil
            } else if previousLocation?.previousLocalHeading != local {
                previousLocation?.previousLocalHeading = local
            }
            previousHeadingPerVolume[volumeNumber] = previousLocation ?? PreviousLocation(previousRegionHeading: region, previousSubregionHeading: subregion, previousLocalHeading: local)
            
            dictionary.addEntries(from: propertyDictionary.filter({
                return $0.value != nil
            }) as [AnyHashable : Any])
            dictionary.addEntries(from: correctedLocationDictionary.filter({
                return $0.value != nil
            }) as [AnyHashable : Any])
            index += 1
            return false
        })
        return batchInsertRequest
    }
    
    static func importRecords(from propertiesList: [LightsProperties], taskContext: NSManagedObjectContext) async throws -> Int {
        guard !propertiesList.isEmpty else { return 0 }
        
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importLight"
        
        /// - Tag: performAndWait
        return try await taskContext.perform {
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = Light.newBatchInsertRequest(with: propertiesList)
            batchInsertRequest.resultType = .count
            do {
                let fetchResult = try taskContext.execute(batchInsertRequest)
                if let batchInsertResult = fetchResult as? NSBatchInsertResult {
                    try? taskContext.save()
                    if let count = batchInsertResult.result as? Int, count > 0 {
                        NSLog("Inserted \(count) Light records")
                        return count
                    } else {
                        NSLog("No new Light records")
                    }
                    // if there were already lights in the db for this volume and this was an update and we got back a light we have to go redo the query due to regions not being populated on all returned objects
                    return 0
                }
            } catch {
                print("error was \(error)")
            }
            throw MSIError.batchInsertError
        }
    }
}
