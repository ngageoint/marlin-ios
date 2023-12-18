//
//  DataSourceList.swift
//  Marlin
//
//  Created by Daniel Barela on 8/12/22.
//

import Foundation
import SwiftUI
import Combine
import CoreData

protocol DataSourceDefinition: ObservableObject {
    var mappable: Bool { get }
    var color: UIColor { get }
    var imageName: String? { get }
    var systemImageName: String? { get }
    var image: UIImage? { get }
    var key: String { get }
    var metricsKey: String { get }
    var name: String { get }
    var fullName: String { get }
    var order: Int { get }
    // this should be moved to a map centric protocol
    var imageScale: CGFloat { get }
}

extension DataSourceDefinition {
//    var order: Int {
//        UserDefaults.standard.dataSourceMapOrder(key)
//    }
    
    var imageScale: CGFloat {
        UserDefaults.standard.imageScale(key) ?? 1.0
    }
    
    var image: UIImage? {
        if let imageName = imageName {
            return UIImage(named: imageName)
        } else if let systemImageName = systemImageName {
            return UIImage(systemName: systemImageName)
        }
        return nil
    }
}

class RouteDefinition: DataSourceDefinition {
    var mappable: Bool = true
    var color: UIColor = .black
    var imageName: String?
    var systemImageName: String? = "arrow.triangle.turn.up.right.diamond.fill"
    var key: String = "route"
    var metricsKey: String = "routes"
    var name: String = NSLocalizedString("Routes", comment: "Route data source display name")
    var fullName: String = NSLocalizedString("Routes", comment: "Route data source full display name")
    @AppStorage("routeOrder") var order: Int = 0
}

class AsamDefinition: DataSourceDefinition {
    var mappable: Bool = true
    var color: UIColor = .black
    var imageName: String? = "asam"
    var systemImageName: String?
    var key: String = "asam"
    var metricsKey: String = "asams"
    var name: String = NSLocalizedString("ASAM", comment: "ASAM data source display name")
    var fullName: String = NSLocalizedString("Anti-Shipping Activity Messages", comment: "ASAM data source full display name")
    @AppStorage("asamOrder") var order: Int = 0
}

class ModuDefinition: DataSourceDefinition {
    var mappable: Bool = true
    var color: UIColor = UIColor(argbValue: 0xFF0042A4)
    var imageName: String? = "modu"
    var systemImageName: String?
    var key: String = "modu"
    var metricsKey: String = "modus"
    var name: String = NSLocalizedString("MODU", comment: "MODU data source display name")
    var fullName: String = NSLocalizedString("Mobile Offshore Drilling Units", comment: "MODU data source full display name")
    @AppStorage("moduOrder") var order: Int = 0
}

class CommonDefinition: DataSourceDefinition {
    var mappable: Bool = false
    var color: UIColor = Color.primaryUIColor
    var imageName: String?
    var systemImageName: String? = "mappin"
    var key: String = "Common"
    var metricsKey: String = "Common"
    var name: String = "Common"
    var fullName: String = "Common"
    @AppStorage("CommonOrder") var order: Int = 0
}

class NoticeToMarinersDefinition: DataSourceDefinition {
    var mappable: Bool = false
    var color: UIColor = UIColor.red
    var imageName: String?
    var systemImageName: String? = "speaker.badge.exclamationmark.fill"
    var key: String = "ntm"
    var metricsKey: String = "ntms"
    var name: String = "NTM"
    var fullName: String = "Notice To Mariners"
    @AppStorage("ntmOrder") var order: Int = 0
}

class DFRSDefinition: DataSourceDefinition {
    var mappable: Bool = true
    var color: UIColor = UIColor(argbValue: 0xFFFFB300)
    var imageName: String?
    var systemImageName: String? = "antenna.radiowaves.left.and.right.circle"
    var key: String = "dfrs"
    var metricsKey: String = "dfrs"
    var name: String = NSLocalizedString("DFRS", comment: "Radio Direction Finders and Radar station data source display name")
    var fullName: String = NSLocalizedString("Radio Direction Finders & Radar Stations", comment: "Radio Direction Finders and Radar station data source full display name")
    var imageScale: CGFloat {
        UserDefaults.standard.imageScale(key) ?? 0.66
    }
    @AppStorage("dfrsOrder") var order: Int = 0
}

