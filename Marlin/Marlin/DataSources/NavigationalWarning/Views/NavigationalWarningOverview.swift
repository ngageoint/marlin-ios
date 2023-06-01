//
//  NavigationalWarningsOverview.swift
//  Marlin
//
//  Created by Daniel Barela on 6/23/22.
//

import SwiftUI
import MapKit

struct NavigationalWarningsOverview: View {
    @ObservedObject var generalLocation: GeneralLocation = GeneralLocation.shared
    
    let MAP_NAME = "Navigational Warning List View Map"
    @State var expandMap: Bool = false
    @State var selection: String? = nil
    let viewDataSourcePub = NotificationCenter.default.publisher(for: .ViewDataSource).compactMap { notification in
        notification.object as? ViewDataSource
    }
    
    @StateObject var itemWrapper: ItemWrapper = ItemWrapper()
    
    var body: some View {
        Self._printChanges()
        return GeometryReader { geometry in
            NavigationLink(tag: "detail", selection: $selection) {
                if let data = itemWrapper.dataSource as? DataSourceViewBuilder {
                    data.detailView
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
                    .currentNavArea(generalLocation.currentNavArea?.name)
            }
        }
        .navigationTitle(NavigationalWarning.fullDataSourceName)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.surfaceColor)
        .onAppear {
            Metrics.shared.appRoute([NavigationalWarning.metricsKey, "group"])
            Metrics.shared.dataSourceList(dataSource: NavigationalWarning.self)
        }
        .onReceive(viewDataSourcePub) { output in
            if let dataSource = output.dataSource as? NavigationalWarning, output.mapName == MAP_NAME {
                NotificationCenter.default.post(name:.DismissBottomSheet, object: nil)
                itemWrapper.dataSource = dataSource
                itemWrapper.date = Date()
                selection = "detail"
            }
        }
    }
    
}
