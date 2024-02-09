//
//  DataSourceDefinition.swift
//  Marlin
//
//  Created by Daniel Barela on 12/20/23.
//

import Foundation
import UIKit
import SwiftUI

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
    func shouldSync() -> Bool
    var dateFormatter: DateFormatter { get }
    var filterable: Filterable? { get }
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

    func shouldSync() -> Bool {
        false
    }

    var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }

    var filterable: Filterable? {
        nil
    }

    var defaultSort: [DataSourceSortParameter] {
        filterable?.defaultSort ?? []
    }
}
enum DataSources {
    static let asam: AsamDefinition = AsamDefinition()
    static let bookmark: BookmarkDefinition = BookmarkDefinition()
    static let common: CommonDefinition = CommonDefinition()
    static let chartCorrection: ChartCorrectionDefinition = ChartCorrectionDefinition()
    static let dfrs: DFRSDefinition = DFRSDefinition()
    static let dgps: DifferentialGPSStationDefinition = DifferentialGPSStationDefinition()
    static let epub: ElectronicPublicationDefinition = ElectronicPublicationDefinition()
    static let geoPackage: GeoPackageDefinition = GeoPackageDefinition()
    static let light: LightDefinition = LightDefinition()
    static let modu: ModuDefinition = ModuDefinition()
    static let navWarning: NavigationalWarningDefinition = NavigationalWarningDefinition()
    static let noticeToMariners: NoticeToMarinersDefinition = NoticeToMarinersDefinition()
    static let port: PortDefinition = PortDefinition()
    static let radioBeacon: RadioBeaconDefinition = RadioBeaconDefinition()
    static let route: RouteDefinition = RouteDefinition()

    // swiftlint:disable cyclomatic_complexity
    static func filterableFromDefintion(_ definition: any DataSourceDefinition) -> Filterable? {
        switch definition {
        case is DataSources.RouteDefinition:
            return DataSourceDefinitions.route.filterable
        case is DataSources.AsamDefinition:
            return DataSourceDefinitions.asam.filterable
        case is DataSources.ModuDefinition:
            return DataSourceDefinitions.modu.filterable
        case is DataSources.CommonDefinition:
            return DataSourceDefinitions.common.filterable
        case is DataSources.NoticeToMarinersDefinition:
            return DataSourceDefinitions.noticeToMariners.filterable
        case is DataSources.DifferentialGPSStationDefinition:
            return DataSourceDefinitions.differentialGPSStation.filterable
        case is DataSources.ElectronicPublicationDefinition:
            return DataSourceDefinitions.epub.filterable
        case is DataSources.PortDefinition:
            return DataSourceDefinitions.port.filterable
        case is DataSources.NavigationalWarningDefinition:
            return DataSourceDefinitions.navWarning.filterable
        case is DataSources.LightDefinition:
            return DataSourceDefinitions.light.filterable
        case is DataSources.RadioBeaconDefinition:
            return DataSourceDefinitions.radioBeacon.filterable
        case is DataSources.ChartCorrectionDefinition:
            return DataSourceDefinitions.chartCorrection.filterable

        default:
            return nil
        }
    }

    static func fromObject(_ type: AnyObject) -> (any DataSourceDefinition)? {
        switch type {
        case is Asam.Type, is AsamModel.Type, is AsamListModel.Type:
            return DataSources.asam
        case is Bookmark.Type:
            return DataSources.bookmark
        case is ChartCorrection.Type:
            return DataSources.chartCorrection
        case is DFRS.Type:
            return DataSources.dfrs
        case is DifferentialGPSStation.Type:
            return DataSources.dgps
        case is ElectronicPublication.Type:
            return DataSources.epub
        case is GeoPackageFeatureItem.Type:
            return DataSources.geoPackage
        case is Light.Type, is LightModel.Type:
            return DataSources.light
        case is ModuModel.Type, is Modu.Type:
            return DataSources.modu
        case is NavigationalWarning.Type:
            return DataSources.navWarning
        case is NoticeToMariners.Type:
            return DataSources.noticeToMariners
        case is Port.Type, is PortModel.Type:
            return DataSources.port
        case is RadioBeacon.Type, is RadioBeaconModel.Type:
            return DataSources.radioBeacon
        case is Route.Type, is RouteModel.Type:
            return DataSources.route
        default:
            return nil
        }
    }

