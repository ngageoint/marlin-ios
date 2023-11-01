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
    case mapExportGeoPackage
    case lightSettings
    case mapLayers
    case coordinateDisplaySettings
    case mapSettings
    case about
    case submitReport
    case disclaimer
    case acknowledgements
}

extension View {
    func marlinRoutes(path: Binding<NavigationPath>) -> some View {
        modifier(MarlinRouteModifier(path: path))
    }
}

struct MarlinRouteModifier: ViewModifier {
    @Binding var path: NavigationPath
    @EnvironmentObject var dataSourceList: DataSourceList
    
    func exportRequest() -> [DataSourceExportRequest] {
        var exports: [DataSourceExportRequest] = []
        let region = UserDefaults.standard.mapRegion
        let commonExportRequest = DataSourceExportRequest(
            dataSourceItem: DataSourceItem(
                dataSource: CommonDataSource.self),
            filters: [
                DataSourceFilterParameter(property:
                                            DataSourceProperty(name: "Location",
                                                               key: #keyPath(CommonDataSource.location),
                                                               type: .location),
                                          comparison: .bounds,
                                          valueMinLatitude: region.center.latitude - (region.span.latitudeDelta / 2.0),
                                          valueMinLongitude: region.center.longitude - (region.span.longitudeDelta / 2.0),
                                          valueMaxLatitude: region.center.latitude + (region.span.latitudeDelta / 2.0),
                                          valueMaxLongitude: region.center.longitude + (region.span.longitudeDelta / 2.0))])
        exports.append(commonExportRequest)
        
        for dataSource in dataSourceList.mappedDataSources {
            exports.append(DataSourceExportRequest(dataSourceItem: dataSource, filters: UserDefaults.standard.filter(dataSource.dataSource)))
        }
        return exports
    }

    func body(content: Content) -> some View {
        content
            .navigationDestination(for: MarlinRoute.self) { item in
                switch item {
                case .exportGeoPackage(let exportRequest):
                    GeoPackageExportView(exportRequest: exportRequest)
                case .mapExportGeoPackage:
                    GeoPackageExportView(exportRequest: exportRequest())
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
                }
            }
            .navigationDestination(for: ItemWrapper.self) { item in
                if let dataSourceViewBuilder = item.dataSource as? (any DataSourceViewBuilder) {
                    dataSourceViewBuilder.detailView
                }
            }
    }
}
