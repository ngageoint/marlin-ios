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
                }
            }
            .navigationDestination(for: ItemWrapper.self) { item in
                if let dataSourceViewBuilder = item.dataSource as? (any DataSourceViewBuilder) {
                    dataSourceViewBuilder.detailView
                }
            }
    }
}
