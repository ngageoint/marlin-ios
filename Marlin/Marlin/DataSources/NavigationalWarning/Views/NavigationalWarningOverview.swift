//
//  NavigationalWarningsOverview.swift
//  Marlin
//
//  Created by Daniel Barela on 6/23/22.
//

import SwiftUI
import MapKit

struct NavigationalWarningsOverview<Location>: View where Location: LocationManagerProtocol  {
    @StateObject var navState = NavState()
    
    let MAP_NAME = "Navigational Warning List View Map"
    var locationManager: Location
    @State var expandMap: Bool = false
    @State var selection: String? = nil
    let tabFocus = NotificationCenter.default.publisher(for: .TabRequestFocus)
    let viewDataSourcePub = NotificationCenter.default.publisher(for: .ViewDataSource).compactMap { notification in
        notification.object as? ViewDataSource
    }
    
    @StateObject var itemWrapper: ItemWrapper = ItemWrapper()
    
    init(locationManager: Location = LocationManager.shared()) {
        self.locationManager = locationManager
    }
    
    var body: some View {
        Self._printChanges()
        return GeometryReader { geometry in
            NavigationLink(tag: "detail", selection: $selection) {
                if let data = itemWrapper.dataSource as? DataSourceViewBuilder {
                    data.detailView
                        .environmentObject(navState)
                }
            } label: {
                EmptyView()
            }
            .isDetailLink(false)
            .hidden()
            
            VStack(spacing: 0) {
                NavigationalWarningMapView(bottomButtons: {
                    ViewExpandButton(expanded: $expandMap)
                })
                .frame(minHeight: expandMap ? geometry.size.height : geometry.size.height * 0.3, maxHeight: expandMap ? geometry.size.height : geometry.size.height * 0.5)
                .edgesIgnoringSafeArea([.leading, .trailing])
                NavigationalWarningAreasView(mapName: MAP_NAME)
                    .currentNavArea(locationManager.currentNavArea?.name)
                    .environmentObject(navState)
            }
        }
        .navigationTitle(NavigationalWarning.fullDataSourceName)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.surfaceColor)
        .onReceive(tabFocus) { output in
            let tabName = output.object as? String
            if tabName == nil || tabName == "\(NavigationalWarning.key)List" {
                selection = "Navigational Warning View"
                navState.rootViewId = UUID()
            }
        }
        .onAppear {
            Metrics.shared.appRoute([NavigationalWarning.metricsKey, "group"])
            Metrics.shared.dataSourceList(dataSource: NavigationalWarning.self)
            navState.navGroupName = "\(NavigationalWarning.key)List"
            navState.mapName = MAP_NAME
        }
        .onReceive(viewDataSourcePub) { output in
            if let dataSource = output.dataSource as? NavigationalWarning, output.mapName == MAP_NAME {
                NotificationCenter.default.post(name:.DismissBottomSheet, object: nil)
                itemWrapper.dataSource = dataSource
                itemWrapper.date = Date()
                selection = "detail"
            }
        }
        .id(navState.rootViewId)
    }
    
}
