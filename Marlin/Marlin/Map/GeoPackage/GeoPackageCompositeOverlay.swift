//
//  GeoPackageCompositeOverlay.swift
//  Marlin
//
//  Created by Daniel Barela on 3/27/23.
//

import Foundation
import MapKit
import geopackage_ios

class GeopackageCompositeOverlay: MKTileOverlay {

    var layer: MapLayerViewModel?
    var mapLayer: MapLayer?
    var geoPackage: GPKGGeoPackage?
    var geoPackageName: String?
    var tableNames: [String] = []
    var tileTables: [GPKGBoundedOverlay] = []
    var featureTables: [GPKGFeatureTiles] = []
    
    @objc public var fillColor: UIColor = UIColor.clear
    
    init(layer: MapLayerViewModel) {
        self.layer = layer
        super.init(urlTemplate: nil)
        tileSize = CGSize(width: 512, height: 512)
        self.minimumZ = layer.minimumZoom
        self.maximumZ = layer.maximumZoom
        self.tableNames = layer.selectedFileLayers.map { $0.name }
        self.geoPackageName = layer.fileName
        openGeoPackage()
        createOverlays()
    }
    
    init(mapLayer: MapLayer) {
        self.mapLayer = mapLayer
        super.init(urlTemplate: nil)
        tileSize = CGSize(width: 512, height: 512)
        self.minimumZ = Int(mapLayer.minZoom)
        self.maximumZ = Int(mapLayer.maxZoom)
        self.tableNames = mapLayer.layerNames
        self.geoPackageName = mapLayer.name
        openGeoPackage()
        createOverlays()
    }
    
    func openGeoPackage() {
        guard let geoPackageName = geoPackageName else {
            return
        }
        geoPackage = GeoPackage.shared.getGeoPackage(name: geoPackageName)
    }
    
    func createOverlays() {
        guard let geoPackage = geoPackage else {
            return
        }
        for table in tableNames {
            if let type = geoPackage.type(ofTable: table) {
                if GPKGContentsDataTypes.isTilesType(type) {
                    if let tileDao = geoPackage.tileDao(withTableName: table), let overlay = GPKGOverlayFactory.boundedOverlay(tileDao) {
                        tileTables.append(overlay)
                    }
                } else if GPKGContentsDataTypes.isFeaturesType(type) {
                    if let featureDao = geoPackage.featureDao(withTableName: table), let featureTiles = GPKGFeatureTiles(geoPackage: geoPackage, andFeatureDao: featureDao) {
                        featureTiles.indexManager = GPKGFeatureIndexManager(geoPackage: geoPackage, andFeatureDao: featureDao)
                        featureTables.append(featureTiles)
                    }
                }
            }
        }
    }
    
    override func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void) {
        var images: [UIImage] = []
        for tileTable in tileTables {
            if tileTable.hasTileWith(x: path.x, andY: path.y, andZoom: path.z) {
                if let data = tileTable.retrieveTileWith(x: path.x, andY: path.y, andZoom: path.z) {
                    images.append(GPKGImageConverter.toImage(data, withScale: tileTable.tileSize.width / 512.0))
                }
            }
        }
        for featureTable in featureTables {
            if let featureImage = featureTable.drawTileWith(x: Int32(path.x), andY: Int32(path.y), andZoom: Int32(path.z)) {
                images.append(featureImage)
            }
        }
        
        var currentImage: UIImage?
        for image in images {
            currentImage = UIImage.combineCentered(image1: currentImage, image2: image)
        }
        result(GPKGImageConverter.toData(currentImage, andFormat: GPKGCompressFormats.fromName(GPKG_CF_PNG_NAME)), nil)
    }
}
