//
//  GeoPackage.swift
//  Marlin
//
//  Created by Daniel Barela on 6/29/22.
//

import UIKit
import MapKit
import geopackage_ios
import sf_ios
import sf_proj_ios
import ExceptionCatcher
import SwiftUI

class GeoPackage: NSObject {
    var mapView: MKMapView
    var fileName: String
    var tableName: String
    var geoPackage: GPKGGeoPackage?
    var overlay: BaseMapOverlay?
    var featureTiles: GPKGFeatureTiles?
    var fillColor: UIColor?
    var polygonColor: UIColor?
    var canReplaceMapContent: Bool = false
    var index: Int = 0

    init(mapView: MKMapView, fileName: String, tableName: String, polygonColor: UIColor? = nil, fillColor: UIColor? = nil, canReplaceMapContent: Bool = false, index: Int = 0) {
        self.mapView = mapView
        self.fileName = fileName
        self.tableName = tableName
        self.fillColor = fillColor
        self.canReplaceMapContent = canReplaceMapContent
        self.index = index
        self.polygonColor = polygonColor
    }
    
    func getOverlay() -> BaseMapOverlay? {
        guard let manager = GPKGGeoPackageFactory.manager() else {
            return nil
        }
        let geoPackagePath = Bundle.main.path(forResource: fileName, ofType: "gpkg")
        if !manager.exists(fileName) {
            do {
                let imported = try ExceptionCatcher.catch {
                    return manager.importGeoPackage(fromPath: geoPackagePath)
                }
                if !imported {
                    return nil
                }
            } catch {
                print("Error:", error.localizedDescription)
                // probably was already imported, just ignore
            }
        }
        
        geoPackage = manager.open(fileName)
        guard let geoPackage = geoPackage else {
            return nil
        }
        
        let featureDao = geoPackage.featureDao(withTableName: tableName)
        
        featureTiles = GPKGFeatureTiles(geoPackage: geoPackage, andFeatureDao: featureDao)
        featureTiles?.indexManager = GPKGFeatureIndexManager(geoPackage: geoPackage, andFeatureDao: featureDao)
        featureTiles?.polygonColor = polygonColor
        featureTiles?.polygonFillColor = polygonColor
        featureTiles?.fillPolygon = true
        featureTiles?.polygonStrokeWidth = 0.3
        featureTiles?.lineStrokeWidth = 0.1
        featureTiles?.lineColor = UIColor.lightGray
        
        overlay = BaseMapOverlay(featureTiles: featureTiles, fillColor: fillColor)
        overlay?.minZoom = 0
        overlay?.canReplaceMapContent = canReplaceMapContent
        
        return overlay
    }
    
    func recreateOverlay() -> BaseMapOverlay? {
        guard let featureTiles = featureTiles else {
            return nil
        }

        featureTiles.polygonColor = polygonColor
        featureTiles.polygonFillColor = polygonColor
        overlay = BaseMapOverlay(featureTiles: featureTiles, fillColor: fillColor)
        overlay?.minZoom = 0
        overlay?.canReplaceMapContent = true
        return overlay
    }
    
    func columnName(dataColumnsDao: GPKGDataColumnsDao?, featureRow: GPKGFeatureRow, columnName: String) -> String {
        guard let dataColumnsDao = dataColumnsDao, let dataColumn = dataColumnsDao.dataColumn(byTableName: featureRow.table.tableName, andColumnName: columnName) else {
            return columnName
        }
        return dataColumn.name
    }
    
    func getFeaturesAtLocation(location: CLLocationCoordinate2D) -> [GPKGFeatureRowData] {
        let dataColumnsDao = GPKGDataColumnsDao(database: geoPackage?.database)
        
        var featureRows: [GPKGFeatureRowData] = []
                
        let featureIndexResults = featureTiles?.indexManager.query(with: SFGeometryEnvelope())
        while ((featureIndexResults?.moveToNext()) == true) {
            if let featureRow = featureIndexResults?.featureRow() {
                let geometryColumn = featureRow.geometryColumnIndex()
                var geometryColumnName: String?
                var featureDataTypes: [String : String] = [:]
                var values: [String : Any] = [:]
                
//                var coordinate = location
                
                for i in 0...featureRow.columnCount() {
                    let value = featureRow.value(with: i)
                    let columnName = columnName(dataColumnsDao: dataColumnsDao, featureRow: featureRow, columnName: featureRow.columnName(with: i))
                    if i == geometryColumn {
                        geometryColumnName = columnName
//                        if let geometry = value as? GPKGGeometryData, let centroid = geometry.geometry.centroid() {
//                            coordinate = CLLocationCoordinate2D(latitude: centroid.y.doubleValue, longitude: centroid.x.doubleValue)
//                        }
                    }
                    
                    featureDataTypes[columnName] = GPKGDataTypes.name(featureRow.featureColumns.column(with: i).dataType)
                    if value != nil {
                        values[columnName] = value
                    }
                }
                if let featureRowData = GPKGFeatureRowData(values: values, andGeometryColumnName: geometryColumnName) {
                    featureRows.append(featureRowData)
                }
            }
        }
        return featureRows
    }
}
