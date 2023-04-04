//
//  GeoPackageImporter.swift
//  Marlin
//
//  Created by Daniel Barela on 3/29/23.
//

import Foundation
import geopackage_ios
import ExceptionCatcher
import SwiftUI

class GeoPackageImportProgress: NSObject, ObservableObject, GPKGProgress {
    @Published var complete: Bool = false
    
    func setMax(_ max: Int32) {
        
    }
    
    func add(_ progress: Int32) {
        
    }
    
    func isActive() -> Bool {
        return !complete
    }
    
    func cleanupOnCancel() -> Bool {
        return false
    }
    
    func completed() {
        print("xxx progress completed")
        complete = true
    }
    
    func failureWithError(_ error: String!) {
        
    }
    
    
}

class GeoPackageImporter {
    var progress: GeoPackageImportProgress = GeoPackageImportProgress()
    
    func fileName(url: URL) -> String {
        url.deletingPathExtension().lastPathComponent
    }
    
    func alreadyImported(url: URL? = nil, name: String? = nil) -> Bool {
        if let url = url {
            let geoPackages = GPKGGeoPackageFactory.manager().databasesLike(fileName(url: url)) ?? []
            return geoPackages.count != 0
        } else if let name = name {
            let geoPackages = GPKGGeoPackageFactory.manager().databasesLike(name) ?? []
            return geoPackages.count != 0
        }
        return false
    }
    
    func uniqueName(url: URL) -> String {
        "\(url.deletingPathExtension().lastPathComponent)_\(Int(Date().timeIntervalSince1970))"
    }
    
    func importGeoPackage(url: URL, nameOverride: String? = nil, overwrite: Bool = false) -> String {
        let manager = GPKGGeoPackageFactory.manager()
        let name = nameOverride ?? url.deletingPathExtension().lastPathComponent
        do {
            try ExceptionCatcher.catch {
                manager?.importGeoPackage(from: url, withName: name, inDirectory: nil, andOverride: overwrite, andProgress: progress)
            }
        } catch {
            print("Error importing:", error.localizedDescription)
        }
        return name
    }
    
    func deleteGeoPackage(url: URL) {
        let manager = GPKGGeoPackageFactory.manager()
        let name = url.deletingPathExtension().lastPathComponent
        manager?.delete(name, andFile: true)
    }
}
