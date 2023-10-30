//
//  MarlinRegularWidth.swift
//  Marlin
//
//  Created by Daniel Barela on 8/5/22.
//

import SwiftUI
import MapKit

struct MarlinRegularWidth: View {
    @EnvironmentObject var appState: AppState

    @AppStorage("selectedTab") var selectedTab: String = "map"
    @AppStorage("initialDataLoaded") var initialDataLoaded: Bool = false

    @State var activeRailItem: DataSourceItem? = nil
    @State var menuOpen: Bool = false
    @Binding var filterOpen: Bool
    @State private var path: NavigationPath = NavigationPath()

    @EnvironmentObject var dataSourceList: DataSourceList
        
    let viewDataSourcePub = NotificationCenter.default.publisher(for: .ViewDataSource).compactMap { notification in
        notification.object as? ViewDataSource
    }
    let switchTabPub = NotificationCenter.default.publisher(for: .SwitchTabs).map { notification in
        notification.object
    }
    let mapFocus = NotificationCenter.default.publisher(for: .TabRequestFocus)
    
    @StateObject var itemWrapper: ItemWrapper = ItemWrapper()
    @State var selection: String? = nil
        
    @StateObject var mixins: MainMapMixins = MainMapMixins()
    
    @ViewBuilder
    func rail() -> some View {
        NavigationStack {
            DataSourceRail(activeRailItem: $activeRailItem)
                .onAppear {
                    var found = false
                    for item in dataSourceList.allTabs {
                        if "\(item.key)List" == selectedTab {
                            activeRailItem = item
                            found = true
                        }
                    }
                    if !found {
                        activeRailItem = dataSourceList.tabs[0]
                    }
                }
                .background(Color.surfaceColor)
                .padding(.horizontal, 2)
                .onChange(of: activeRailItem) { newValue in
                    if let item = newValue {
                        selectedTab = "\(item.key)List"
                    }
                }
                .modifier(Hamburger(menuOpen: $menuOpen))
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Data Source Rail")
        }
    }
    
    @ViewBuilder
    func list() -> some View {
        if let activeRailItem = activeRailItem {
            DataSourceNavView(dataSource: activeRailItem, focusedItem: itemWrapper, watchFocusedItem: true)
                .background(Color.backgroundColor)
                .accessibilityElement(children: .contain)
                .accessibilityLabel("\(activeRailItem.dataSource.definition.fullName) List")
        }
    }
    
    @ViewBuilder
    func map() -> some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                DataLoadedNotificationBanner()
                CurrentLocation()
                ZStack(alignment: .topLeading) {
                    MarlinMainMap(path: $path)
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel("Marlin Map")
                        .onAppear {
                            Metrics.shared.mapView()
                        }
                    loadingCapsule()
                }
            }
            .marlinRoutes(path: $path)
            .modifier(FilterButton(filterOpen: $filterOpen, dataSources: $dataSourceList.mappedDataSources))
            .navigationTitle("Marlin")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    @State private var visibility: NavigationSplitViewVisibility = .all
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                rail()
                    .frame(minWidth: 72, idealWidth: 72, maxWidth: 72)
                list()
                    .frame(minWidth: 256, idealWidth: 360, maxWidth: 360)
                map()
            }
            GeometryReader { geometry in
                SideMenu(width: min(geometry.size.width - 56, 512),
                         isOpen: self.menuOpen,
                         menuClose: self.openMenu
                )
                .opacity(self.menuOpen ? 1 : 0)
                .animation(.default, value: self.menuOpen)
            }
        }
        .onReceive(viewDataSourcePub) { output in
            if let dataSource = output.dataSource {
                viewData(dataSource)
            }
        }
        .onReceive(switchTabPub) { output in
            if let output = output as? String {
                if output == "settings" {
                    path.append(MarlinRoute.about)
                } else if output == "submitReport" {
                    path.append(MarlinRoute.submitReport)
                } else {
                    let dataSource = dataSourceList.allTabs.first { item in
                        item.key == output
                    }
                    self.activeRailItem = dataSource
                }
                self.menuOpen = false
            }
        }
        
        .navigationTitle("Marlin")
        .navigationBarTitleDisplayMode(.inline)
    }

    func openMenu() {
        self.menuOpen.toggle()
    }
    
    func viewData(_ data: any DataSource) {
        NotificationCenter.default.post(name: .FocusMapOnItem, object: FocusMapOnItemNotification(item: nil))
        NotificationCenter.default.post(name:.DismissBottomSheet, object: nil)
        activeRailItem = dataSourceList.allTabs.first(where: { item in
            item.dataSource == type(of: data.self)
        })
        itemWrapper.dataSource = data
        itemWrapper.date = Date()
    }
    
    @ViewBuilder
    func loadingCapsule() -> some View {
        HStack {
            Spacer()
            Capsule()
                .fill(Color.primaryColor)
                .frame(width: 175, height: 25)
                .overlay(
                    HStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.onPrimaryColor))
                            .scaleEffect(0.5, anchor: .center)
                        Text("Loading initial data")
                            .font(Font.overline)
                            .foregroundColor(Color.onPrimaryColor)
                    }
                )
            Spacer()
        }
        .animation(.default, value: initialDataLoaded)
        .opacity(initialDataLoaded ? 0.0 : 1.0)
        .padding(.top, 8)
    }
}
