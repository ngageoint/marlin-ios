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
    
    init(fileName: String, tableName: String) {
        self.fileName = fileName
        self.tableName = tableName
    }
    
    func setupMixin(mapView: MKMapView, marlinMap: MarlinMap, scheme: MarlinScheme?) {
        geoPackage = GeoPackage(mapView: mapView, fileName: self.fileName, tableName: self.tableName)
        geoPackage?.addOverlay()
    }
    
    func updateMixin() {
        geoPackage?.updateLayers()
    }
    
    func items(at location: CLLocationCoordinate2D) -> [Any]? {
        return geoPackage?.getFeaturesAtLocation(location: location)
    }
}
