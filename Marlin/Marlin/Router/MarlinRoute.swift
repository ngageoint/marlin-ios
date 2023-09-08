//
//  MarlinRoute.swift
//  Marlin
//
//  Created by Daniel Barela on 6/30/23.
//

import Foundation
import SwiftUI

enum MarlinRoute: Hashable {
    case exportGeoPackage([DataSourceExportRequest])
    case lightSettings
    case mapLayers
    case coordinateDisplaySettings
    case mapSettings
    case about
    case submitReport
    case disclaimer
    case acknowledgements
    case createRoute
    case dataSourceDetail(dataSourceKey: String, itemKey: String)
}

enum AsamRoute: Hashable {
    case detail(String)
}

enum DataSourceRoute: Hashable {
    case detail(dataSourceKey: String, itemKey: String)
}

extension View {
    func marlinRoutes(path: Binding<NavigationPath>) -> some View {
        modifier(MarlinRouteModifier(path: path))
    }
}

struct MarlinRouteModifier: ViewModifier {
    @Binding var path: NavigationPath
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: MarlinRoute.self) { item in
                switch item {
                case .exportGeoPackage(let exportRequest):
                    GeoPackageExportView(exportRequest: exportRequest)
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
                    CreateRouteView(path: $path)
                case .dataSourceDetail(let dataSourceKey, let itemKey):
                    switch dataSourceKey {
                    case Asam.key:
                        let viewModel = AsamViewModel(repository: MainAsamRepository(context: PersistenceController.current.viewContext))
                        AsamDetailView(viewModel: viewModel, reference: itemKey)
                    case Modu.key:
                        if let modu = Modu.getItem(context: PersistenceController.current.viewContext, itemKey: itemKey) as? Modu {
                            ModuDetailView(modu: modu)
                        }
                    case Port.key:
                        if let port = Port.getItem(context: PersistenceController.current.viewContext, itemKey: itemKey) as? Port {
                            PortDetailView(port: port)
                        }
                    case NavigationalWarning.key:

                        if let navWarning = NavigationalWarning.getItem(context: PersistenceController.current.viewContext, itemKey: itemKey) as? NavigationalWarning {
                            NavigationalWarningDetailView(navigationalWarning: navWarning)
                        }
                    case NoticeToMariners.key:
                        if let noticeNumber = Int64(itemKey) {
                            NoticeToMarinersFullNoticeView(viewModel: NoticeToMarinersFullNoticeViewViewModel(noticeNumber: noticeNumber))
                        }
                    case DifferentialGPSStation.key:
                        if let dgps = DifferentialGPSStation.getItem(context: PersistenceController.current.viewContext, itemKey: itemKey) as? DifferentialGPSStation {
                            DifferentialGPSStationDetailView(differentialGPSStation: dgps)
                        }
                    case Light.key:
                        let split = itemKey.split(separator: "--")
                        if split.count == 3 {
                            LightDetailView(featureNumber: "\(split[0])", volumeNumber: "\(split[1])")
                        }
                    case RadioBeacon.key:
                        if let radioBeacon = RadioBeacon.getItem(context: PersistenceController.current.viewContext, itemKey: itemKey) as? RadioBeacon {
                            RadioBeaconDetailView(radioBeacon: radioBeacon)
                        }
                    case ElectronicPublication.key:
                        if let epub = ElectronicPublication.getItem(context: PersistenceController.current.viewContext, itemKey: itemKey) as? ElectronicPublication {
                            ElectronicPublicationDetailView(electronicPublication: epub)
                        }
                    case GeoPackageFeatureItem.key:
                        if let gpFeature = GeoPackageFeatureItem.getItem(context: PersistenceController.current.viewContext, itemKey: itemKey) as? GeoPackageFeatureItem {
                            GeoPackageFeatureItemDetailView(featureItem: gpFeature)
                        }
                    default:
                        EmptyView()
                    }
                }
            }
            .navigationDestination(for: AsamRoute.self) { item in
                let viewModel = AsamViewModel(repository: MainAsamRepository(context: PersistenceController.current.viewContext))

                switch item {
                case .detail(let reference):
                    AsamDetailView(viewModel: viewModel, reference: reference)
                }
            }
            .navigationDestination(for: ItemWrapper.self) { item in
                if let dataSourceViewBuilder = item.dataSource as? (any DataSourceViewBuilder) {
                    dataSourceViewBuilder.detailView
                }
            }
    }
}
