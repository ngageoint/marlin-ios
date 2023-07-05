//
//  MapNavigationView.swift
//  Marlin
//
//  Created by Daniel Barela on 5/23/23.
//

import SwiftUI

struct MapNavigationView: View {
    @EnvironmentObject var dataSourceList: DataSourceList
    @Binding var filterOpen: Bool
    @Binding var menuOpen: Bool
    
    @StateObject var itemWrapper: ItemWrapper = ItemWrapper()
    
    @Binding var path: NavigationPath
    
    let viewDataSourcePub = NotificationCenter.default.publisher(for: .ViewDataSource).compactMap { notification in
        notification.object as? ViewDataSource
    }
    let switchTabPub = NotificationCenter.default.publisher(for: .SwitchTabs).map { notification in
        notification.object
    }

    var body: some View {
        Self._printChanges()
        return NavigationStack(path: $path) {
            VStack(spacing: 0) {
                DataLoadedNotificationBanner()
                CurrentLocation()
                ZStack(alignment: .topLeading) {
                    MarlinMainMap(path: $path)
                        .navigationTitle("Marlin")
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarBackButtonHidden(true)
                        .modifier(Hamburger(menuOpen: $menuOpen))
                        .modifier(FilterButton(filterOpen: $filterOpen, dataSources: $dataSourceList.mappedDataSources))
                        .onAppear {
                            Metrics.shared.mapView()
                        }
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel("Marlin Map")
                    
                    LoadingCapsule()
                }
            }
            .navigationDestination(for: DataSourceItem.self) { item in
                DataSourceListView(dataSource: item, focusedItem: itemWrapper, path: $path)
            }
            .marlinRoutes(path: $path)
            .onReceive(viewDataSourcePub) { output in
                if let dataSource = output.dataSource {
                    if output.mapName == nil || output.mapName == "Marlin Map" {
                        viewData(dataSource)
                    }
                }
            }
            .onReceive(switchTabPub) { output in
                if let output = output as? String {
                    if output == "settings" {
                        path.append(MarlinRoute.about)
                    } else if output == "submitReport" {
                        path.append(MarlinRoute.submitReport)
                    } else {
                        let tab = dataSourceList.tabs.contains(where: { item in
                            item.key == output
                        })
                        if !tab, let dataSourceItem = dataSourceList.allTabs.first(where: { item in
                            item.key == output
                        }) {
                            print("append \(dataSourceItem) to path")
                            path.append(dataSourceItem)
                        }
                    }
                }
            }
        }
    }
    
    func viewData(_ data: any DataSource) {
        NotificationCenter.default.post(name: .FocusMapOnItem, object: FocusMapOnItemNotification(item: nil))
        NotificationCenter.default.post(name:.DismissBottomSheet, object: nil)
        let itemWrapper = ItemWrapper()
        itemWrapper.dataSource = data
        itemWrapper.date = Date()
        path.append(itemWrapper)
    }
}
