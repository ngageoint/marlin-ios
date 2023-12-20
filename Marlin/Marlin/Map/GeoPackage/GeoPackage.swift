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
    
    func deleteGeoPackage(name: String) -> Bool {
        cache.close(byName: name)
        cache.remove(byName: name)
        return manager.delete(name, andFile: true)
    }
    
    func getGeoPackage(name: String) -> GPKGGeoPackage? {
        return try? ExceptionCatcher.catch {
            return cache.geoPackageOpenName(name)
        }
    }
    
    func dataColumnsDao(database: GPKGConnection) -> GPKGDataColumnsDao? {
        let dataColumnsDao = GPKGDataColumnsDao(database: database)
        
        if !(dataColumnsDao?.tableExists() ?? false) {
            return nil
        }
        
        return dataColumnsDao
    }
    
    func displayColumnName(
        dataColumnsDao: GPKGDataColumnsDao?,
        featureRow: GPKGFeatureRow,
        columnName: String) -> String {
        if let dataColumnsDao = dataColumnsDao, 
            let dataColumn = dataColumnsDao.dataColumn(
                byTableName: featureRow.table.tableName,
                andColumnName: columnName) {
            return dataColumn.name
        }
        return columnName
    }
    
    func displayColumnName(
        dataColumnsDao: GPKGDataColumnsDao?,
        attributeRow: GPKGAttributesRow,
        columnName: String) -> String {
        if let dataColumnsDao = dataColumnsDao, 
            let dataColumn = dataColumnsDao.dataColumn(
                byTableName: attributeRow.table.tableName,
                andColumnName: columnName) {
            return dataColumn.name
        }
        return columnName
    }
    
    func getFeature(geoPackageName: String, tableName: String, featureId: Int) -> GeoPackageFeatureItem? {
        guard let geoPackage = GeoPackage.shared.getGeoPackage(name: geoPackageName) else {
            return nil
        }
        if !GPKGContentsDataTypes.isFeaturesType(geoPackage.type(ofTable: tableName)) {
            return nil
        }

        guard let featureDao = geoPackage.featureDao(withTableName: tableName) else {
            return nil
        }
        
        let rte = GPKGRelatedTablesExtension(geoPackage: geoPackage)
        
        var mediaTables: [GPKGExtendedRelation] = []
        var attributeTables: [GPKGExtendedRelation] = []
        
        if let relationsDao = GPKGExtendedRelationsDao(database: geoPackage.database),
            relationsDao.tableExists(),
            let relations = relationsDao.relations(toBaseTable: tableName) {
            do {
                try ExceptionCatcher.catch {
                    while relations.moveToNext() {
                        let extendedRelation: GPKGExtendedRelation = relationsDao.relation(relations)
                        if extendedRelation.relationType() == GPKGRelationTypes.fromName("media") {
                            mediaTables.append(extendedRelation)
                        } else
                        if extendedRelation.relationType() == GPKGRelationTypes.fromName("attributes")
                        || extendedRelation.relationType() == GPKGRelationTypes.fromName("simple_attributes") {
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
        
        let result = featureDao.query(forIdRow: Int32(featureId))
        if let featureRow = result as? GPKGFeatureRow,
           let featureItem = rowToFeatureItem(
            featureRow: featureRow,
            geoPackage: geoPackage,
            rte: rte,
            mediaTables: mediaTables,
            attributeTables: attributeTables,
            dataColumnsDao: dataColumnsDao,
            featureDao: featureDao,
            layerName: nil) {
            return featureItem
        }
        
        return nil
    }
    
    func getFeaturesFromTable(
        at location: CLLocationCoordinate2D,
        mapView: MKMapView,
        table: String,
        geoPackageName: String,
        layerName: String) -> [GeoPackageFeatureItem] {
        var featureItems: [GeoPackageFeatureItem] = []
        guard let geoPackage = GeoPackage.shared.getGeoPackage(name: geoPackageName),
              GPKGContentsDataTypes.isFeaturesType(geoPackage.type(ofTable: table)) else {
            return []
        }

        if let boundingBox = GPKGMapUtils.buildClickBoundingBox(
            with: GPKGMapUtils.buildClickLocationBoundingBox(
                with: location,
                andMapView: mapView,
                andScreenPercentage: 0.03)),
            let featureDao = geoPackage.featureDao(
                withTableName: table),
            let indexManager = GPKGFeatureIndexManager(
                geoPackage: geoPackage,
                andFeatureDao: featureDao) {

            let rte = GPKGRelatedTablesExtension(geoPackage: geoPackage)
            
            var mediaTables: [GPKGExtendedRelation] = []
            var attributeTables: [GPKGExtendedRelation] = []
            
            if let relationsDao = GPKGExtendedRelationsDao(database: geoPackage.database),
               relationsDao.tableExists(),
                let relations = relationsDao.relations(toBaseTable: table) {
                do {
                    try ExceptionCatcher.catch {
                        while relations.moveToNext() {
                            let extendedRelation: GPKGExtendedRelation = relationsDao.relation(relations)
                            if extendedRelation.relationType() == GPKGRelationTypes.fromName("media") {
                                mediaTables.append(extendedRelation)
                            } else 
                            if extendedRelation.relationType() == GPKGRelationTypes.fromName("attributes")
                                || extendedRelation.relationType() == GPKGRelationTypes.fromName("simple_attributes") {
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

            if let results = indexManager.query(
                with: boundingBox,
                in: PROJProjectionFactory.projection(withEpsgInt: 4326)) {
                for row in results {
                    if let featureRow = row as? GPKGFeatureRow, 
                        let featureItem = rowToFeatureItem(
                            featureRow: featureRow,
                            geoPackage: geoPackage,
                            rte: rte,
                            mediaTables: mediaTables,
                            attributeTables: attributeTables,
                            dataColumnsDao: dataColumnsDao,
                            featureDao: featureDao,
                            layerName: layerName) {
                        featureItems.append(featureItem)
                    }
                }
            }
        }
        return featureItems
    }

    func mediaForFeature(
        featureId: Int32,
        rte: GPKGRelatedTablesExtension?,
        mediaTables: [GPKGExtendedRelation]
    ) -> [GPKGMediaRow] {
        var media: [GPKGMediaRow] = []

        for relation in mediaTables {
            let relatedMedia = rte?.mappings(forTableName: relation.mappingTableName, withBaseId: featureId)
            let mediaDao = rte?.mediaDao(forTableName: relation.relatedTableName)
            media.append(contentsOf: mediaDao?.rows(withIds: relatedMedia) ?? [])
        }

        return media
    }

    func attributesForFeature(
        featureId: Int32,
        rte: GPKGRelatedTablesExtension?,
        attributeTables: [GPKGExtendedRelation]
    ) -> [GPKGAttributesRow] {
        var attributes: [GPKGAttributesRow] = []

        for relation in attributeTables {
            let relatedAttributes = rte?.mappings(forTableName: relation.mappingTableName, withBaseId: featureId) ?? []
            let attributesDao = rte?.geoPackage.attributesDao(withTableName: relation.relatedTableName)

            for relatedAttribute in relatedAttributes {
                if let row = attributesDao?.query(forIdObject: relatedAttribute) as? GPKGAttributesRow {
                    attributes.append(row)
                }
            }
        }
        return attributes
    }

    func mediaForAttribute(
        geoPackage: GPKGGeoPackage,
        rte: GPKGRelatedTablesExtension?,
        row: GPKGAttributesRow
    ) -> [GPKGMediaRow] {
        var attributeMediaTables: [GPKGExtendedRelation] = []
        var attributeMedias: [GPKGMediaRow] = []
        if let relationsDao = GPKGExtendedRelationsDao(database: geoPackage.database),
           relationsDao.tableExists(),
           let relations = relationsDao.relations(toBaseTable: row.attributesTable.tableName()) {
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
            let relatedMedia = rte?.mappings(forTableName: relation.mappingTableName, withBaseId: attributeId)
            let mediaDao = rte?.mediaDao(forTableName: relation.relatedTableName)
            attributeMedias.append(contentsOf: mediaDao?.rows(withIds: relatedMedia) ?? [])
        }
        return attributeMedias
    }

    private struct StyleAndIcon {
        var style: GPKGStyleRow?
        var image: UIImage?
    }

    private func getFeatureStyle(
        geoPackage: GPKGGeoPackage,
        featureDao: GPKGFeatureDao,
        featureRow: GPKGFeatureRow
    ) -> StyleAndIcon? {
        var styleAndIcon: StyleAndIcon?
        do {
            try ExceptionCatcher.catch {
                let featureTiles = GPKGFeatureTiles(
                    geoPackage: geoPackage,
                    andFeatureDao: featureDao)
                if let featureTiles = featureTiles,
                   let featureTableStyles = featureTiles.featureTableStyles,
                   let featureStyle = featureTableStyles.featureStyle(withFeature: featureRow) {
                    if featureStyle.hasIcon() {
                        styleAndIcon = StyleAndIcon(style: featureStyle.style, image: featureStyle.icon.dataImage())
                    } else {
                        styleAndIcon = StyleAndIcon(style: featureStyle.style)
                    }
                }
                featureTiles?.close()
            }
        } catch {
            print("Exception \(error)")
        }
        return styleAndIcon
    }

    func rowToFeatureItem(
        featureRow: GPKGFeatureRow,
        geoPackage: GPKGGeoPackage,
        rte: GPKGRelatedTablesExtension?,
        mediaTables: [GPKGExtendedRelation],
        attributeTables: [GPKGExtendedRelation],
        dataColumnsDao: GPKGDataColumnsDao?,
        featureDao: GPKGFeatureDao,
        layerName: String?
    ) -> GeoPackageFeatureItem? {

        let featureId = featureRow.idValue()
        let media = mediaForFeature(featureId: featureId, rte: rte, mediaTables: mediaTables)
        
        let attributes = attributesForFeature(featureId: featureId, rte: rte, attributeTables: attributeTables)

        var values: [String: AnyHashable] = [:]
        var featureDataTypes: [String: String] = [:]
        let geometryColumn = featureRow.geometryColumnIndex()
        var geometryColumnName: String?
        
        var coordinate: CLLocationCoordinate2D?
        
        for i in 0...(featureRow.columnCount() - 1) {
            let value = featureRow.value(with: i)
            let columnName = self.displayColumnName(
                dataColumnsDao: dataColumnsDao,
                featureRow: featureRow,
                columnName: featureRow.columnName(with: i))
            if i == geometryColumn {
                geometryColumnName = columnName
                if let geometry = value as? GPKGGeometryData {
                    let centroid = geometry.geometry.centroid()
                    let transform = SFPGeometryTransform(from: featureDao.projection, andToEpsg: 4326)
                    if let centroid = transform?.transform(centroid) {
                        coordinate = CLLocationCoordinate2D(
                            latitude: centroid.y.doubleValue,
                            longitude: centroid.x.doubleValue)
                    }
                    transform?.destroy()
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
            let attributeId = row.idValue()
            let attributeMedias: [GPKGMediaRow] = mediaForAttribute(geoPackage: geoPackage, rte: rte, row: row)

            let values: [String: AnyHashable] = [:]
            var attributeDataTypes: [String: String] = [:]

            for i in 0...(row.columnCount() - 1) {
                let columnName = self.displayColumnName(
                    dataColumnsDao: dataColumnsDao, 
                    attributeRow: row,
                    columnName: row.columnName(with: i))
                if let dataType = GPKGDataTypes.name(row.attributesColumns.columns()[Int(i)].dataType) {
                    attributeDataTypes[columnName] = dataType
                }
            }
            
            let attributeRowData = GPKGFeatureRowData(values: values, andGeometryColumnName: nil)
            let featureItem = GeoPackageFeatureItem(
                layerName: layerName,
                geoPackageName: geoPackage.name,
                tableName: featureRow.tableName(),
                featureId: Int(attributeId),
                featureRowData: attributeRowData,
                featureDataTypes: attributeDataTypes,
                coordinate: coordinate ?? kCLLocationCoordinate2DInvalid,
                mediaRows: attributeMedias)
            attributeFeatureRowData.append(featureItem)
        }
        
        let featureStyle = getFeatureStyle(geoPackage: geoPackage, featureDao: featureDao, featureRow: featureRow)
        let style: GPKGStyleRow? = featureStyle?.style
        let image: UIImage? = featureStyle?.image
        
        let featureItem = GeoPackageFeatureItem(
            layerName: layerName,
            geoPackageName: geoPackage.name,
            tableName: featureRow.tableName(),
            featureId: Int(featureId),
            featureRowData: featureRowData,
            featureDataTypes: featureDataTypes,
            coordinate: coordinate ?? kCLLocationCoordinate2DInvalid,
            icon: image,
            style: style,
            mediaRows: media,
            attributeRows: attributeFeatureRowData)
        return featureItem
    }
}

extension GPKGFeatureIndexResults: Sequence {
    public func makeIterator() -> NSFastEnumerationIterator {
        return NSFastEnumerationIterator(self)
    }
}
