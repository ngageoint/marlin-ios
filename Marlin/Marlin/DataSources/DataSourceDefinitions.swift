//
//  DataSourceDefinitions.swift
//  Marlin
//
//  Created by Daniel Barela on 12/20/23.
//

import Foundation

// TODO: should this go away?
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

    // this cannot be fixed since we have this many data sources
    // swiftlint:disable cyclomatic_complexity
    static func from(_ definition: (any DataSourceDefinition)? = nil) -> DataSourceDefinitions? {
        switch definition {
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
    // swiftlint:enable cyclomatic_complexity

    var definition: any DataSourceDefinition {
        switch self {
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
        switch self {
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

    // this cannot be fixed since we have this many data sources
    // swiftlint:disable cyclomatic_complexity
    static func filterableFromDefintion(_ definition: any DataSourceDefinition) -> Filterable? {
        switch definition {
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
    // swiftlint:enable cyclomatic_complexity
}
