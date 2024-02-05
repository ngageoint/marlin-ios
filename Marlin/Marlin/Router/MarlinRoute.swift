//
//  MarlinRoute.swift
//  Marlin
//
//  Created by Daniel Barela on 6/30/23.
//

import Foundation
import SwiftUI
import CoreData

class MarlinRouter: ObservableObject {
    @Published var path: NavigationPath = NavigationPath()
}

enum MarlinRoute: Hashable {
    case exportGeoPackage(useMapRegion: Bool)
    case exportGeoPackageDataSource(dataSource: DataSourceDefinitions?, filters: [DataSourceFilterParameter]? = nil)
    case lightSettings
    case mapLayers
    case coordinateDisplaySettings
    case mapSettings
    case about
    case submitReport
    case disclaimer
    case acknowledgements
    case createRoute
    case editRoute(routeURI: URL?)
    case dataSourceDetail(dataSourceKey: String, itemKey: String)
    case dataSourceRouteDetail(dataSourceKey: String, itemKey: String, waypointURI: URL)
}

enum AsamRoute: Hashable {
    case detail(String)
}

enum DataSourceRoute: Hashable {
    case detail(dataSourceKey: String, itemKey: String)
}

extension View {
    func marlinRoutes() -> some View {
        modifier(MarlinRouteModifier())
    }
}

struct MarlinRouteModifier: ViewModifier {
    @EnvironmentObject var dataSourceList: DataSourceList
    
    func createExportDataSources() -> [DataSourceDefinitions] {
        var dataSources: [DataSourceDefinitions] = []
        
        for dataSource in dataSourceList.mappedDataSources {
            if let def = DataSourceDefinitions.from(dataSource.dataSource.definition) {
                dataSources.append(def)
            }
        }
        return dataSources
    }
    
    // this is being refactored, ignore this error for now
    // swiftlint:disable cyclomatic_complexity function_body_length
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: MarlinRoute.self) { item in
                switch item {
                case .exportGeoPackageDataSource(let dataSource, let filters):
                    GeoPackageExportView(
                        dataSources: dataSource != nil ? [dataSource!] : [],
                        filters: filters,
                        useMapRegion: false)
                case .exportGeoPackage(let useMapRegion):
                    GeoPackageExportView(dataSources: createExportDataSources(), useMapRegion: useMapRegion)
                case .lightSettings:
                    LightSettingsView()
                case .mapSettings:
                    MapSettings()
                case .mapLayers:
                    MapLayersView()
                case .coordinateDisplaySettings:
                    CoordinateDisplaySettings()
                case .about:
                    AboutView()
                case .submitReport:
                    SubmitReportView()
                case .disclaimer:
                    ScrollView {
                        DisclaimerView()
                    }
                case .acknowledgements:
                    AcknowledgementsView()
                case .createRoute:
                    CreateRouteView()
                case .editRoute(let routeURI):
                    CreateRouteView(routeURI: routeURI)
                case .dataSourceDetail(let dataSourceKey, let itemKey):
                    switch dataSourceKey {
                    case Asam.key:
                        AsamDetailView(reference: itemKey)
                    case Modu.key:
                        ModuDetailView(name: itemKey)
                    case Port.key:
                        PortDetailView(portNumber: Int64(itemKey))
                    case NavigationalWarning.key:

                        if let navWarning = NavigationalWarning.getItem(
                            context: PersistenceController.current.viewContext,
                            itemKey: itemKey) as? NavigationalWarning {
                            NavigationalWarningDetailView(navigationalWarning: navWarning)
                        }
                    case NoticeToMariners.key:
                        if let noticeNumber = Int64(itemKey) {
                            NoticeToMarinersFullNoticeView(
                                viewModel: NoticeToMarinersFullNoticeViewViewModel(noticeNumber: noticeNumber))
                        }
                    case DifferentialGPSStation.key:
                        let split = itemKey.split(separator: "--")
                        if split.count == 2 {
                            DifferentialGPSStationDetailView(featureNumber: Int(split[0]), volumeNumber: "\(split[1])")
                        }
                    case Light.key:
                        let split = itemKey.split(separator: "--")
                        if split.count == 3 {
                            LightDetailView(featureNumber: "\(split[0])", volumeNumber: "\(split[1])")
                        }
                    case RadioBeacon.key:
                        let split = itemKey.split(separator: "--")
                        if split.count == 2 {
                            RadioBeaconDetailView(featureNumber: Int(split[0]), volumeNumber: "\(split[1])")
                        }
                    case ElectronicPublication.key:
                        if let epub = ElectronicPublication.getItem(
                            context: PersistenceController.current.viewContext,
                            itemKey: itemKey) as? ElectronicPublication {
                            ElectronicPublicationDetailView(electronicPublication: epub)
                        }
                    case GeoPackageFeatureItem.key:
                        if let gpFeature = GeoPackageFeatureItem.getItem(
                            context: PersistenceController.current.viewContext,
                            itemKey: itemKey) as? GeoPackageFeatureItem {
                            GeoPackageFeatureItemDetailView(featureItem: gpFeature)
                        }
                    case Route.key:
                        CreateRouteView(routeURI: URL(string: itemKey))
                    default:
                        EmptyView()
                    }
                case .dataSourceRouteDetail(let dataSourceKey, let itemKey, let waypointURI):
                    switch dataSourceKey {
                    case Asam.key:
                        AsamDetailView(reference: itemKey, waypointURI: waypointURI)
                    case Modu.key:
                        ModuDetailView(name: itemKey, waypointURI: waypointURI)
                    case Light.key:
                        let split = itemKey.split(separator: "--")
                        if split.count == 3 {
                            LightDetailView(
                                featureNumber: "\(split[0])",
                                volumeNumber: "\(split[1])",
                                waypointURI: waypointURI)
                        }
                    case Port.key:
                        PortDetailView(portNumber: Int64(itemKey), waypointURI: waypointURI)
                    case DifferentialGPSStation.key:
                        let split = itemKey.split(separator: "--")
                        if split.count == 2 {
                            DifferentialGPSStationDetailView(
                                featureNumber: Int(split[0]),
                                volumeNumber: "\(split[1])",
                                waypointURI: waypointURI)
                        }
                    case RadioBeacon.key:
                        let split = itemKey.split(separator: "--")
                        if split.count == 2 {
                            RadioBeaconDetailView(
                                featureNumber: Int(split[0]),
                                volumeNumber: "\(split[1])",
                                waypointURI: waypointURI)
                        }
                    default:
                        EmptyView()
                    }
                }
            }
            .navigationDestination(for: AsamRoute.self) { item in
                switch item {
                case .detail(let reference):
                    // disable this rule in order to execute a statement prior to returning a view
                    // swiftlint:disable redundant_discardable_let
                    let _ = NotificationCenter.default.post(
                        name: .DismissBottomSheet,
                        object: nil,
                        userInfo: nil
                    )
                    // swiftlint:enable redundant_discardable_let

                    AsamDetailView(reference: reference)
                }
            }
            .navigationDestination(for: ItemWrapper.self) { item in
                if let dataSourceViewBuilder = item.dataSource as? (any DataSourceViewBuilder) {
                    dataSourceViewBuilder.detailView
                }
            }
    }
    // swiftlint:enable cyclomatic_complexity function_body_length
}
