//
//  GeoPackageExporter.swift
//  Marlin
//
//  Created by Daniel Barela on 6/23/23.
//

import Foundation
import geopackage_ios
import ExceptionCatcher
import CoreData

class DataSourceExportRequest: Identifiable, Hashable, Equatable, ObservableObject {
    
    static func == (lhs: DataSourceExportRequest, rhs: DataSourceExportRequest) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: String { dataSourceItem.key }
    var dataSourceItem: DataSourceItem
    @Published var filters: [DataSourceFilterParameter]?
    @Published var count: Int = 0
    @Published var progress: DataSourceExportProgress
    
    init(dataSourceItem: DataSourceItem, filters: [DataSourceFilterParameter]?) {
        self.dataSourceItem = dataSourceItem
        self.filters = filters
        progress = DataSourceExportProgress(dataSourceItem: dataSourceItem)
    }
    
    func fetchRequest() -> NSFetchRequest<any NSFetchRequestResult>? {
        guard let dataSource = self.dataSourceItem.dataSource as? NSManagedObject.Type else {
            return nil
        }
        let fetchRequest = dataSource.fetchRequest()
        var predicates: [NSPredicate] = []
        if let filters = filters {
            for filter in filters {
                if let predicate = filter.toPredicate() {
                    predicates.append(predicate)
                }
            }
        }
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        fetchRequest.predicate = predicate
        return fetchRequest
    }
}

class DataSourceExportProgress: Identifiable, Hashable, Equatable, ObservableObject {
    static func == (lhs: DataSourceExportProgress, rhs: DataSourceExportProgress) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: String { dataSourceItem.key }
    var dataSourceItem: DataSourceItem
    @Published var complete: Bool = false
    @Published var exporting: Bool = false
    @Published var totalCount: Float = 0.0
    @Published var exportCount: Float = 0.0
    
    init(dataSourceItem: DataSourceItem) {
        self.dataSourceItem = dataSourceItem
    }
}

class GeoPackageExporter: ObservableObject {
    var manager: GPKGGeoPackageManager = GPKGGeoPackageFactory.manager()
    @Published var exportRequest: [DataSourceExportRequest]?
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
            
            for request in exportRequest {
                guard let dataSource = request.dataSourceItem.dataSource as? GeoPackageExportable.Type else {
                    continue
                }
                
                var filters = request.filters
                if filters == nil, let dataSource = dataSource as? any DataSource.Type {
                    filters = UserDefaults.standard.filter(dataSource)
                }
                
                let exportProgress = request.progress
                DispatchQueue.main.async {
                    if let fetchRequest = dataSource.fetchRequest(filters: filters) {
                        exportProgress.totalCount = Float((try? PersistenceController.current.viewContext.count(for: fetchRequest)) ?? 0)
                    }
                }
            }
            
            print("Begining export to \(geoPackage.path ?? "who knows")")
            let rtree = GPKGRTreeIndexExtension(geoPackage: geoPackage)
            
            for request in exportRequest {
                guard let dataSource = request.dataSourceItem.dataSource as? GeoPackageExportable.Type else {
                    continue
                }
                do {
                    guard let table = try dataSource.self.createTable(geoPackage: geoPackage), let featureTableStyles = GPKGFeatureTableStyles(geoPackage: geoPackage, andTable: table) else {
                        continue
                    }

                    let styles = dataSource.self.createStyles(tableStyles: featureTableStyles)
                    var filters = request.filters
                    if filters == nil, let dataSource = dataSource as? any DataSource.Type {
                        filters = UserDefaults.standard.filter(dataSource)
                    }
                    
                    let exportProgress = request.progress
                    DispatchQueue.main.async {
                        if let fetchRequest = dataSource.fetchRequest(filters: filters) {
                            exportProgress.totalCount = Float((try? PersistenceController.current.viewContext.count(for: fetchRequest)) ?? 0)
                        }
                        exportProgress.exporting = true
                    }
                    try dataSource.createFeatures(geoPackage: geoPackage, table: table, filters: filters, styleRows: styles, dataSourceProgress: exportProgress)
                    rtree?.create(with: table)
                    DispatchQueue.main.async {
                        exportProgress.exporting = false
                        exportProgress.complete = true
                    }
                } catch {
                    DispatchQueue.main.async { [self] in
                        complete = false
                        exporting = false
                        creationError = error.localizedDescription
                        print("Error:", error.localizedDescription)
                    }
                }
            }
            print("GeoPackage created \(geoPackage.path ?? "who knows")")

            DispatchQueue.main.async {
                self.exporting = false
                self.complete = true
            }
        }
    }
}
