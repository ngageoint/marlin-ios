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
    
    var id: String { filterable?.definition.key ?? "" }
    var filterable: Filterable?
    @Published var filters: [DataSourceFilterParameter]? {
        didSet {
            print("set the filters")
        }
    }
    @Published var count: Int = 0
    
    init(filterable: Filterable?, filters: [DataSourceFilterParameter]?) {
        self.filterable = filterable
        self.filters = filters
    }
    
    func fetchRequest(commonFilters: [DataSourceFilterParameter]?) -> NSFetchRequest<any NSFetchRequestResult>? {
        return filterable?.fetchRequest(filters: filters, commonFilters: commonFilters)
    }
}

class DataSourceExportProgress: Identifiable, Hashable, Equatable, ObservableObject {
    static func == (lhs: DataSourceExportProgress, rhs: DataSourceExportProgress) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: String { filterable.definition.key }
    var filterable: Filterable
    @Published var complete: Bool = false
    @Published var exporting: Bool = false
    @Published var totalCount: Float = 0.0
    @Published var exportCount: Float = 0.0
    
    init(filterable: Filterable) {
        self.filterable = filterable
    }
}

class GeoPackageExporter: ObservableObject {
    var cancellable = Set<AnyCancellable>()

    var manager: GPKGGeoPackageManager = GPKGGeoPackageFactory.manager()
    @Published var filterViewModels: [TemporaryFilterViewModel] = []
    @Published var commonViewModel: TemporaryFilterViewModel = TemporaryFilterViewModel(dataSource: DataSourceDefinitions.common.filterable, filters: [])
    
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
            request.filterable?.definition.key != CommonDataSource.key
        }) {
            let model = TemporaryFilterViewModel(dataSource: request.filterable, filters: request.filters)
            filterViewModels.append(model)
        }
        
        if let commonRequest = exportRequests.first(where: { request in
            request.filterable?.definition.key == CommonDataSource.key
        }) {
            if let filters = commonRequest.filters {
                commonViewModel.filters = filters
            }
        }
    }
    
    func addExportDataSource(filterable: Filterable?) {
        guard let filterable = filterable else {
            return
        }
        filterViewModels.append(TemporaryFilterViewModel(dataSource: filterable, filters: UserDefaults.standard.filter(filterable.definition)))
    }
    
    func removeExportDataSource(filterable: Filterable?) {
        guard let filterable = filterable else {
            return
        }
        filterViewModels.removeAll { model in
            model.dataSource?.definition.key == filterable.definition.key
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
        Metrics.shared.geoPackageExport(dataSources: filterViewModels.compactMap(\.dataSource))
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
                if let filterable = viewModel.dataSource {
                    let exportProgress = DataSourceExportProgress(filterable: filterable)
                    DispatchQueue.main.sync {
                        self.exportProgresses.append(exportProgress)
                        if let fetchRequest = filterable.fetchRequest(filters: filters, commonFilters: viewModel.commonFilters) {
                            exportProgress.totalCount = Float((try? PersistenceController.current.viewContext.count(for: fetchRequest)) ?? 0)
                        }
                    }
                }
            }
            
            print("Begining export to \(geoPackage.path ?? "who knows")")
            let rtree = GPKGRTreeIndexExtension(geoPackage: geoPackage)
            
            for viewModel in filterViewModels {
                guard let dataSource = viewModel.dataSource as? GeoPackageExportable.Type, let exportProgress = exportProgresses.first(where: { progress in
                    progress.filterable.definition.key == viewModel.dataSource?.definition.key
                }) else {
                    continue
                }
                do {
                    guard let table = try dataSource.self.createTable(geoPackage: geoPackage), let featureTableStyles = GPKGFeatureTableStyles(geoPackage: geoPackage, andTable: table) else {
                        continue
                    }

                    let styles = dataSource.self.createStyles(tableStyles: featureTableStyles)

                    DispatchQueue.main.async {
                        if let fetchRequest = viewModel.dataSource?.fetchRequest(filters: viewModel.filters, commonFilters: viewModel.commonFilters) {
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
