//
//  GeoPackageExportable.swift
//  Marlin
//
//  Created by Daniel Barela on 6/23/23.
//

import Foundation
import geopackage_ios
import ExceptionCatcher
import CoreData

extension DataSourcePropertyType {
    var geoPackageType: GPKGDataType {
        switch(self) {
            
        case .string:
            return GPKG_DT_TEXT
        case .date:
            return GPKG_DT_DATE
        case .int:
            return GPKG_DT_INT
        case .float:
            return GPKG_DT_FLOAT
        case .double:
            return GPKG_DT_DOUBLE
        case .boolean:
            return GPKG_DT_BOOLEAN
        case .enumeration:
            return GPKG_DT_TEXT
        case .location:
            return GPKG_DT_TEXT
        case .latitude:
            return GPKG_DT_DOUBLE
        case .longitude:
            return GPKG_DT_DOUBLE
        }
    }
}

protocol GeoPackageExportable: NSObject {
    static var properties: [DataSourceProperty] { get }
    static var key: String { get }
    static var color: UIColor { get }
    static var image: UIImage? { get }
    var sfGeometry: SFGeometry? { get }
    static func createTable(geoPackage: GPKGGeoPackage) throws -> GPKGFeatureTable?
    static func fetchRequest(filters: [DataSourceFilterParameter]?) -> NSFetchRequest<NSFetchRequestResult>?
    static func createFeatures(geoPackage: GPKGGeoPackage, table: GPKGFeatureTable, filters: [DataSourceFilterParameter]?, styleRows: [GPKGStyleRow], dataSourceProgress: DataSourceExportProgress) throws
    func createFeature(geoPackage: GPKGGeoPackage, table: GPKGFeatureTable, styleRows: [GPKGStyleRow])
    static func createStyles(tableStyles: GPKGFeatureTableStyles) -> [GPKGStyleRow]
}

extension GeoPackageExportable {
    static func createTable(geoPackage: GPKGGeoPackage) throws -> GPKGFeatureTable? {
        let srs = geoPackage.spatialReferenceSystemDao().srs(withOrganization: PROJ_AUTHORITY_EPSG, andCoordsysId: PROJ_EPSG_WORLD_GEODETIC_SYSTEM as NSNumber)
        
        let geometryColumns = GPKGGeometryColumns()
        geometryColumns.tableName = key
        geometryColumns.columnName = "geometry"
        geometryColumns.setGeometryType(SF_GEOMETRY)
        geometryColumns.z = 0
        geometryColumns.m = 0
        geometryColumns.setSrs(srs)
        
        var columns: [GPKGFeatureColumn] = []
        var dataColumns: [GPKGDataColumns] = []
        
        let propertiesByName = Dictionary(grouping: properties, by: \.key)
        for (_, properties) in propertiesByName {
            if let property = properties.filter({ property in
                property.subEntityKey == nil
            }).first {
                columns.append(GPKGFeatureColumn.createColumn(withName: property.key, andDataType: property.type.geoPackageType))
                let dc = GPKGDataColumns()
                dc.tableName = key
                dc.columnName = property.key
                dc.name = property.name
                dc.title = property.name
                dataColumns.append(dc)
            }
        }
        
        // for now.  Calculate this properly at some point
        let boundingBox = GPKGBoundingBox(minLongitude: -180.0, andMinLatitude: -90.0, andMaxLongitude: 180.0, andMaxLatitude: 90.0)
        let featureTableMetadata = GPKGFeatureTableMetadata(geometryColumns: geometryColumns, andIdColumn: "object_id", andAutoincrement: true, andAdditionalColumns: columns, andBoundingBox: boundingBox)
        
        let table = try ExceptionCatcher.catch {
            return geoPackage.createFeatureTable(with: featureTableMetadata)
        }
        
        // create the data columns extension for pretty column names
        let extensions = GPKGSchemaExtension(geoPackage: geoPackage)
        extensions?.createDataColumnsTable()
        if let dcDao = GPKGSchemaExtension.dataColumnsDao(with: geoPackage) {
            for dataColumn in dataColumns {
                try ExceptionCatcher.catch {
                    dcDao.create(dataColumn)
                }
            }
        }
        
        // add the icon
        let style = GPKGFeatureStyleExtension(geoPackage: geoPackage)
        style?.createStyleTable()
        style?.createIconTable()
        
        let styleDao = style?.styleDao()
        let iconDao = style?.iconDao()
        
        let featureTableStyles = GPKGFeatureTableStyles(geoPackage: geoPackage, andTable: table)
        let tableStyleDefault = styleDao?.newRow()
        tableStyleDefault?.setName("\(key) Style")
        tableStyleDefault?.setColor(CLRColor(red: Int32(color.redComponent * 255.0), andGreen: Int32(color.greenComponent * 255.0), andBlue: Int32(color.blueComponent * 255.0)))
        tableStyleDefault?.setFillColor(CLRColor(red: Int32(color.redComponent * 255.0), andGreen: Int32(color.greenComponent * 255.0), andBlue: Int32(color.blueComponent * 255.0)))
        if let alpha = color.alphaComponent as? NSDecimalNumber {
            tableStyleDefault?.setOpacity(alpha)
        }
        tableStyleDefault?.setFillOpacity(0.3)

        tableStyleDefault?.setWidth(2.0)
        featureTableStyles?.setTableStyleDefault(tableStyleDefault)
        
        if let image = image {
            let circle = CircleImage(color: color, radius: image.size.width / 2.0 + 10, fill: true, withoutScreenScale: true)
            let combined = UIImage.combineCentered(image1: circle, image2: image.withRenderingMode(.alwaysTemplate).withTintColor(.white))?.aspectResize(to: CGSize(width: 30, height: 30))
            let imageData = combined?.pngData() ?? image.pngData()
            if let imageData = imageData {
                let iconStyleDefault = iconDao?.newRow()
                iconStyleDefault?.tableIcon = true
                iconStyleDefault?.setName("Icon")
                iconStyleDefault?.setContentType("image/png")
                iconStyleDefault?.setData(imageData)
                iconStyleDefault?.setWidthValue(Double(combined?.size.width ?? image.size.width))
                iconStyleDefault?.setHeightValue(Double(combined?.size.height ?? image.size.height))
                featureTableStyles?.setTableIconDefault(iconStyleDefault)
            }
        }

        return table
    }
    