    static func fromKey(key: String) -> (any DataSourceDefinition)? {
        switch key {
        case DataSources.asam.key:
            return DataSources.asam
        case DataSources.bookmark.key:
            return DataSources.bookmark
        case DataSources.chartCorrection.key:
            return DataSources.chartCorrection
        case DataSources.dfrs.key:
            return DataSources.dfrs
        case DataSources.dgps.key:
            return DataSources.dgps
        case DataSources.epub.key:
            return DataSources.epub
        case DataSources.geoPackage.key:
            return DataSources.geoPackage
        case DataSources.light.key:
            return DataSources.light
        case DataSources.modu.key:
            return DataSources.modu
        case DataSources.navWarning.key:
            return DataSources.navWarning
        case DataSources.noticeToMariners.key:
            return DataSources.noticeToMariners
        case DataSources.port.key:
            return DataSources.port
        case DataSources.radioBeacon.key:
            return DataSources.radioBeacon
        case DataSources.route.key:
            return DataSources.route
        default:
            return nil
        }
    }

    static func fromDataSourceType(_ type: any DataSource.Type) -> (any DataSourceDefinition)? {
        switch type {
        case is AsamModel.Type, is Asam.Type:
            return DataSources.asam
        case is Bookmark.Type:
            return DataSources.bookmark
        case is ChartCorrection.Type:
            return DataSources.chartCorrection
        case is DFRS.Type:
            return DataSources.dfrs
        case is DifferentialGPSStation.Type:
            return DataSources.dgps
        case is ElectronicPublication.Type:
            return DataSources.epub
        case is GeoPackageFeatureItem.Type:
            return DataSources.geoPackage
        case is Light.Type, is LightModel.Type:
            return DataSources.light
        case is ModuModel.Type, is Modu.Type:
            return DataSources.modu
        case is NavigationalWarning.Type:
            return DataSources.navWarning
        case is NoticeToMariners.Type:
            return DataSources.noticeToMariners
        case is Port.Type, is PortModel.Type:
            return DataSources.port
        case is RadioBeacon.Type, is RadioBeaconModel.Type:
            return DataSources.radioBeacon
        case is Route.Type, is RouteModel.Type:
            return DataSources.route
        default:
            return nil
        }
    }
    // swiftlint:enable cyclomatic_complexity
}

extension DataSources {
    class AsamDefinition: DataSourceDefinition {
        var mappable: Bool = true
        var color: UIColor = .black
        var imageName: String? = "asam"
        var systemImageName: String?
        var key: String = "asam"
        var metricsKey: String = "asams"
        var name: String = NSLocalizedString("ASAM", comment: "ASAM data source display name")
        var fullName: String = 
        NSLocalizedString("Anti-Shipping Activity Messages", comment: "ASAM data source full display name")
        @AppStorage("asamOrder") var order: Int = 0
        func shouldSync() -> Bool {
            // sync once every hour
            return UserDefaults.standard.dataSourceEnabled(DataSources.asam)
            && (Date().timeIntervalSince1970 - (60 * 60)) > 
            UserDefaults.standard.lastSyncTimeSeconds(DataSources.asam)
        }

        var filterable: AsamFilterable = AsamFilterable()

        fileprivate init() { }
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

        fileprivate init() { }
    }

    class ModuDefinition: DataSourceDefinition {
        var mappable: Bool = true
        var color: UIColor = UIColor(argbValue: 0xFF0042A4)
        var imageName: String? = "modu"
        var systemImageName: String?
        let key: String = "modu"
        var metricsKey: String = "modus"
        var name: String = NSLocalizedString("MODU", comment: "MODU data source display name")
        var fullName: String = 
        NSLocalizedString("Mobile Offshore Drilling Units", comment: "MODU data source full display name")
        @AppStorage("moduOrder") var order: Int = 0
        func shouldSync() -> Bool {
            // sync once every hour
            return UserDefaults.standard.dataSourceEnabled(DataSources.modu)
            && (Date().timeIntervalSince1970 - (60 * 60)) > UserDefaults.standard.lastSyncTimeSeconds(DataSources.modu)
        }

