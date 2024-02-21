//
//  GeoPackageExportViewModel.swift
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

class GeoPackageExportViewModel: ObservableObject {
    var asamRepository: AsamRepository?
    var moduRepository: ModuRepositoryManager?
    var lightRepository: LightRepositoryManager?
    var portRepository: PortRepositoryManager?
    var dgpsRepository: DifferentialGPSStationRepositoryManager?
    var radioBeaconRepository: RadioBeaconRepositoryManager?
    var routeRepository: RouteRepositoryManager?
    var navigationalWarningRepository: NavigationalWarningRepositoryManager?
    
    var cancellable = Set<AnyCancellable>()
    var countChangeCancellable: AnyCancellable?

    var manager: GPKGGeoPackageManager = GPKGGeoPackageFactory.manager()
    @Published var filterViewModels: [DataSourceDefinitions: FilterViewModel] = [:]
    @Published var commonViewModel: FilterViewModel = TemporaryFilterViewModel(
        dataSource: DataSourceDefinitions.common.filterable,
        filters: []
    )

    var geoPackage: GPKGGeoPackage?
    var filename: String?
    
    @Published var dataSources: [any DataSourceDefinition] = []
    
    @Published var exportProgresses: [DataSourceDefinitions: DataSourceExportProgress] = [:]
    
    @Published var complete: Bool = false
    @Published var exporting: Bool = false
    @Published var creationError: String?
    @Published var error: Bool = false
    
    @Published var counts: [DataSourceDefinitions: Int] = [:]
    
    init() {
        setupCombine()
    }
    
    func setupCombine() {
        // when the filterViewModels values changes, re-set up the filter subscriber
        $filterViewModels
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.bindFilters()
            }
            .store(in: &cancellable)
        