    static func createStyles(tableStyles: GPKGFeatureTableStyles) -> [GPKGStyleRow] {
        return []
    }
    
    static func fetchRequest(filters: [DataSourceFilterParameter]?) -> NSFetchRequest<NSFetchRequestResult>? {
        guard let dataSource = self as? NSManagedObject.Type else {
            return nil
        }
        let fetchRequest = dataSource.fetchRequest()
        var predicates: [NSPredicate] = []
        if let filters = filters {
            for filter in filters {
                if let predicate = filter.toPredicate() {
                    predicates.append(predicate)
                }
            }
        }
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        fetchRequest.predicate = predicate
        return fetchRequest
    }
    
    static func createFeatures(geoPackage: GPKGGeoPackage, table: GPKGFeatureTable, filters: [DataSourceFilterParameter]?, styleRows: [GPKGStyleRow], dataSourceProgress: DataSourceExportProgress) throws {
        guard let fetchRequest = fetchRequest(filters: filters) else {
            return
        }
        
        let context = PersistenceController.current.newTaskContext()
        try context.performAndWait {
            let results = try context.fetch(fetchRequest)
            var exported = 0
            for result in results where result is GeoPackageExportable {
                if let gpExportable = result as? GeoPackageExportable {
                    gpExportable.createFeature(geoPackage: geoPackage, table: table, styleRows: styleRows)
                    exported += 1
                    if exported % 10 == 0 {
                        DispatchQueue.main.async {
                            dataSourceProgress.exportCount = Float(exported)
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                dataSourceProgress.exportCount = Float(exported)
            }
        }
    }
    
    func createFeature(geoPackage: GPKGGeoPackage, table: GPKGFeatureTable, styleRows: [GPKGStyleRow]) {
        guard let featureDao = geoPackage.featureDao(with: table), let row = featureDao.newRow() else {
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
                featureDao.create(row)
            }
        } catch {
            print("Excetion creating feature \(error.localizedDescription)")
        }
    }
}
