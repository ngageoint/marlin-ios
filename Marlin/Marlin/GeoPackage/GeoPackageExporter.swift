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
import Combine

class DataSourceExportRequest: Identifiable, Hashable, Equatable, ObservableObject {
    
    static func == (lhs: DataSourceExportRequest, rhs: DataSourceExportRequest) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: String { dataSourceItem.key }
    var dataSourceItem: DataSourceItem
    @Published var filters: [DataSourceFilterParameter]? {
        didSet {
            print("set the filters")
        }
    }
    @Published var count: Int = 0
    
    init(dataSourceItem: DataSourceItem, filters: [DataSourceFilterParameter]?) {
        self.dataSourceItem = dataSourceItem
        self.filters = filters
    }
    
    func fetchRequest(commonFilters: [DataSourceFilterParameter]?) -> NSFetchRequest<any NSFetchRequestResult>? {
        return self.dataSourceItem.dataSource.fetchRequest(filters: filters, commonFilters: commonFilters)
    }
}

class DataSourceExportProgress: Identifiable, Hashable, Equatable, ObservableObject {
    static func == (lhs: DataSourceExportProgress, rhs: DataSourceExportProgress) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: String { dataSource.key }
    var dataSource: DataSource.Type
    @Published var complete: Bool = false
    @Published var exporting: Bool = false
    @Published var totalCount: Float = 0.0
    @Published var exportCount: Float = 0.0
    
    init(dataSource: DataSource.Type) {
        self.dataSource = dataSource
    }
}

class GeoPackageExporter: ObservableObject {
    var cancellable = Set<AnyCancellable>()

    var manager: GPKGGeoPackageManager = GPKGGeoPackageFactory.manager()
    @Published var filterViewModels: [TemporaryFilterViewModel] = []
    @Published var commonViewModel: TemporaryFilterViewModel = TemporaryFilterViewModel(dataSource: CommonDataSource.self, filters: [])
    
    var commonFilters: [DataSourceFilterParameter]?
    var geoPackage: GPKGGeoPackage?
    var filename: String?
    
    @Published var exportProgresses: [DataSourceExportProgress] = []
    
    @Published var complete: Bool = false
    @Published var exporting: Bool = false
    @Published var creationError: String?
    
    init() {
        commonViewModel.$filters
            .receive(on: RunLoop.main)
            .sink() { [self] commonFilters in
                print("common filters changed")
                for viewModel in self.filterViewModels {
                    viewModel.commonFilters = commonFilters
                }
            }
            .store(in: &cancellable)
    }
    
    func setExportRequests(exportRequests: [DataSourceExportRequest]) {
        for request in exportRequests.filter({ request in
            request.dataSourceItem.dataSource.key != CommonDataSource.key
        }) {
            let model = TemporaryFilterViewModel(dataSource: request.dataSourceItem.dataSource, filters: request.filters)
            filterViewModels.append(model)
        }
        
        if let commonRequest = exportRequests.first(where: { request in
            request.dataSourceItem.dataSource.key == CommonDataSource.key
        }) {
            if let filters = commonRequest.filters {
                commonViewModel.filters = filters
            }
        }
    }
    
    func addExportDataSource(dataSourceItem: DataSourceItem) {
        filterViewModels.append(TemporaryFilterViewModel(dataSource: dataSourceItem.dataSource, filters: UserDefaults.standard.filter(dataSourceItem.dataSource)))
    }
    
    func removeExportDataSource(dataSourceItem: DataSourceItem) {
        filterViewModels.removeAll { model in
            model.dataSource.key == dataSourceItem.key
        }
    }
        
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
    
    func export() {
        exporting = true
        complete = false
        backgroundExport()
        Metrics.shared.geoPackageExport(dataSources: filterViewModels.map(\.dataSource))
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
            
            for viewModel in filterViewModels {
                let filters = viewModel.filters
                let exportProgress = DataSourceExportProgress(dataSource: viewModel.dataSource)
                DispatchQueue.main.sync {
                    self.exportProgresses.append(exportProgress)
                    if let fetchRequest = viewModel.dataSource.fetchRequest(filters: filters, commonFilters: viewModel.commonFilters) {
                        exportProgress.totalCount = Float((try? PersistenceController.current.viewContext.count(for: fetchRequest)) ?? 0)
                    }
                }
            }
            
            print("Begining export to \(geoPackage.path ?? "who knows")")
            let rtree = GPKGRTreeIndexExtension(geoPackage: geoPackage)
            
            for viewModel in filterViewModels {
                guard let dataSource = viewModel.dataSource as? GeoPackageExportable.Type, let exportProgress = exportProgresses.first(where: { progress in
                    progress.dataSource.key == viewModel.dataSource.key
                }) else {
                    continue
                }
                do {
                    guard let table = try dataSource.self.createTable(geoPackage: geoPackage), let featureTableStyles = GPKGFeatureTableStyles(geoPackage: geoPackage, andTable: table) else {
                        continue
                    }

                    let styles = dataSource.self.createStyles(tableStyles: featureTableStyles)

                    DispatchQueue.main.async {
                        if let fetchRequest = viewModel.dataSource.fetchRequest(filters: viewModel.filters, commonFilters: viewModel.commonFilters) {
                            exportProgress.totalCount = Float((try? PersistenceController.current.viewContext.count(for: fetchRequest)) ?? 0)
                        }
                        exportProgress.exporting = true
                    }
                    try dataSource.createFeatures(geoPackage: geoPackage, table: table, filters: viewModel.filters, commonFilters: viewModel.commonFilters, styleRows: styles, dataSourceProgress: exportProgress)
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