class DifferentialGPSStationDefinition: DataSourceDefinition {
    var mappable: Bool = true
    var color: UIColor = UIColor(argbValue: 0xFF00E676)
    var imageName: String? = "dgps"
    var systemImageName: String?
    var key: String = "differentialGPSStation"
    var metricsKey: String = "dgpsStations"
    var name: String = NSLocalizedString("DGPS", comment: "Differential GPS Station data source display name")
    var fullName: String = NSLocalizedString("Differential GPS Stations", comment: "Differential GPS Station data source full display name")
    var imageScale: CGFloat {
        UserDefaults.standard.imageScale(key) ?? 0.66
    }
    @AppStorage("differentialGPSStationOrder") var order: Int = 0
}

class ElectronicPublicationDefinition: DataSourceDefinition {
    var mappable: Bool = false
    var color: UIColor = UIColor(argbValue: 0xFF30B0C7)
    var imageName: String?
    var systemImageName: String? = "doc.text.fill"
    var key: String = "epub"
    var metricsKey: String = "epubs"
    var name: String = NSLocalizedString("EPUB", comment: "Electronic Publication data source display name")
    var fullName: String = NSLocalizedString("Electronic Publications", comment: "Electronic Publication data source full display name")
    @AppStorage("epubOrder") var order: Int = 0
}

class PortDefinition: DataSourceDefinition {
    var mappable: Bool = true
    var color: UIColor = UIColor(argbValue: 0xFF5856d6)
    var imageName: String? = "port"
    var systemImageName: String?
    var key: String = "port"
    var metricsKey: String = "ports"
    var name: String = NSLocalizedString("Ports", comment: "Port data source display name")
    var fullName: String = NSLocalizedString("World Ports", comment: "Port data source full display name")
    @AppStorage("portOrder") var order: Int = 0
}

class NavigationalWarningDefinition: DataSourceDefinition {
    var mappable: Bool = true
    var color: UIColor = UIColor(argbValue: 0xFFD32F2F)
    var imageName: String?
    var systemImageName: String? = "exclamationmark.triangle.fill"
    var key: String = "navWarning"
    var metricsKey: String = "navigational_warnings"
    var name: String = NSLocalizedString("Warnings", comment: "Warnings data source display name")
    var fullName: String = NSLocalizedString("Navigational Warnings", comment: "Warnings data source full display name")
    @AppStorage("navWarningOrder") var order: Int = 0
}

class LightDefinition: DataSourceDefinition {
    var mappable: Bool = true
    var color: UIColor = UIColor(argbValue: 0xFFFFC500)
    var imageName: String?
    var systemImageName: String? = "lightbulb.fill"
    var key: String = "light"
    var metricsKey: String = "lights"
    var name: String = NSLocalizedString("Lights", comment: "Lights data source display name")
    var fullName: String = NSLocalizedString("Lights", comment: "Lights data source full display name")
    var imageScale: CGFloat {
        UserDefaults.standard.imageScale(key) ?? 0.66
    }
    @AppStorage("lightOrder") var order: Int = 0
}

class RadioBeaconDefinition: DataSourceDefinition {
    var mappable: Bool = true
    var color: UIColor = UIColor(argbValue: 0xFF007BFF)
    var imageName: String?
    var systemImageName: String? = "antenna.radiowaves.left.and.right"
    var key: String = "radioBeacon"
    var metricsKey: String = "radioBeacons"
    var name: String = NSLocalizedString("Beacons", comment: "Radio Beacons data source display name")
    var fullName: String = NSLocalizedString("Radio Beacons", comment: "Radio Beacons data source full display name")
    var imageScale: CGFloat {
        UserDefaults.standard.imageScale(key) ?? 0.66
    }
    @AppStorage("radioBeaconOrder") var order: Int = 0
}

