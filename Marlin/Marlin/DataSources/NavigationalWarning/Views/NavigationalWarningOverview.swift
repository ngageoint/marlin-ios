//
//  NavigationalWarningsOverview.swift
//  Marlin
//
//  Created by Daniel Barela on 6/23/22.
//

import SwiftUI
import MapKit

struct NavigationalWarningsOverview {
    @ObservedObject var generalLocation: GeneralLocation = GeneralLocation.shared
    
    let MAP_NAME = "Navigational Warning List View Map"
    @State var expandMap: Bool = false
    @State var selection: String? = nil
    @State private var path: NavigationPath = NavigationPath()
    
    @ObservedObject var focusedItem: ItemWrapper = ItemWrapper()
    var watchFocusedItem: Bool = false
    
    let viewDataSourcePub = NotificationCenter.default.publisher(for: .ViewDataSource).compactMap { notification in
        notification.object as? ViewDataSource
    }
}

extension NavigationalWarningsOverview: View {
    var body: some View {
        Self._printChanges()
        return NavigationStack(path: $path) {
            VStack(spacing: 0) {
                GeometryReader { geometry in
                    
                    NavigationalWarningMapView(bottomButtons: {
                        ViewExpandButton(expanded: $expandMap)
                    })
                    .frame(minHeight: expandMap ? geometry.size.height : geometry.size.height * 0.3, maxHeight: expandMap ? geometry.size.height : geometry.size.height * 0.5)
                    .edgesIgnoringSafeArea([.leading, .trailing])
                }
                NavigationalWarningAreasView(mapName: MAP_NAME, path: $path)
                    .currentNavArea(generalLocation.currentNavArea?.name)
            }
            .navigationTitle(NavigationalWarning.fullDataSourceName)
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.surfaceColor)
            .navigationDestination(for: NavigationalWarning.self) { item in
                item.detailView
                    .onDisappear {
                        focusedItem.dataSource = nil
                    }
            }
            .navigationDestination(for: NavigationalWarningSection.self) { section in
                NavigationalWarningNavAreaListView(warnings: section.warnings, navArea: section.id, mapName: MAP_NAME, path: $path)
                    .accessibilityElement(children: .contain)
            }
        }
        .onChange(of: focusedItem.date) { newValue in
            if watchFocusedItem, let focusedItem = focusedItem.dataSource as? NavigationalWarning {
                path.append(focusedItem)
            }
        }
        .onAppear {
            if watchFocusedItem, let focusedItem = focusedItem.dataSource as? NavigationalWarning {
                path.append(focusedItem)
            }
            Metrics.shared.appRoute([NavigationalWarning.metricsKey, "group"])
            Metrics.shared.dataSourceList(dataSource: NavigationalWarning.self)
        }
        .onReceive(viewDataSourcePub) { output in
            if let dataSource = output.dataSource as? NavigationalWarning, output.mapName == MAP_NAME {
                NotificationCenter.default.post(name:.DismissBottomSheet, object: nil)
                path.append(dataSource)
            }
        }
    }
    
}
