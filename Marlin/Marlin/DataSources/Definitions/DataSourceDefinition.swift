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
    static let asam: AsamDefinition = AsamDefinition.definition
    static let bookmark: BookmarkDefinition = BookmarkDefinition.definition
    static let common: CommonDefinition = CommonDefinition.definition
    static let chartCorrection: ChartCorrectionDefinition = ChartCorrectionDefinition.definition
    static let dgps: DGPSStationDefinition = DGPSStationDefinition.definition
    static let epub: PublicationDefinition = PublicationDefinition.definition
    static let geoPackage: GeoPackageDefinition = GeoPackageDefinition.definition
    static let light: LightDefinition = LightDefinition.definition
    static let modu: ModuDefinition = ModuDefinition.definition
    static let navWarning: NavigationalWarningDefinition = NavigationalWarningDefinition.definition
    static let noticeToMariners: NoticeToMarinersDefinition = NoticeToMarinersDefinition.definition
    static let port: PortDefinition = PortDefinition.definition
    static let radioBeacon: RadioBeaconDefinition = RadioBeaconDefinition.definition
    static let route: RouteDefinition = RouteDefinition.definition
    static let userPlace: UserPlaceDefinition = UserPlaceDefinition.definition
    static let search: SearchProviderDataDefinition = SearchProviderDataDefinition.definition

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
        case is DataSources.DGPSStationDefinition:
            return DataSourceDefinitions.differentialGPSStation.filterable
        case is DataSources.PublicationDefinition:
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
        case is DataSources.UserPlaceDefinition:
            return DataSources.userPlace.filterable
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
        case DataSources.userPlace.key:
            return DataSources.userPlace
        case DataSources.search.key:
            return DataSources.search
        default:
            return nil
        }
    }
}