class BookmarkDefinition: DataSourceDefinition {
    var mappable: Bool = false
    var color: UIColor = UIColor(argbValue: 0xFFFF9500)
    var imageName: String?
    var systemImageName: String? = "bookmark.fill"
    var key: String = "bookmark"
    var metricsKey: String = "bookmark"
    var name: String = NSLocalizedString("Bookmarks", comment: "Bookmarks data source display name")
    var fullName: String = NSLocalizedString("Bookmarks", comment: "Bookmarks data source full display name")
    @AppStorage("bookmarkOrder") var order: Int = 0
}

class ChartCorrectionDefinition: DataSourceDefinition {
    var mappable: Bool = false
    var color: UIColor = UIColor.red
    var imageName: String?
    var systemImageName: String? = "antenna.radiowaves.left.and.right"
    var key: String = "chartCorrection"
    var metricsKey: String = "corrections"
    var name: String = NSLocalizedString("Chart Corrections", comment: "Chart Corrections data source display name")
    var fullName: String = NSLocalizedString("Chart Corrections", comment: "Chart Corrections data source full display name")
    @AppStorage("chartCorrectionOrder") var order: Int = 0
}

class GeoPackageDefinition: DataSourceDefinition {
    var mappable: Bool = true
    var color: UIColor = UIColor.brown
    var imageName: String?
    var systemImageName: String?
    var key: String = "gpfeature"
    var metricsKey: String = "geopackage"
    var name: String = NSLocalizedString("GeoPackage Feature", comment: "GeoPackage Feature data source display name")
    var fullName: String = NSLocalizedString("GeoPackage Feature", comment: "GeoPackage Feature data source full display name")
    @AppStorage("gpfeatureOrder") var order: Int = 0
}

enum DataSourceDefinitions: String, Identifiable {
    var id: String { rawValue }
    
    case route
    case asam
    case modu
    case common
    case noticeToMariners
    case dfrs
    case dgps
    case epub
    case port
    case navWarning
    case light
    case radioBeacon
    case bookmark
    case chartCorrection
    case geoPackage
    
    static func from(_ definition: (any DataSourceDefinition)? = nil) -> DataSourceDefinitions? {
        switch(definition) {
        case is RouteDefinition:
            return DataSourceDefinitions.route
        case is AsamDefinition:
            return DataSourceDefinitions.asam
        case is ModuDefinition:
            return DataSourceDefinitions.modu
        case is CommonDefinition:
            return DataSourceDefinitions.common
        case is NoticeToMarinersDefinition:
            return DataSourceDefinitions.noticeToMariners
        case is DifferentialGPSStationDefinition:
            return DataSourceDefinitions.dgps
        case is ElectronicPublicationDefinition:
            return DataSourceDefinitions.epub
        case is PortDefinition:
            return DataSourceDefinitions.port
        case is NavigationalWarningDefinition:
            return DataSourceDefinitions.navWarning
        case is LightDefinition:
            return DataSourceDefinitions.light
        case is RadioBeaconDefinition:
            return DataSourceDefinitions.radioBeacon
        case is ChartCorrectionDefinition:
            return DataSourceDefinitions.chartCorrection
            
        default:
            return nil
        }
    }
    
    var definition: any DataSourceDefinition {
        switch(self) {
        case .route:
            return RouteDefinition()
        case .asam:
            return AsamDefinition()
        case .modu:
            return ModuDefinition()
        case .common:
            return CommonDefinition()
        case .noticeToMariners:
            return NoticeToMarinersDefinition()
        case .dfrs:
            return DFRSDefinition()
        case .dgps:
            return DifferentialGPSStationDefinition()
        case .epub:
            return ElectronicPublicationDefinition()
        case .port:
            return PortDefinition()
        case .navWarning:
            return NavigationalWarningDefinition()
        case .light:
            return LightDefinition()
        case .radioBeacon:
            return RadioBeaconDefinition()
        case .bookmark:
            return BookmarkDefinition()
        case .chartCorrection:
            return ChartCorrectionDefinition()
        case .geoPackage:
            return GeoPackageDefinition()
        }
    }
    
