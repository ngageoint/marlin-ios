//
//  GeoPackageExportViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 10/25/23.
//

import Foundation
import Combine

class GeoPackageExportViewModel: ObservableObject {
    var cancellable = Set<AnyCancellable>()

    var asamRepository: AsamRepositoryManager?
    var moduRepository: ModuRepositoryManager?
    var lightRepository: LightRepositoryManager?
    var portRepository: PortRepositoryManager?
    var dgpsRepository: DifferentialGPSStationRepositoryManager?
    var radioBeaconRepository: RadioBeaconRepositoryManager?
    var routeRepository: RouteRepositoryManager?
    
    @Published var exportProgresses: [DataSourceExportProgress] = []
    
    @Published var complete: Bool = false
    @Published var exporting: Bool = false
    @Published var creationError: String?
    
    @Published var dataSources: [any DataSourceDefinition] = []
    
    @Published var exporter: GeoPackageExporter = GeoPackageExporter()
    
    @Published var filterViewModels: [TemporaryFilterViewModel] = []
    @Published var commonViewModel: TemporaryFilterViewModel = TemporaryFilterViewModel(dataSource: DataSourceDefinitions.common.filterable, filters: [])
    
    
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
    
    func toggleDataSource(dataSource: (any DataSourceDefinition)?) {
        guard let dataSource = dataSource, !exporting else { return }
        if dataSources.contains(where: { definition in
            definition.key == dataSource.key
        }) {
            dataSources.removeAll { definition in
                definition.key == dataSource.key
            }
            guard let filterable = DataSourceDefinitions.filterableFromDefintion(dataSource) else {
                return
            }
            filterViewModels.removeAll { model in
                model.dataSource?.definition.key == filterable.definition.key
            }
        } else {
            dataSources.append(dataSource)
            guard let filterable = DataSourceDefinitions.filterableFromDefintion(dataSource) else {
                return
            }
            filterViewModels.append(TemporaryFilterViewModel(dataSource: filterable, filters: UserDefaults.standard.filter(filterable.definition)))
        }
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
    
    func export() {
        
        Metrics.shared.geoPackageExport(dataSources: filterViewModels.compactMap(\.dataSource))
        
        exporter.export()
    }
}
