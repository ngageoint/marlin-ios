//
//  DataSourceDefinitions.swift
//  Marlin
//
//  Created by Daniel Barela on 12/20/23.
//

import Foundation

enum DataSourceDefinitions: String, Identifiable, CaseIterable {
    var id: String { rawValue }

    case route
    case asam
    case modu
    case common
    case differentialGPSStation
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
        case is DataSources.DGPSStationDefinition:
            return DataSourceDefinitions.differentialGPSStation
        case is DataSources.PublicationDefinition:
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
            return DataSources.noticeToMariners
        case .differentialGPSStation:
            return DataSources.dgps
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
        case .differentialGPSStation:
            return DGPSStationFilterable()
        case .epub:
            return PublicationFilterable()
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
        case is DataSources.DGPSStationDefinition:
            return DataSourceDefinitions.differentialGPSStation.filterable
        case is DataSources.PublicationDefinition:
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
