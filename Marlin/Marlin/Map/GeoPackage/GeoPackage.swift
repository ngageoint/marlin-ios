//
//  GeoPackage.swift
//  Marlin
//
//  Created by Daniel Barela on 3/27/23.
//

import Foundation
import geopackage_ios

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
}