    var filterable: Filterable? {
        switch(self) {
        case .route:
            return RouteFilterable()
        case .asam:
            return AsamFilterable()
        case .modu:
            return ModuFilterable()
        case .common:
            return CommonFilterable()
        case .noticeToMariners:
            return NoticeToMarinersFilterable()
        case .dgps:
            return DifferentialGPSStationFilterable()
        case .epub:
            return ElectronicPublicationFilterable()
        case .port:
            return PortFilterable()
        case .navWarning:
            return NavigationalWarningFilterable()
        case .light:
            return LightFilterable()
        case .radioBeacon:
            return RadioBeaconFilterable()
//        case .bookmark:
//            return BookmarkDefinition()
        case .chartCorrection:
            return ChartCorrectionFilterable()
        default:
            return nil
//        case .geoPackage:
//            return GeoPackageDefinition()
        }
    }
    
    static func filterableFromDefintion(_ definition: any DataSourceDefinition) -> Filterable? {
        switch(definition) {
        case is RouteDefinition:
            return DataSourceDefinitions.route.filterable
        case is AsamDefinition:
            return DataSourceDefinitions.asam.filterable
        case is ModuDefinition:
            return DataSourceDefinitions.modu.filterable
        case is CommonDefinition:
            return DataSourceDefinitions.common.filterable
        case is NoticeToMarinersDefinition:
            return DataSourceDefinitions.noticeToMariners.filterable
        case is DifferentialGPSStationDefinition:
            return DataSourceDefinitions.dgps.filterable
        case is ElectronicPublicationDefinition:
            return DataSourceDefinitions.epub.filterable
        case is PortDefinition:
            return DataSourceDefinitions.port.filterable
        case is NavigationalWarningDefinition:
            return DataSourceDefinitions.navWarning.filterable
        case is LightDefinition:
            return DataSourceDefinitions.light.filterable
        case is RadioBeaconDefinition:
            return DataSourceDefinitions.radioBeacon.filterable
        case is ChartCorrectionDefinition:
            return DataSourceDefinitions.chartCorrection.filterable
            
        default:
            return nil
        }
    }
}

// TODO: this should go away
enum DataSourceType: String, CaseIterable {
    case asam
    case modu
    case light
    case port
    case differentialGPSStation
    case radioBeacon
    // swiftlint:disable identifier_name
    case Common
    // swiftlint:enable identifier_name
    case route
    case ntm
    case epub
    case navWarning
    
    static func fromKey(_ key: String) -> DataSourceType? {
        return self.allCases.first { "\($0)" == key }
    }
    
    func toDataSource() -> DataSource.Type {
        switch self {
        case .asam:
            return Asam.self
        case .modu:
            return Modu.self
        case .light:
            return Light.self
        case .port:
            return Port.self
        case .differentialGPSStation:
            return DifferentialGPSStation.self
        case .radioBeacon:
            return RadioBeacon.self
        case .Common:
            return CommonDataSource.self
        case .route:
            return Route.self
        case .ntm:
            return NoticeToMariners.self
        case .epub:
            return ElectronicPublication.self
        case .navWarning:
            return NavigationalWarning.self
        }
    }

    func asamModel(dataSource: DataSource?) -> DataSource? {
        if let asam = dataSource as? Asam {
            return AsamModel(asam: asam)
        }
        return nil
    }

    func moduModel(dataSource: DataSource?) -> DataSource? {
        if let modu = dataSource as? Modu {
            return ModuModel(modu: modu)
        }
        return nil
    }
    func lightModel(dataSource: DataSource?) -> DataSource? {
        if let light = dataSource as? Light {
            return LightModel(light: light)
        }
        return nil
    }
    func portModel(dataSource: DataSource?) -> DataSource? {
        if let port = dataSource as? Port {
            return PortModel(port: port)
        }
        return nil
    }
    func differentialGPSStationModel(dataSource: DataSource?) -> DataSource? {
        if let differentialGPSStation = dataSource as? DifferentialGPSStation {
            return DifferentialGPSStationModel(differentialGPSStation: differentialGPSStation)
        }
        return nil
    }
    func radioBeaconModel(dataSource: DataSource?) -> DataSource? {
        if let radioBeacon = dataSource as? RadioBeacon {
            return RadioBeaconModel(radioBeacon: radioBeacon)
        }
        return nil
    }
    func commonModel(dataSource: DataSource?) -> DataSource? {
        if let common = dataSource as? CommonDataSource {
            return common
        }
        return nil
    }
    func routeModel(dataSource: DataSource?) -> DataSource? {
        if let route = dataSource as? Route {
            return route
        }
        return nil
    }
    func ntmModel(dataSource: DataSource?) -> DataSource? {
        if let ntm = dataSource as? NoticeToMariners {
            return ntm
        }
        return nil
    }
    func epubModel(dataSource: DataSource?) -> DataSource? {
        if let epub = dataSource as? ElectronicPublication {
            return epub
        }
        return nil
    }
    func navWarningModel(dataSource: DataSource?) -> DataSource? {
        if let navWarning = dataSource as? NavigationalWarning {
            return navWarning
        }
        return nil
    }