        $dataSources
            .receive(on: RunLoop.main)
            .sink { [weak self] dataSources in
                guard let self = self else { return }
                for dataSource in dataSources {
                    if let definitions = DataSourceDefinitions.from(dataSource), 
                        let filterable = definitions.filterable {
                        let exportProgress = DataSourceExportProgress(filterable: filterable)
                        self.exportProgresses[definitions] = exportProgress
                    }
                }
                NSLog("self export progresses \(self.exportProgresses)")
            }
            .store(in: &cancellable)
    }
    
    func bindFilters() {
        let observables = filterViewModels.values.map { Publishers.MergeMany($0.$filters) }
        let publisher = Publishers.MergeMany(observables)

        if let countChangeCancellable = countChangeCancellable {
            countChangeCancellable.cancel()
        }
        countChangeCancellable = Publishers.CombineLatest3($dataSources, commonViewModel.$filters, publisher)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.updateCounts()
            }
    }
    
    func getCount(definition: (any DataSourceDefinition)? = nil) -> Int? {
        if let def = DataSourceDefinitions.from(definition) {
            return counts[def]
        }
        return nil
    }

    var dataSourceDefinitions: [DataSourceDefinitions] {
        dataSources.compactMap { definition in
            DataSourceDefinitions.from(definition)
        }
    }
    
    func updateCounts() {
        NSLog("Update Counts commonFilters are \(self.commonViewModel.filters)")
        self.counts = dataSources.reduce(into: [DataSourceDefinitions: Int]()) {
            
            if let definition = DataSourceDefinitions.from($1) {
                let filters = (self.filterViewModels[definition]?.filters ?? []) + self.commonViewModel.filters
                
                switch definition {
                case .route: $0[definition] = self.routeRepository?.getCount(filters: filters)
                case .asam: $0[definition] = self.asamRepository?.getCount(filters: filters)
                case .modu: $0[definition] = self.moduRepository?.getCount(filters: filters)
                case .dgps: $0[definition] = self.dgpsRepository?.getCount(filters: filters)
                case .port: $0[definition] = self.portRepository?.getCount(filters: filters)
                case .navWarning: $0[definition] = self.navigationalWarningRepository?.getCount(filters: filters)
                case .light: $0[definition] = self.lightRepository?.getCount(filters: filters)
                case .radioBeacon: $0[definition] = self.radioBeaconRepository?.getCount(filters: filters)
                default: break
                }
            }
        }
    }
    
    func toggleDataSource(definition: any DataSourceDefinition) {
        if exporting {
            return
        }
        let included = dataSources.contains { dsDefinition in
            dsDefinition.key == definition.key
        }
        
        if included {
            removeExportDataSource(filterable: DataSourceDefinitions.filterableFromDefintion(definition))
        } else {
            addExportDataSource(filterable: DataSourceDefinitions.filterableFromDefintion(definition))
        }
    }
    
    func setExportParameters(
        dataSources: [DataSourceDefinitions],
        filters: [DataSourceFilterParameter]?,
        useMapRegion: Bool) {
        let region = UserDefaults.standard.mapRegion
        
        for dataSource in dataSources {
            toggleDataSource(definition: dataSource.definition)
            if let filters = filters {
                filterViewModels[dataSource]?.filters.append(contentsOf: filters)
            }
        }
        
        if useMapRegion {
            commonViewModel.filters = [
                DataSourceFilterParameter(
                    property: DataSourceProperty(name: "Location",
                                                 key: #keyPath(CommonDataSource.coordinate),
                                                 type: .location),
                    comparison: .bounds,
                    valueMinLatitude: region.center.latitude - (region.span.latitudeDelta / 2.0),
                    valueMinLongitude: region.center.longitude - (region.span.longitudeDelta / 2.0),
                    valueMaxLatitude: region.center.latitude + (region.span.latitudeDelta / 2.0),
                    valueMaxLongitude: region.center.longitude + (region.span.longitudeDelta / 2.0))
            ]
        }
    }
    
    func addExportDataSource(filterable: Filterable?) {
        guard let filterable = filterable, let def = DataSourceDefinitions.from(filterable.definition) else {
            return
        }
        filterViewModels[def] = TemporaryFilterViewModel(
            dataSource: filterable,
            filters: UserDefaults.standard.filter(filterable.definition))
        dataSources.append(filterable.definition)
    }
    
    func removeExportDataSource(filterable: Filterable?) {
        guard let filterable = filterable, let def = DataSourceDefinitions.from(filterable.definition) else {
            return
        }
        filterViewModels.removeValue(forKey: def)
        dataSources.removeAll { definition in
            return definition.key == filterable.definition.key
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
                self.error = true
                self.creationError = error.localizedDescription
            }
            print("Error:", error.localizedDescription)
        }
        return false
    }
    
    func export() {
        exporting = true
        complete = false
        error = false
        exportProgresses.removeAll()
        backgroundExport()
        Metrics.shared.geoPackageExport(dataSources: filterViewModels.values.compactMap(\.dataSource))
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
                    self.error = true
                    self.creationError = "Unable to create GeoPackage file"
                }
                return
            }

            let rtree = GPKGRTreeIndexExtension(geoPackage: geoPackage)
            
            for viewModel in filterViewModels.values.sorted(by: { viewModel1, viewModel2 in
                (viewModel1.dataSource?.definition.order ?? -1) <
                    (viewModel2.dataSource?.definition.order ?? -1)
            }) {
                guard let dataSource = viewModel.dataSource, 
                        let exportable = DataSourceType.fromKey(dataSource.definition.key)?
                    .toDataSource() as? GeoPackageExportable.Type else { continue }
                guard let dataSource = viewModel.dataSource, 
                        let definitions = DataSourceDefinitions.from(dataSource.definition),
                      let exportProgress = exportProgresses[definitions] else {
                    continue
                }
                do {
                    guard let table = try exportable.createTable(geoPackage: geoPackage), 
                            let featureTableStyles = GPKGFeatureTableStyles(
                                geoPackage: geoPackage,
                                andTable: table
                            ) else {
                        continue
                    }
                    let styles = exportable.createStyles(tableStyles: featureTableStyles)

                    DispatchQueue.main.async {
                        exportProgress.totalCount = Float(self.counts[definitions] ?? 0)
                        exportProgress.exporting = true
                    }
                    try exportable.createFeatures(
                        geoPackage: geoPackage,
                        table: table,
                        filters: viewModel.filters,
                        commonFilters: commonViewModel.filters,
                        styleRows: styles,
                        dataSourceProgress: exportProgress)
                    rtree?.create(with: table)
                    DispatchQueue.main.async {
                        exportProgress.exporting = false
                        exportProgress.complete = true
                    }
                } catch {
                    DispatchQueue.main.async { [self] in
                        complete = false
                        exporting = false
                        self.error = true
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
