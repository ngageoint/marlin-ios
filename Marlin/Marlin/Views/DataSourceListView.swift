//
//  DataSourceListView.swift
//  Marlin
//
//  Created by Daniel Barela on 5/23/23.
//

import SwiftUI

struct DataSourceNavView: View {
    var dataSource: DataSourceItem
    @ObservedObject var focusedItem: ItemWrapper
    var watchFocusedItem: Bool = false
    @ObservedObject private var router: MarlinRouter = MarlinRouter()

    var body: some View {
        Self._printChanges()
        return NavigationStack(path: $router.path) {
            DataSourceListView(dataSource: dataSource, focusedItem: focusedItem)
                .marlinRoutes()
                .environmentObject(router)
        }
    }
}

struct DataSourceListView: View {
    var dataSource: DataSourceItem
    @ObservedObject var focusedItem: ItemWrapper
    var watchFocusedItem: Bool = false
    @EnvironmentObject var router: MarlinRouter

    var body: some View {
        if dataSource.key == DataSources.asam.key {
            AsamList()
        } else if dataSource.key == DataSources.modu.key {
            ModuList()
        } else if dataSource.key == Light.key {
            MSIListView<Light, EmptyView, EmptyView, EmptyView>(
                focusedItem: focusedItem,
                watchFocusedItem: watchFocusedItem
            )
        } else if dataSource.key == NavigationalWarning.key {
            NavigationalWarningsOverview(
                focusedItem: focusedItem,
                watchFocusedItem: watchFocusedItem
            )
        } else if dataSource.key == DataSources.port.key {
            PortList()
        } else if dataSource.key == RadioBeacon.key {
            MSIListView<RadioBeacon, EmptyView, EmptyView, EmptyView>(
                focusedItem: focusedItem,
                watchFocusedItem: watchFocusedItem
            )
        } else if dataSource.key == DifferentialGPSStation.key {
            MSIListView<DifferentialGPSStation, EmptyView, EmptyView, EmptyView>(
                focusedItem: focusedItem,
                watchFocusedItem: watchFocusedItem
            )
        } else if dataSource.key == DFRS.key {
            MSIListView<DFRS, EmptyView, EmptyView, EmptyView>()
        } else if dataSource.key == ElectronicPublication.key {
            ElectronicPublicationsList()
        } else if dataSource.key == NoticeToMariners.key {
            NoticeToMarinersView()
        } else if dataSource.key == Bookmark.key {
            BookmarkListView(
                focusedItem: focusedItem,
                watchFocusedItem: watchFocusedItem
            )
        } else if dataSource.key == Route.key {
            RouteList()
        }
    }
}
