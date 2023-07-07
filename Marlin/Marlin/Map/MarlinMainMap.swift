//
//  MarlinMainMap.swift
//  Marlin
//
//  Created by Daniel Barela on 5/23/23.
//

import SwiftUI
import MapKit

struct MarlinMainMap: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    
    @StateObject var mixins: MainMapMixins = MainMapMixins()
    @StateObject var mapState: MapState = MapState()
    
    @Binding var path: NavigationPath
    
    @EnvironmentObject var dataSourceList: DataSourceList
    
    let focusMapAtLocation = NotificationCenter.default.publisher(for: .FocusMapAtLocation)
    
    var body: some View {
        Self._printChanges()
        return VStack {
            MarlinMap(name: "Marlin Map", mixins: mixins, mapState: mapState)
                .ignoresSafeArea()
        }
        .onReceive(focusMapAtLocation) { notification in
            mapState.forceCenter = notification.object as? MKCoordinateRegion
        }
        .overlay(bottomButtons(), alignment: .bottom)
        .overlay(topButtons(), alignment: .top)
    }
    
    @ViewBuilder
    func topButtons() -> some View {
        HStack(alignment: .top, spacing: 8) {
            // top left button stack
            VStack(alignment: .leading, spacing: 8) {
                SearchView(mapState: mapState)
            }
            .padding(.leading, 8)
            .padding(.top, 16)
            Spacer()
            // top right button stack
            VStack(alignment: .trailing, spacing: 16) {
                NavigationLink(value: MarlinRoute.mapSettings) {
                    Label(
                        title: {},
                        icon: { Image(systemName: "square.3.stack.3d")
                                .renderingMode(.template)
                        }
                    )
                }
                .isDetailLink(false)
                .fixedSize()
                .buttonStyle(MaterialFloatingButtonStyle(type: .secondary, size: .mini, foregroundColor: Color.primaryColorVariant, backgroundColor: Color.mapButtonColor))
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Map Settings Button")
            }
            .padding(.trailing, 8)
            .padding(.top, 16)
        }
    }
    
    func exportRequest() -> [DataSourceExportRequest] {
        var exports: [DataSourceExportRequest] = []
        for dataSource in dataSourceList.mappedDataSources {
            exports.append(DataSourceExportRequest(dataSourceItem: dataSource, filters: UserDefaults.standard.filter(dataSource.dataSource)))
        }
        return exports
    }
    
    @ViewBuilder
    func bottomButtons() -> some View {
        HStack(alignment: .bottom, spacing: 0) {
            let layout = verticalSizeClass != .compact ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8)) : AnyLayout(HStackLayout(alignment: .bottom, spacing: 8))
            
            layout {
                DataSourceToggles()
            }
            .padding(.leading, 8)
            .padding(.bottom, 30)
            
            Spacer()
            // bottom right button stack
            VStack(alignment: .trailing, spacing: 16) {
                NavigationLink(value: MarlinRoute.exportGeoPackage(exportRequest())) {
                    Label(
                        title: {},
                        icon: { Image(systemName: "square.and.arrow.down")
                                .renderingMode(.template)
                        }
                    )
                }
                .isDetailLink(false)
                .fixedSize()
                .buttonStyle(MaterialFloatingButtonStyle(type: .secondary, size: .mini, foregroundColor: Color.primaryColorVariant, backgroundColor: Color.mapButtonColor))
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Export Button")
                
                UserTrackingButton(mapState: mapState)
                    .fixedSize()
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("User Tracking")
            }
            .padding(.trailing, 8)
            .padding(.bottom, 30)
        }
    }
}
