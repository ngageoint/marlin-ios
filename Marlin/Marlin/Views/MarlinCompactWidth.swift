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
    
    @ObservedObject var dataSourceList: DataSourceList
    @State var menuOpen: Bool = false
    @State var selection: String? = nil
    @StateObject var itemWrapper: ItemWrapper = ItemWrapper()
    
    let viewDataSourcePub = NotificationCenter.default.publisher(for: .ViewDataSource)
    let mapFocus = NotificationCenter.default.publisher(for: .MapRequestFocus)
    let switchTabPub = NotificationCenter.default.publisher(for: .SwitchTabs).map { notification in
        notification.object
    }
    
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
                                HStack(alignment: .top, spacing: 0) {
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
                        }
                        NavigationLink(tag: "detail", selection: $selection) {
                            DataDetailView(data: itemWrapper.dataSource)
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
                
                ForEach(dataSourceList.tabs, id: \.self) { dataSource in
                    NavigationView {
                        createListView(dataSource: dataSource)
                            .if(UserDefaults.standard.hamburger) { view in
                                view.modifier(Hamburger(menuOpen: $menuOpen))
                            }
                    }
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
                    if dataSourceList.tabs.contains(where: { item in
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
        }
    }
    
    func openMenu() {
        self.menuOpen.toggle()
    }
    
    func viewData(_ data: DataSource) {
        NotificationCenter.default.post(name: .MapAnnotationFocused, object: MapAnnotationFocusedNotification(annotation: nil))
        NotificationCenter.default.post(name:.DismissBottomSheet, object: nil)
        itemWrapper.dataSource = data
        itemWrapper.date = Date()
        selection = "detail"
    }
}

