//
//  GeoPackage.swift
//  Marlin
//
//  Created by Daniel Barela on 3/27/23.
//

import Foundation
import geopackage_ios
import ExceptionCatcher

class GeoPackage {
    
    static let shared = GeoPackage()
    
    var manager: GPKGGeoPackageManager = GPKGGeoPackageFactory.manager()
    var cache: GPKGGeoPackageCache
    
    private init() {
        cache = GPKGGeoPackageCache(manager: manager)
    }
    
    func getGeoPackage(name: String) -> GPKGGeoPackage {
        return cache.geoPackageOpenName(name)
    }
    
    func dataColumnsDao(database: GPKGConnection) -> GPKGDataColumnsDao? {
        let dataColumnsDao = GPKGDataColumnsDao(database: database)
        
        if (!(dataColumnsDao?.tableExists() ?? false)) {
            return nil
        }
        
        return dataColumnsDao
    }
    
    func displayColumnName(dataColumnsDao: GPKGDataColumnsDao?, featureRow: GPKGFeatureRow, columnName: String) -> String {
        if let dataColumnsDao = dataColumnsDao, let dataColumn = dataColumnsDao.dataColumn(byTableName: featureRow.table.tableName, andColumnName: columnName) {
            return dataColumn.name
        }
        return columnName
    }
    
    func displayColumnName(dataColumnsDao: GPKGDataColumnsDao?, attributeRow: GPKGAttributesRow, columnName: String) -> String {
        if let dataColumnsDao = dataColumnsDao, let dataColumn = dataColumnsDao.dataColumn(byTableName: attributeRow.table.tableName, andColumnName: columnName) {
            return dataColumn.name
        }
        return columnName
    }