        var filterable: ModuFilterable = ModuFilterable()

        fileprivate init() { }
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

        fileprivate init() { }
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
        func shouldSync() -> Bool {
            // sync once every day
            return UserDefaults.standard.dataSourceEnabled(NoticeToMariners.definition) 
            && (Date().timeIntervalSince1970 - (60 * 60 * 24)) > 
            UserDefaults.standard.lastSyncTimeSeconds(NoticeToMariners.definition)
        }

        var filterable: NoticeToMarinersFilterable = NoticeToMarinersFilterable()

        fileprivate init() { }
    }

    class DFRSDefinition: DataSourceDefinition {
        var mappable: Bool = true
        var color: UIColor = UIColor(argbValue: 0xFFFFB300)
        var imageName: String?
        var systemImageName: String? = "antenna.radiowaves.left.and.right.circle"
        var key: String = "dfrs"
        var metricsKey: String = "dfrs"
        var name: String = 
        NSLocalizedString("DFRS", comment: "Radio Direction Finders and Radar station data source display name")
        var fullName: String = 
        NSLocalizedString("Radio Direction Finders & Radar Stations",
                          comment: "Radio Direction Finders and Radar station data source full display name")
        var imageScale: CGFloat {
            UserDefaults.standard.imageScale(key) ?? 0.66
        }
        @AppStorage("dfrsOrder") var order: Int = 0
        func shouldSync() -> Bool {
            // sync once every week
            return UserDefaults.standard.dataSourceEnabled(DFRS.definition) 
            && (Date().timeIntervalSince1970 - (60 * 60 * 24 * 7)) > 
            UserDefaults.standard.lastSyncTimeSeconds(DFRS.definition)
        }

        fileprivate init() { }
    }

    class DifferentialGPSStationDefinition: DataSourceDefinition {
        var mappable: Bool = true
        var color: UIColor = UIColor(argbValue: 0xFF00E676)
        var imageName: String? = "dgps"
        var systemImageName: String?
        var key: String = "differentialGPSStation"
        var metricsKey: String = "dgpsStations"
        var name: String = NSLocalizedString("DGPS", comment: "Differential GPS Station data source display name")
        var fullName: String = 
        NSLocalizedString("Differential GPS Stations",
                          comment: "Differential GPS Station data source full display name")
        var imageScale: CGFloat {
            UserDefaults.standard.imageScale(key) ?? 0.66
        }
        @AppStorage("differentialGPSStationOrder") var order: Int = 0
        func shouldSync() -> Bool {
            // sync once every week
            return UserDefaults.standard.dataSourceEnabled(DataSources.dgps)
            && (Date().timeIntervalSince1970 - (60 * 60 * 24 * 7)) >
            UserDefaults.standard.lastSyncTimeSeconds(DataSources.dgps)
        }

        var filterable: DifferentialGPSStationFilterable = DifferentialGPSStationFilterable()

        fileprivate init() { }
    }

    class ElectronicPublicationDefinition: DataSourceDefinition {
        var mappable: Bool = false
        var color: UIColor = UIColor(argbValue: 0xFF30B0C7)
        var imageName: String?
        var systemImageName: String? = "doc.text.fill"
        var key: String = "epub"
        var metricsKey: String = "epubs"
        var name: String = NSLocalizedString("EPUB", comment: "Electronic Publication data source display name")
        var fullName: String = 
        NSLocalizedString("Electronic Publications", comment: "Electronic Publication data source full display name")
        @AppStorage("epubOrder") var order: Int = 0
        func shouldSync() -> Bool {
            // sync once every day
            return UserDefaults.standard.dataSourceEnabled(ElectronicPublication.definition) 
            && (Date().timeIntervalSince1970 - (60 * 60 * 24 * 1)) > 
            UserDefaults.standard.lastSyncTimeSeconds(ElectronicPublication.definition)
        }

        var filterable: ElectronicPublicationFilterable = ElectronicPublicationFilterable()
        fileprivate init() { }
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
        func shouldSync() -> Bool {
            // sync once every week
            return UserDefaults.standard.dataSourceEnabled(DataSources.port)
            && (Date().timeIntervalSince1970 - (60 * 60 * 24 * 7)) >
            UserDefaults.standard.lastSyncTimeSeconds(DataSources.port)
        }

