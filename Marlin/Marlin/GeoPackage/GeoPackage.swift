//
//  GeoPackage.swift
//  Marlin
//
//  Created by Daniel Barela on 6/29/22.
//

import UIKit
import MapKit
import geopackage_ios
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
    var canReplaceMapContent: Bool = false
    var index: Int = 0

    init(mapView: MKMapView, fileName: String, tableName: String, fillColor: UIColor? = nil, canReplaceMapContent: Bool = false, index: Int = 0) {
        self.mapView = mapView
        self.fileName = fileName
        self.tableName = tableName
        self.fillColor = fillColor
        self.canReplaceMapContent = canReplaceMapContent
        self.index = index
    }
    
    func addOverlay() {
        guard let manager = GPKGGeoPackageFactory.manager() else {
            return
        }
        let geoPackagePath = Bundle.main.path(forResource: fileName, ofType: "gpkg")
        if !manager.exists(fileName) {
            do {
                let imported = try ExceptionCatcher.catch {
                    return manager.importGeoPackage(fromPath: geoPackagePath)
                }
                if !imported {
                    return
                }
            } catch {
                print("Error:", error.localizedDescription)
                // probably was already imported, just ignore
            }
        }
        
        geoPackage = manager.open(fileName)
        if let geoPackage = geoPackage {
            let featureDao = geoPackage.featureDao(withTableName: tableName)
            
            featureTiles = GPKGFeatureTiles(geoPackage: geoPackage, andFeatureDao: featureDao)
            featureTiles?.indexManager = GPKGFeatureIndexManager(geoPackage: geoPackage, andFeatureDao: featureDao)
            let style = UITraitCollection.current.userInterfaceStyle
            if style == .light {
                featureTiles?.polygonColor = UIColor(red: 0.91, green: 0.87, blue: 0.80, alpha: 1.00)
                featureTiles?.polygonFillColor = UIColor(red: 0.91, green: 0.87, blue: 0.80, alpha: 1.00)
            } else {
                featureTiles?.polygonColor = UIColor(red: 0.72, green: 0.67, blue: 0.54, alpha: 1.00)
                featureTiles?.polygonFillColor = UIColor(red: 0.72, green: 0.67, blue: 0.54, alpha: 1.00)
            }
            featureTiles?.fillPolygon = true
            featureTiles?.polygonStrokeWidth = 0.3
            featureTiles?.lineStrokeWidth = 0.1
            featureTiles?.lineColor = UIColor.lightGray
            
            overlay = BaseMapOverlay(featureTiles: featureTiles, fillColor: fillColor)
            overlay?.minZoom = 0
            overlay?.canReplaceMapContent = canReplaceMapContent
            
            if let overlay = overlay {
                mapView.insertOverlay(overlay, at: index)
//                mapView.addOverlay(overlay)
            }
        }
    }
    
    func updateLayers() {
        let style = UITraitCollection.current.userInterfaceStyle
        if style == .light {
            featureTiles?.polygonColor = UIColor(red: 0.91, green: 0.87, blue: 0.80, alpha: 1.00)
            featureTiles?.polygonFillColor = UIColor(red: 0.91, green: 0.87, blue: 0.80, alpha: 1.00)
        } else {
            featureTiles?.polygonColor = UIColor(red: 0.72, green: 0.67, blue: 0.54, alpha: 1.00)
            featureTiles?.polygonFillColor = UIColor(red: 0.72, green: 0.67, blue: 0.54, alpha: 1.00)
        }
        if let oldOverlay = overlay {
            mapView.removeOverlay(oldOverlay)
            overlay = BaseMapOverlay(featureTiles: featureTiles, fillColor: fillColor)
            overlay?.minZoom = 0
            overlay?.canReplaceMapContent = true
            if let overlay = overlay {
                mapView.addOverlay(overlay)
            }
        }
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
                
                var coordinate = location
                
                for i in 0...featureRow.columnCount() {
                    let value = featureRow.value(with: i)
                    let columnName = columnName(dataColumnsDao: dataColumnsDao, featureRow: featureRow, columnName: featureRow.columnName(with: i))
                    if i == geometryColumn {
                        geometryColumnName = columnName
                        if let geometry = value as? GPKGGeometryData, let centroid = geometry.geometry.centroid() {
                            coordinate = CLLocationCoordinate2D(latitude: centroid.y.doubleValue, longitude: centroid.x.doubleValue)
                        }
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