    func getFeaturesFromTable(at location: CLLocationCoordinate2D, mapView: MKMapView, table: String, geoPackageName: String, layerName: String) -> [GeoPackageFeatureItem] {
        var featureItems: [GeoPackageFeatureItem] = []
        let geoPackage = GeoPackage.shared.getGeoPackage(name: geoPackageName)
        if !GPKGContentsDataTypes.isFeaturesType(geoPackage.type(ofTable: table)) {
            return []
        }
        if let boundingBox = GPKGMapUtils.buildClickBoundingBox(with: GPKGMapUtils.buildClickLocationBoundingBox(with: location, andMapView: mapView, andScreenPercentage: 0.03)), let featureDao = geoPackage.featureDao(withTableName: table), let indexManager = GPKGFeatureIndexManager(geoPackage: geoPackage, andFeatureDao: featureDao) {
                        
            let rte = GPKGRelatedTablesExtension(geoPackage: geoPackage)
            
            var mediaTables: [GPKGExtendedRelation] = []
            var attributeTables: [GPKGExtendedRelation] = []
            
            if let relationsDao = GPKGExtendedRelationsDao(database: geoPackage.database), relationsDao.tableExists(), let relations = relationsDao.relations(toBaseTable: table) {
                do {
                    try ExceptionCatcher.catch {
                        while relations.moveToNext() {
                            let extendedRelation: GPKGExtendedRelation = relationsDao.relation(relations)
                            if extendedRelation.relationType() == GPKGRelationTypes.fromName("media") {
                                mediaTables.append(extendedRelation)
                            } else if extendedRelation.relationType() == GPKGRelationTypes.fromName("attributes") || extendedRelation.relationType() == GPKGRelationTypes.fromName("simple_attributes") {
                                attributeTables.append(extendedRelation)
                            }
                        }
                        relations.close()
                    }
                } catch {
                    print("Error getting relations from the GeoPackage \(error)")
                    relations.close()
                }
            }
            
            let dataColumnsDao = self.dataColumnsDao(database: geoPackage.database)

            if let results = indexManager.query(with: boundingBox, in: PROJProjectionFactory.projection(withEpsgInt: 4326)) {
                for row in results {
                    guard let featureRow = row as? GPKGFeatureRow else {
                        continue
                    }
                    var media: [GPKGMediaRow] = []
                    var attributes: [GPKGAttributesRow] = []
                    
                    let featureId = featureRow.idValue()
                    
                    for relation in mediaTables {
                        let relatedMedia = rte?.mappings(forTableName: relation.mappingTableName, withBaseId: featureId)
                        let mediaDao = rte?.mediaDao(forTableName: relation.relatedTableName)
                        media.append(contentsOf: mediaDao?.rows(withIds: relatedMedia) ?? [])
                    }
                    
                    for relation in attributeTables {
                        let relatedAttributes = rte?.mappings(forTableName: relation.mappingTableName, withBaseId: featureId) ?? []
                        let attributesDao = geoPackage.attributesDao(withTableName: relation.relatedTableName)
                        
                        for relatedAttribute in relatedAttributes {
                            if let row = attributesDao?.query(forIdObject: relatedAttribute) as? GPKGAttributesRow {
                                attributes.append(row)
                            }
                        }
                    }
                    
                    var values: [String : AnyHashable] = [:]
                    var featureDataTypes: [String : String] = [:]
                    var geometryColumn = featureRow.geometryColumnIndex()
                    var geometryColumnName: String?
                    
                    var coordinate = location
                    
                    for i in 0...(featureRow.columnCount() - 1) {
                        let value = featureRow.value(with: i)
                        let columnName = self.displayColumnName(dataColumnsDao: dataColumnsDao, featureRow: featureRow, columnName: featureRow.columnName(with: i))
                        if i == geometryColumn {
                            geometryColumnName = columnName
                            if let geometry = value as? GPKGGeometryData {
                                var centroid = geometry.geometry.centroid()
                                let transform = SFPGeometryTransform(from: featureDao.projection, andToEpsg: 4326)
                                if let centroid = transform?.transform(centroid) {
                                    coordinate = CLLocationCoordinate2D(latitude: centroid.y.doubleValue, longitude: centroid.x.doubleValue)
                                }
                            }
                        }
                        
                        if let dataType = GPKGDataTypes.name(featureRow.featureColumns.columns()[Int(i)].dataType) {
                            featureDataTypes[columnName] = dataType
                        }
                        
                        if let value = value {
                            values[columnName] = value
                        }
                    }
                    
                    let featureRowData = GPKGFeatureRowData(values: values, andGeometryColumnName: geometryColumnName)
                    var attributeFeatureRowData: [GeoPackageFeatureItem] = []
                    for row in attributes {
                        var attributeMediaTables: [GPKGExtendedRelation] = []
                        var attributeMedias: [GPKGMediaRow] = []
                        if let relationsDao = GPKGExtendedRelationsDao(database: geoPackage.database), relationsDao.tableExists(), let relations = relationsDao.relations(toBaseTable: row.attributesTable.tableName()) {
                            do {
                                try ExceptionCatcher.catch {
                                    while relations.moveToNext() {
                                        let extendedRelation: GPKGExtendedRelation = relationsDao.relation(relations)
                                        if extendedRelation.relationType() == GPKGRelationTypes.fromName("media") {
                                            attributeMediaTables.append(extendedRelation)
                                        }
                                    }
                                    relations.close()
                                }
                            } catch {
                                print("Error getting relations from the GeoPackage \(error)")
                                relations.close()
                            }
                        }
                        let attributeId = row.idValue()
                        for relation in attributeMediaTables {
                            var relatedMedia = rte?.mappings(forTableName: relation.mappingTableName, withBaseId: attributeId)
                            let mediaDao = rte?.mediaDao(forTableName: relation.relatedTableName)
                            attributeMedias.append(contentsOf: mediaDao?.rows(withIds: relatedMedia) ?? [])
                        }
                        
                        var values: [String : AnyHashable] = [:]
                        var attributeDataTypes: [String : String] = [:]
                        
                        for i in 0...(row.columnCount() - 1) {
                            let value = row.value(with: i)
                            let columnName = self.displayColumnName(dataColumnsDao: dataColumnsDao, attributeRow: row, columnName: row.columnName(with: i))
                            if let dataType = GPKGDataTypes.name(row.attributesColumns.columns()[Int(i)].dataType) {
                                attributeDataTypes[columnName] = dataType
                            }
                        }
                        
                        let attributeRowData = GPKGFeatureRowData(values: values, andGeometryColumnName: nil)
                        let featureItem = GeoPackageFeatureItem(layerName: layerName, featureId: Int(attributeId), featureRowData: attributeRowData, featureDataTypes: attributeDataTypes, coordinate: coordinate, mediaRows: attributeMedias)
                        attributeFeatureRowData.append(featureItem)
                    }
                    
                    var style: GPKGStyleRow?
                    var image: UIImage?

                    if let featureTiles = GPKGFeatureTiles(geoPackage: geoPackage, andFeatureDao: featureDao), let featureTableStyles = featureTiles.featureTableStyles, let featureStyle = featureTableStyles.featureStyle(withFeature: featureRow) {

                        if featureStyle.hasIcon() {
                            image = featureStyle.icon.dataImage()
                        }
                        style = featureStyle.style
                    }
                    
                    let featureItem = GeoPackageFeatureItem(layerName: layerName, featureId: Int(featureId), featureRowData: featureRowData, featureDataTypes: featureDataTypes, coordinate: coordinate, icon: image, style: style, mediaRows: media, attributeRows: attributeFeatureRowData)
                    featureItems.append(featureItem)
                }
            }
        }
        return featureItems
    }
}

extension GPKGFeatureIndexResults: Sequence {
    public func makeIterator() -> NSFastEnumerationIterator {
        return NSFastEnumerationIterator(self)
    }
}
