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

protocol GeoPackageExportable: DataSource, NSManagedObject {
    var sfGeometry: SFGeometry? { get }
    static func createTable(geoPackage: GPKGGeoPackage) throws -> GPKGFeatureTable?
    func createFeature(geoPackage: GPKGGeoPackage, table: GPKGFeatureTable)
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
        
        for property in properties {
            columns.append(GPKGFeatureColumn.createColumn(withName: property.key, andDataType: property.type.geoPackageType))
            let dc = GPKGDataColumns()
            dc.tableName = key
            dc.columnName = property.key
            dc.name = property.name
            dc.title = property.name
            dataColumns.append(dc)
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
        tableStyleDefault?.setColor(CLRColor(hex: "#FFDD66FF"))
        tableStyleDefault?.setOpacity(1.0)
        tableStyleDefault?.setWidth(10.0)
        tableStyleDefault?.setFillColor(CLRColor(hex: "#FFDD66FF"))
        tableStyleDefault?.setFillOpacity(1.0)
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
    
    func createFeature(geoPackage: GPKGGeoPackage, table: GPKGFeatureTable) {
        guard let featureDao = geoPackage.featureDao(with: table), let row = featureDao.newRow() else {
            return
        }
        if let sfGeometry = sfGeometry {
            let gpkgGeometry = GPKGGeometryData(geometry: sfGeometry)
            row.setValueWithColumnName("geometry", andValue: gpkgGeometry)
        }
        
        for property in Self.properties {
            if let value = self.value(forKey: property.key) as? NSObject {
                row.setValueWithColumnName(property.key, andValue: value)
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
