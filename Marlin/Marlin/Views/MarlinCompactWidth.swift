//
//  MarlinCompactWidth.swift
//  Marlin
//
//  Created by Daniel Barela on 8/5/22.
//

import SwiftUI
import MapKit

struct MarlinCompactWidth: View {
    @EnvironmentObject var appState: AppState
    
    @AppStorage("selectedTab") var selectedTab: String = "map"
    @AppStorage("initialDataLoaded") var initialDataLoaded: Bool = false
    @State var loadingData: Bool = false

    @AppStorage("searchEnabled") var searchEnabled: Bool = false
    @State var search: String = ""
    @AppStorage("searchExpanded") var searchExpanded: Bool = false
    
    @ObservedObject var dataSourceList: DataSourceList
    @State var menuOpen: Bool = false
    @State var selection: String? = nil
    @StateObject var itemWrapper: ItemWrapper = ItemWrapper()
    
    let viewDataSourcePub = NotificationCenter.default.publisher(for: .ViewDataSource)
    let mapFocus = NotificationCenter.default.publisher(for: .MapRequestFocus)
    let switchTabPub = NotificationCenter.default.publisher(for: .SwitchTabs).map { notification in
        notification.object
    }
    let dataSourceLoadedPub = NotificationCenter.default.publisher(for: .DataSourceLoaded)
    let dataSourceLoadingPub = NotificationCenter.default.publisher(for: .DataSourceLoading)

    var marlinMap: MarlinMap
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                NavigationView {
                    VStack {
                        ZStack(alignment: .topLeading) {
                            marlinMap
                                .navigationTitle("Marlin")
                                .navigationBarTitleDisplayMode(.inline)
                                .navigationBarBackButtonHidden(true)
                                .if(UserDefaults.standard.hamburger) { view in
                                    view.modifier(Hamburger(menuOpen: $menuOpen))
                                }
                            VStack {
                                // top of map
                                HStack(alignment: .top, spacing: 8) {
                                    // top left button stack
                                    VStack(alignment: .leading, spacing: 16) {
                                        if searchEnabled {
                                            HStack(alignment: .center, spacing: 0) {
                                                Image(systemName: "magnifyingglass")
                                                    .font(.system(size: 18))
                                                    .frame(width: 24, height: 24, alignment: .center)
                                                    .onTapGesture {
                                                        searchExpanded.toggle()
                                                    }
                                                TextField("Search", text: $search)
                                                    .frame(maxWidth: searchExpanded ? .infinity : 0)
                                                
                                            }
                                            .frame(minWidth: 40, maxWidth: searchExpanded ? .infinity : 40, minHeight: 40, maxHeight: 40)
                                            .padding([.leading, .trailing], searchExpanded ? 8 : 0)
                                            .font(Font.body2)
                                            .foregroundColor(Color.primaryColorVariant)
                                            .background(
                                                RoundedRectangle(cornerRadius: 20).fill(Color.surfaceColor).shadow(color: Color(.sRGB, white: 0, opacity: 0.4), radius: 3, x: 0, y: 4)
                                            )
                                            .animation(.default, value: searchExpanded)
                                            .offset(x: 8, y: 16)
                                        }
                                    }
                                    Spacer()
                                    // top right button stack
                                    VStack(alignment: .trailing, spacing: 16) {
                                        NavigationLink {
                                            MapSettings()
                                        } label: {
                                            Label(
                                                title: {},
                                                icon: { Image(systemName: "square.3.stack.3d")
                                                        .renderingMode(.template)
                                                }
                                            )
                                        }
                                        .isDetailLink(false)
                                        .offset(x: -8, y: 16)
                                        .fixedSize()
                                        .buttonStyle(MaterialFloatingButtonStyle(type: .secondary, size: .mini))
                                    }
                                }
                                Spacer()
                                // bottom of map
                                HStack(alignment: .bottom, spacing: 0) {
                                    Spacer()
                                    // bottom right button stack
                                    VStack(alignment: .trailing, spacing: 16) {
                                        UserTrackingButton(mapState: marlinMap.mapState)
                                            .offset(x: -8, y: -24)
                                            .fixedSize()
                                    }
                                }
                            }
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
                            
                            HStack {
                                Spacer()
                                Capsule()
                                    .fill(Color.primaryColor)
                                    .frame(width: 150, height: 25)
                                    .overlay(
                                        HStack {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: Color.onPrimaryColor))
                                                .scaleEffect(0.5, anchor: .center)
                                            Text("Updating data")
                                                .font(Font.overline)
                                                .foregroundColor(Color.onPrimaryColor)
                                        }
                                    )
                                Spacer()
                            }
                            .animation(.easeInOut(duration: 2.0), value: loadingData)
                            .opacity(loadingData && initialDataLoaded ? 1.0 : 0.0)
                            .padding(.top, 8)
                            .transition(.opacity)
                        }
                        NavigationLink(tag: "detail", selection: $selection) {
                            if let data = itemWrapper.dataSource as? DataSourceViewBuilder {
                                data.detailView
                            }
                        } label: {
                            EmptyView()
                        }
                        .isDetailLink(false)
                        .hidden()
                        
