//
//  GeoPackageExporter.swift
//  Marlin
//
//  Created by Daniel Barela on 6/23/23.
//

import Foundation
import geopackage_ios
import ExceptionCatcher

class GeoPackageExporter: ObservableObject {
    var manager: GPKGGeoPackageManager = GPKGGeoPackageFactory.manager()
    var dataSources: [GeoPackageExportable.Type] = []
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
    
    func export(dataSources: [GeoPackageExportable.Type]) {
        self.dataSources = dataSources
        exporting = true
        complete = false
        backgroundExport()
    }
    
    private func backgroundExport() {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
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
            for dataSource in dataSources {
                do {
                    let table = try dataSource.self.createTable(geoPackage: geoPackage)
                    let filters = UserDefaults.standard.filter(dataSource)
                    let fetchRequest = dataSource.fetchRequest()
                    var predicates: [NSPredicate] = []
                    for filter in filters {
                        if let predicate = filter.toPredicate() {
                            predicates.append(predicate)
                        }
                    }
                    let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
                    var sort: [NSSortDescriptor] = []
                    let sortDescriptors = dataSource.defaultSort
                    for sortDescriptor in sortDescriptors {
                        sort.append(sortDescriptor.toNSSortDescriptor())
                    }

                    fetchRequest.sortDescriptors = sort
                    fetchRequest.predicate = predicate
                    let context = PersistenceController.current.newTaskContext()
                    try context.performAndWait {
                        let results = try context.fetch(fetchRequest)
                        for result in results where result is GeoPackageExportable {
                            if let gpExportable = result as? GeoPackageExportable, let table = table {
                                gpExportable.createFeature(geoPackage: geoPackage, table: table)
                            }
                        }
                    }
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