    func createModel(dataSource: DataSource?) -> DataSource? {
        switch self {
        case .asam:
            return asamModel(dataSource: dataSource)
        case .modu:
            return moduModel(dataSource: dataSource)
        case .light:
            return lightModel(dataSource: dataSource)
        case .port:
            return portModel(dataSource: dataSource)
        case .differentialGPSStation:
            return differentialGPSStationModel(dataSource: dataSource)
        case .radioBeacon:
            return radioBeaconModel(dataSource: dataSource)
        case .Common:
            return commonModel(dataSource: dataSource)
        case .route:
            return routeModel(dataSource: dataSource)
        case .ntm:
            return ntmModel(dataSource: dataSource)
        case .epub:
            return epubModel(dataSource: dataSource)
        case .navWarning:
            return navWarningModel(dataSource: dataSource)
        }
    }
}

class DataSourceList: ObservableObject {
    let tabItems: [DataSourceItem] = [
        DataSourceItem(dataSource: Asam.self),
        DataSourceItem(dataSource: Modu.self),
        DataSourceItem(dataSource: Light.self),
        DataSourceItem(dataSource: NavigationalWarning.self),
        DataSourceItem(dataSource: Port.self),
        DataSourceItem(dataSource: RadioBeacon.self),
        DataSourceItem(dataSource: DifferentialGPSStation.self),
        DataSourceItem(dataSource: DFRS.self),
        DataSourceItem(dataSource: ElectronicPublication.self),
        DataSourceItem(dataSource: NoticeToMariners.self),
        DataSourceItem(dataSource: Bookmark.self),
        DataSourceItem(dataSource: Route.self)
    ]
    
    var enabledTabs: [DataSourceItem] {
        return tabItems.filter({ item in
            item.enabled
        })
    }
    
    var mappableDataSources: [DataSourceItem] {
        return enabledTabs.filter { item in
            item.dataSource.definition.mappable
        }.sorted(by: { one, two in
            return one.order < two.order
        })
    }
    
    var allTabs: [DataSourceItem] {
        return enabledTabs.sorted(by: { one, two in
            return one.order < two.order
        })
    }
    @Published var tabs: [DataSourceItem] = []
    @Published var nonTabs: [DataSourceItem] = []
    @Published var mappedDataSources: [DataSourceItem] = []
    
    @Published var mappedFilterableDataSources: [Filterable] = []
    static let MAX_TABS = 4
    @AppStorage("userTabs") var userTabs: Int = MAX_TABS
    
    var cancellable = Set<AnyCancellable>()
    
