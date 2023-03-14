//
//  GeoPackageMap.swift
//  Marlin
//
//  Created by Daniel Barela on 6/29/22.
//

import Foundation
import MapKit
import geopackage_ios
import SwiftUI

class GeoPackageMap: NSObject, MapMixin {
    
    var geopackageImportedObserver: AnyObject?
        
    var geoPackageManager: GPKGGeoPackageManager?
    var geoPackageCache: GPKGGeoPackageCache?
    
    var geoPackage: GeoPackage?
    
    var fileName: String
    var tableName: String
    var fillColor: UIColor?
    var polygonColor: UIColor?
    var canReplaceMapContent: Bool = false
    var index: Int = 0
    
    init(fileName: String, tableName: String, polygonColor: UIColor? = nil, fillColor: UIColor? = nil, canReplaceMapContent: Bool = false, index: Int = 0) {
        self.fileName = fileName
        self.tableName = tableName
        self.fillColor = fillColor
        self.polygonColor = polygonColor
        self.canReplaceMapContent = canReplaceMapContent
        self.index = index
    }
    
    func setupMixin(marlinMap: MarlinMap, mapView: MKMapView) {
        geoPackage = GeoPackage(mapView: mapView, fileName: fileName, tableName: tableName, polygonColor: polygonColor, fillColor: fillColor, canReplaceMapContent: canReplaceMapContent, index: index)
        if let overlay = geoPackage?.getOverlay() {
            DispatchQueue.main.async {
                marlinMap.mapState.overlays.insert(overlay, at: min(self.index, marlinMap.mapState.overlays.count))
            }
        }
    }
    
    func updateMixin(mapView: MKMapView, mapState: MapState) {
    }
    
    func items(at location: CLLocationCoordinate2D) -> [Any]? {
        return nil
//        return geoPackage?.getFeaturesAtLocation(location: location)
    }
}
