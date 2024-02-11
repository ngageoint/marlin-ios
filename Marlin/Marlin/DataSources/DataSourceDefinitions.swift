//
//  DataSourceDefinitions.swift
//  Marlin
//
//  Created by Daniel Barela on 12/20/23.
//

import Foundation

enum DataSourceDefinitions: String, Identifiable, CaseIterable {
    var id: String { rawValue }

    case asam
    case bookmark
    case common
    case chartCorrection
    case dfrs
    case differentialGPSStation
    case epub
    case geoPackage
    case light
    case modu
    case navWarning
    case noticeToMariners
    case port
    case radioBeacon
    case route

    // this cannot be fixed since we have this many data sources
    // swiftlint:disable cyclomatic_complexity
    static func from(_ definition: (any DataSourceDefinition)? = nil) -> DataSourceDefinitions? {
        switch definition {
        case is DataSources.RouteDefinition:
            return DataSourceDefinitions.route
        case is DataSources.AsamDefinition:
            return DataSourceDefinitions.asam
        case is DataSources.ModuDefinition:
            return DataSourceDefinitions.modu
        case is DataSources.CommonDefinition:
            return DataSourceDefinitions.common
        case is DataSources.NoticeToMarinersDefinition:
            return DataSourceDefinitions.noticeToMariners
        case is DataSources.DifferentialGPSStationDefinition:
            return DataSourceDefinitions.differentialGPSStation
        case is DataSources.ElectronicPublicationDefinition:
            return DataSourceDefinitions.epub
        case is DataSources.PortDefinition:
            return DataSourceDefinitions.port
        case is DataSources.NavigationalWarningDefinition:
            return DataSourceDefinitions.navWarning
        case is DataSources.LightDefinition:
            return DataSourceDefinitions.light
        case is DataSources.RadioBeaconDefinition:
            return DataSourceDefinitions.radioBeacon
        case is DataSources.ChartCorrectionDefinition:
            return DataSourceDefinitions.chartCorrection

        default:
            return nil
        }
    }
    // swiftlint:enable cyclomatic_complexity

    var definition: any DataSourceDefinition {
        switch self {
        case .route:
            return DataSources.route
        case .asam:
            return DataSources.asam
        case .modu:
            return DataSources.modu
        case .common:
            return DataSources.common
        case .noticeToMariners:
            return DataSources.noticeToMariners
        case .dfrs:
            return DataSources.dfrs
        case .differentialGPSStation:
            return DataSources.dgps
        case .epub:
            return DataSources.epub
        case .port:
            return DataSources.port
        case .navWarning:
            return DataSources.navWarning
        case .light:
            return DataSources.light
        case .radioBeacon:
            return DataSources.radioBeacon
        case .bookmark:
            return DataSources.bookmark
        case .chartCorrection:
            return DataSources.chartCorrection
        case .geoPackage:
            return DataSources.geoPackage
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
    // swiftlint:enable cyclomatic_complexity
}