                        NavigationLink(tag: "settings", selection: $selection) {
                            SettingsView()
                        } label: {
                            EmptyView()
                        }
                        .isDetailLink(false)
                        .hidden()
                        
                        ForEach(dataSourceList.nonTabs) { dataSource in
                            
                            NavigationLink(tag: "\(dataSource.key)List", selection: $selection) {
                                createListView(dataSource: dataSource)
                            } label: {
                                EmptyView()
                            }
                            
                            .isDetailLink(false)
                            .hidden()
                        }
                    }
                    .onReceive(self.appState.$popToRoot) { popToRoot in
                        if popToRoot {
                            self.selection = "map"
                            self.appState.popToRoot = false
                        }
                    }
                }
                .tag("map")
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
                // this affects text buttons, image buttons need .foregroundColor set on them
                .tint(Color.onPrimaryColor)
                .navigationViewStyle(.stack)
                .statusBar(hidden: false)
                // This is deprecated, but in iOS16 this is the only way to set the back button color
                .accentColor(Color.onPrimaryColor)
                
                ForEach(dataSourceList.tabs, id: \.self) { dataSource in
                    NavigationView {
                        createListView(dataSource: dataSource)
                            .if(UserDefaults.standard.hamburger) { view in
                                view.modifier(Hamburger(menuOpen: $menuOpen))
                            }
                    }
                    // This is deprecated, but in iOS16 this is the only way to set the back button color
                    .accentColor(Color.onPrimaryColor)
                    // This must be set or navigation links that are nested more than 2 deep will auto pop off
                    .navigationViewStyle(.stack)
                    .tabItem {
                        if let imageName = dataSource.dataSource.imageName {
                            Label(dataSource.dataSource.dataSourceName, image: imageName)
                        } else if let imageName = dataSource.dataSource.systemImageName {
                            Label(dataSource.dataSource.dataSourceName, systemImage: imageName)
                        } else {
                            Label(dataSource.dataSource.dataSourceName, systemImage: "list.bullet.rectangle.fill")
                        }
                    }
                    .tag("\(dataSource.key)List")
                }
            }
            .onReceive(viewDataSourcePub) { output in
                if let dataSource = output.object as? DataSource {
                    viewData(dataSource)
                }
            }
            .onReceive(mapFocus) { output in
                selectedTab = "map"
                self.appState.popToRoot = true
            }
            .onReceive(switchTabPub) { output in
                if let output = output as? String {
                    if output == "settings" {
                        selectedTab = "map"
                        selection = "settings"
                    } else if dataSourceList.tabs.contains(where: { item in
                            item.key == output
                        }) {
                        selectedTab = "\(output)List"
                    } else {
                        selectedTab = "map"
                        selection = "\(output)List"
                    }
                    self.menuOpen = false
                }
            }
            .onReceive(dataSourceLoadedPub) { output in
                print("data source updated pub")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    let loading = dataSourceList.allTabs.contains { dataSourceItem in
                        return appState.loadingDataSource[dataSourceItem.key] ?? false

                    }
                    withAnimation {
                        loadingData = loading
                    }
                }
            }
            .onReceive(dataSourceLoadingPub) { output in
                print("data source loading pub")
                DispatchQueue.main.async {
                    let loading = dataSourceList.allTabs.contains { dataSourceItem in
                        return appState.loadingDataSource[dataSourceItem.key] ?? false

                    }
                    withAnimation {
                        loadingData = loading
                    }
                }
            }
            
            GeometryReader { geometry in
                SideMenu(width: geometry.size.width - 56,
                         isOpen: self.menuOpen,
                         menuClose: self.openMenu,
                         dataSourceList: dataSourceList
                )
            }
        }
    }
    
    @ViewBuilder
    func createListView(dataSource: DataSourceItem) -> some View {
        if dataSource.key == Asam.key {
            AsamListView(focusedItem: itemWrapper)
        } else if dataSource.key == Modu.key {
            ModuListView(focusedItem: itemWrapper)
        } else if dataSource.key == Light.key {
            LightsListView(focusedItem: itemWrapper)
        } else if dataSource.key == NavigationalWarning.key {
            NavigationalWarningListView()
        } else if dataSource.key == Port.key {
            PortListView(focusedItem: itemWrapper)
        } else if dataSource.key == RadioBeacon.key {
            RadioBeaconListView(focusedItem: itemWrapper)
        } else if dataSource.key == DifferentialGPSStation.key {
            DifferentialGPSStationListView(focusedItem: itemWrapper)
        } else if dataSource.key == DFRS.key {
            DFRSListView(focusedItem: itemWrapper)
        }
    }
    
    func openMenu() {
        self.menuOpen.toggle()
    }
    
    func viewData(_ data: DataSource) {
        NotificationCenter.default.post(name: .FocusMapOnItem, object: FocusMapOnItemNotification(item: nil))
        NotificationCenter.default.post(name:.DismissBottomSheet, object: nil)
        itemWrapper.dataSource = data
        itemWrapper.date = Date()
        selection = "detail"
    }
}

