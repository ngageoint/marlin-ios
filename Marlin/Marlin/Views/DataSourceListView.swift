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
    @State private var path: NavigationPath = NavigationPath()
    
    
    var body: some View {
        Self._printChanges()
        return NavigationStack(path: $path) {
            DataSourceListView(dataSource: dataSource, focusedItem: focusedItem, path: $path)
                .marlinRoutes(path: $path)
        }
    }
}

struct DataSourceListView: View {
    var dataSource: DataSourceItem
    @ObservedObject var focusedItem: ItemWrapper
    var watchFocusedItem: Bool = false
    @Binding var path: NavigationPath
    
    var body: some View {
        if dataSource.key == Asam.key {
            MSIListView<Asam, EmptyView, EmptyView, EmptyView>(path: $path, focusedItem: focusedItem, watchFocusedItem: watchFocusedItem)
        } else if dataSource.key == Modu.key {
            MSIListView<Modu, EmptyView, EmptyView, EmptyView>(path: $path, focusedItem: focusedItem, watchFocusedItem: watchFocusedItem)
        } else if dataSource.key == Light.key {
            MSIListView<Light, EmptyView, EmptyView, EmptyView>(path: $path, focusedItem: focusedItem, watchFocusedItem: watchFocusedItem)
        } else if dataSource.key == NavigationalWarning.key {
            NavigationalWarningsOverview(path: $path, focusedItem: focusedItem, watchFocusedItem: watchFocusedItem)
        } else if dataSource.key == Port.key {
            MSIListView<Port, EmptyView, EmptyView, EmptyView>(path: $path, focusedItem: focusedItem, watchFocusedItem: watchFocusedItem)
        } else if dataSource.key == RadioBeacon.key {
            MSIListView<RadioBeacon, EmptyView, EmptyView, EmptyView>(path: $path, focusedItem: focusedItem, watchFocusedItem: watchFocusedItem)
        } else if dataSource.key == DifferentialGPSStation.key {
            MSIListView<DifferentialGPSStation, EmptyView, EmptyView, EmptyView>(path: $path, focusedItem: focusedItem, watchFocusedItem: watchFocusedItem)
        } else if dataSource.key == DFRS.key {
            MSIListView<DFRS, EmptyView, EmptyView, EmptyView>(path: $path)
        } else if dataSource.key == ElectronicPublication.key {
            ElectronicPublicationsList()
        } else if dataSource.key == NoticeToMariners.key {
            NoticeToMarinersView(path: $path)
        } else if dataSource.key == Bookmark.key {
            BookmarkListView(path: $path, focusedItem: focusedItem, watchFocusedItem: watchFocusedItem)
        } else if dataSource.key == Route.key {
            RouteList(path: $path)
        }
    }
}