        var dateFormatter: DateFormatter {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            return dateFormatter
        }

        var filterable: PortFilterable = PortFilterable()

        fileprivate init() { }
    }

    class NavigationalWarningDefinition: DataSourceDefinition {
        var mappable: Bool = true
        var color: UIColor = UIColor(argbValue: 0xFFD32F2F)
        var imageName: String?
        var systemImageName: String? = "exclamationmark.triangle.fill"
        var key: String = "navWarning"
        var metricsKey: String = "navigational_warnings"
        var name: String = NSLocalizedString("Warnings", comment: "Warnings data source display name")
        var fullName: String = 
        NSLocalizedString("Navigational Warnings", comment: "Warnings data source full display name")
        @AppStorage("navWarningOrder") var order: Int = 0
        func shouldSync() -> Bool {
            // sync once every hour
            return UserDefaults.standard.dataSourceEnabled(NavigationalWarning.definition) 
            && (Date().timeIntervalSince1970 - (60 * 60)) > 
            UserDefaults.standard.lastSyncTimeSeconds(NavigationalWarning.definition)
        }

        var filterable: NavigationalWarningFilterable = NavigationalWarningFilterable()
        fileprivate init() { }
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
        func shouldSync() -> Bool {
            // sync once every week
            return UserDefaults.standard.dataSourceEnabled(DataSources.light)
            && (Date().timeIntervalSince1970 - (60 * 60 * 24 * 7)) >
            UserDefaults.standard.lastSyncTimeSeconds(DataSources.light)
        }

        var filterable: LightFilterable = LightFilterable()

        fileprivate init() { }
    }

    class RadioBeaconDefinition: DataSourceDefinition {
        var mappable: Bool = true
        var color: UIColor = UIColor(argbValue: 0xFF007BFF)
        var imageName: String? = "settings_input_antenna"
        var systemImageName: String?
        var key: String = "radioBeacon"
        var metricsKey: String = "radioBeacons"
        var name: String = NSLocalizedString("Beacons", comment: "Radio Beacons data source display name")
        var fullName: String = 
        NSLocalizedString("Radio Beacons", comment: "Radio Beacons data source full display name")
        var imageScale: CGFloat {
            UserDefaults.standard.imageScale(key) ?? 0.66
        }
        @AppStorage("radioBeaconOrder") var order: Int = 0
        func shouldSync() -> Bool {
            // sync once every week
            return UserDefaults.standard.dataSourceEnabled(DataSources.radioBeacon)
            && (Date().timeIntervalSince1970 - (60 * 60 * 24 * 7)) >
            UserDefaults.standard.lastSyncTimeSeconds(DataSources.radioBeacon)
        }

        var filterable: RadioBeaconFilterable = RadioBeaconFilterable()

        fileprivate init() { }
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

        fileprivate init() { }
    }

    class ChartCorrectionDefinition: DataSourceDefinition {
        var mappable: Bool = false
        var color: UIColor = UIColor.red
        var imageName: String?
        var systemImageName: String? = "antenna.radiowaves.left.and.right"
        var key: String = "chartCorrection"
        var metricsKey: String = "corrections"
        var name: String = NSLocalizedString("Chart Corrections", comment: "Chart Corrections data source display name")
        var fullName: String = 
        NSLocalizedString("Chart Corrections", comment: "Chart Corrections data source full display name")
        @AppStorage("chartCorrectionOrder") var order: Int = 0

        fileprivate init() { }
    }

    class GeoPackageDefinition: DataSourceDefinition {
        var mappable: Bool = true
        var color: UIColor = UIColor.brown
        var imageName: String?
        var systemImageName: String?
        var key: String = "gpfeature"
        var metricsKey: String = "geopackage"
        var name: String = 
        NSLocalizedString("GeoPackage Feature", comment: "GeoPackage Feature data source display name")
        var fullName: String = 
        NSLocalizedString("GeoPackage Feature", comment: "GeoPackage Feature data source full display name")
        @AppStorage("gpfeatureOrder") var order: Int = 0

        fileprivate init() { }
    }
}
