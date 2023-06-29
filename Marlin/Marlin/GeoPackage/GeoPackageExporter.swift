//
//  GeoPackageExporter.swift
//  Marlin
//
//  Created by Daniel Barela on 6/23/23.
//

import Foundation
import geopackage_ios
import ExceptionCatcher

struct DataSourceExportRequest: Identifiable, Hashable, Equatable {
    
    static func == (lhs: DataSourceExportRequest, rhs: DataSourceExportRequest) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: String { dataSourceItem.key }
    var dataSourceItem: DataSourceItem
    var filters: [DataSourceFilterParameter]?
}

class GeoPackageExporter: ObservableObject {
    var manager: GPKGGeoPackageManager = GPKGGeoPackageFactory.manager()
    var exportRequest: [DataSourceExportRequest]?
    var geoPackage: GPKGGeoPackage?
    var filename: String?
    
    @Published var complete: Bool = false
    @Published var exporting: Bool = false
    @Published var creationError: String?
    
    func createGeoPackage() -> Bool {
        do {
            let created = try ExceptionCatcher.catch {
                let formatter = DateFormatter()
                formatter.dateFormat = "YYYYMMddHHmmss"
                let fileDate = formatter.string(from: Date())
                 let filename = "marlin_export\(fileDate)"
                
                if manager.create(filename) {
                    geoPackage = manager.open(filename)
                }
                self.filename = filename
                return geoPackage
            }
            geoPackage = created
            return geoPackage != nil
        } catch {
            DispatchQueue.main.async {
                self.creationError = error.localizedDescription
            }
            print("Error:", error.localizedDescription)
        }
        return false
    }
    
    func export(exportRequest: [DataSourceExportRequest]) {
        self.exportRequest = exportRequest
        exporting = true
        complete = false
        backgroundExport()
    }
    
    private func backgroundExport() {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            guard let exportRequest = exportRequest else {
                return
            }
            if !createGeoPackage() {
                DispatchQueue.main.async {
                    self.exporting = false
                    self.complete = false
                }
                return
            }
            guard let geoPackage = geoPackage else {
                DispatchQueue.main.async {
                    self.exporting = false
                    self.complete = false
                    self.creationError = "Unable to create GeoPackage file"
                }
                return
            }
            print("GeoPackage created \(geoPackage.path ?? "who knows")")
            let rtree = GPKGRTreeIndexExtension(geoPackage: geoPackage)
            
            for request in exportRequest {
                guard let dataSource = request.dataSourceItem.dataSource as? GeoPackageExportable.Type else {
                    continue
                }
                do {
                    guard let table = try dataSource.self.createTable(geoPackage: geoPackage) else {
                        continue
                    }
                    var filters = request.filters
                    if filters == nil, let dataSource = dataSource as? any DataSource.Type {
                        filters = UserDefaults.standard.filter(dataSource)
                    }
                    
                    try dataSource.createFeatures(geoPackage: geoPackage, table: table, filters: filters)
                    rtree?.create(with: table)
                } catch {
                    DispatchQueue.main.async { [self] in
                        complete = false
                        exporting = false
                        creationError = error.localizedDescription
                        print("Error:", error.localizedDescription)
                    }
                }
            }
            print("created table")
            
            DispatchQueue.main.async {
                self.exporting = false
                self.complete = true
            }
        }
    }
}