    init() {
        _tabs = Published(initialValue: Array(allTabs.prefix(userTabs).filter({ item in
            UserDefaults.standard.dataSourceEnabled(item.dataSource.definition)
        })))
        _nonTabs = Published(initialValue: Array(allTabs.dropFirst(userTabs).filter({ item in
            UserDefaults.standard.dataSourceEnabled(item.dataSource.definition)
        })))
        _mappedDataSources = Published(initialValue: Array(allTabs.filter({ item in
            // no filtering Navigational Warnings for right now..
            UserDefaults.standard
                .dataSourceEnabled(item.dataSource.definition)
            && UserDefaults.standard
                .showOnMap(key: item.key)
        })))
        
        _mappedFilterableDataSources = Published(initialValue: Array(
            allTabs.filter({ item in
                // no filtering Navigational Warnings for right now..
                UserDefaults.standard
                    .dataSourceEnabled(item.dataSource.definition)
                && UserDefaults.standard
                    .showOnMap(key: item.key)
            })
            .compactMap({ item in
                return DataSourceDefinitions.filterableFromDefintion(item.dataSource.definition)
            })
            .sorted(by: { filterable1, filterable2 in
                filterable1.definition.order < filterable2.definition.order
            })
        ))
        
        NotificationCenter.default.publisher(for: .MappedDataSourcesUpdated)
            .sink(receiveValue: { [weak self] _ in
                guard let allTabs = self?.allTabs else {
                    return
                }
                self?._mappedDataSources = Published(
                    initialValue: Array(
                        allTabs.filter(
                            { item in
                                UserDefaults.standard.dataSourceEnabled(item.dataSource.definition) &&
                                UserDefaults.standard.showOnMap(key: item.key)
                            }
                        )
                    )
                )
                self?._mappedFilterableDataSources = Published(
                    initialValue: Array(
                        allTabs.filter(
                            { item in
                                // no filtering Navigational Warnings for right now..
                                UserDefaults.standard.dataSourceEnabled(item.dataSource.definition) &&
                                UserDefaults.standard.showOnMap(key: item.key)
                            }
                        )
                        .compactMap(
                            { item in
                                DataSourceDefinitions.filterableFromDefintion(item.dataSource.definition)
                            }
                        )
                    )
                )
                self?.objectWillChange.send()
            })
            .store(in: &cancellable)
    }
    
    func addItemToTabs(dataSourceItem: DataSourceItem, position: Int) {
        nonTabs.removeAll { item in
            item == dataSourceItem
        }
        // set the order of the dropped
        tabs.insert(dataSourceItem, at: position)
        
        // reorder the tab datasources
        for i in 0...(tabs.count - 1) {
            tabs[i].order = i
        }
        
        if let last = tabs.last {
            
            // if they are above max tabs move the last tab to the non tabs
            if tabs.count > DataSourceList.MAX_TABS {
                tabs.removeLast()
                nonTabs.insert(last, at: 0)
            }
            
            // reorder the non tabs
            if nonTabs.count > 0 {
                for i in 0...nonTabs.count - 1 {
                    nonTabs[i].order = i + tabs.count
                }
            }
        }
        userTabs = tabs.count
    }
    
    func addItemToNonTabs(dataSourceItem: DataSourceItem, position: Int) {
        // remove the data source from the tab list
        tabs.removeAll { item in
            item == dataSourceItem
        }
        
        // put the data source into the non tab list where they dropped it
        nonTabs.insert(dataSourceItem, at: position)
        
        // reorder everything
        if tabs.count > 0 {
            for i in 0...tabs.count - 1 {
                tabs[i].order = i
            }
        }
        
        if nonTabs.count > 0 {
            for i in 0...nonTabs.count - 1 {
                nonTabs[i].order = i + tabs.count
            }
        }
        
        userTabs = tabs.count
    }
}

class DataSourceItem: ObservableObject, Identifiable, Hashable, Equatable {
    
    static func == (lhs: DataSourceItem, rhs: DataSourceItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }
    
    var id: String { key }
    var key: String { dataSource.definition.key }
    var dataSource: any DataSource.Type
    
    @AppStorage<Int> var order: Int
    @AppStorage<Bool> var showOnMap: Bool {
        didSet {
            NotificationCenter.default.post(name: .MappedDataSourcesUpdated, object: nil)
        }
    }
    @AppStorage<Data> var filterData: Data {
        willSet {
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
    @AppStorage<Bool> var enabled: Bool
    
    init(dataSource: any DataSource.Type) {
        self.dataSource = dataSource
        self._order = AppStorage(
            wrappedValue: 0,
            "\(dataSource.definition.key)Order")
        self._showOnMap = AppStorage(
            wrappedValue: dataSource.definition.mappable,
            "showOnMap\(dataSource.definition.key)")
        self._filterData = AppStorage(
            wrappedValue: Data(),
            "\(dataSource.definition.key)Filter")
        self._enabled = AppStorage(
            wrappedValue: UserDefaults.standard.dataSourceEnabled(dataSource.definition),
            "\(dataSource.definition.key)DataSourceEnabled")

    }
    
    var description: String {
        return "Data Source \(key) order: \(order)"
    }
}
