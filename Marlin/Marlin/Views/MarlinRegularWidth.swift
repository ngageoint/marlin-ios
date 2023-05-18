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

    @ObservedObject var dataSourceList: DataSourceList
        
    let viewDataSourcePub = NotificationCenter.default.publisher(for: .ViewDataSource).compactMap { notification in
        notification.object as? ViewDataSource
    }
    let switchTabPub = NotificationCenter.default.publisher(for: .SwitchTabs).map { notification in
        notification.object
    }
    let mapFocus = NotificationCenter.default.publisher(for: .TabRequestFocus)
    
    @StateObject var itemWrapper: ItemWrapper = ItemWrapper()
    @State var selection: String? = nil
        
    var marlinMap: MarlinMap
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    HStack(spacing: 0) {
                        DataSourceRail(dataSourceList: dataSourceList, activeRailItem: $activeRailItem)
                            .frame(minWidth: 72, idealWidth: 72, maxWidth: 72)
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
                            .accessibilityElement(children: .contain)
                            .accessibilityLabel("Data Source Rail")
                        
                        if let activeRailItem = activeRailItem {
                            NavigationView {
                                createListView(dataSource: activeRailItem)
                            }
                            .navigationViewStyle(.stack)
                            .frame(minWidth: 256, idealWidth: 360, maxWidth: 360)
                            .background(Color.backgroundColor)
                        }
                        
                        NavigationView {
                            ZStack(alignment: .topLeading) {
                                marlinMap
                                    .accessibilityElement(children: .contain)
                                    .accessibilityLabel("Marlin Map")
                                    .ignoresSafeArea()
                                    .onAppear {
                                        Metrics.shared.mapView()
                                    }
                                VStack(spacing: 0) {
                                    // top of map
                                    DataLoadedNotificationBanner()
                                    CurrentLocation()
                                    topButtons()
                                    Spacer()
                                    // bottom of map
                                    bottomButtons()
                                }
                                loadingCapsule()
                                
                            }
                            .navigationBarHidden(true)
                        }.navigationViewStyle(.stack)
                    }
                    .onReceive(viewDataSourcePub) { output in
                        if let dataSource = output.dataSource {
                            viewData(dataSource)
                        }
                    }
                    .onReceive(switchTabPub) { output in
                        if let output = output as? String {
                            let dataSource = dataSourceList.allTabs.first { item in
                                item.key == output
                            }
                            self.activeRailItem = dataSource
                        }
                    }
                    .modifier(FilterButton(filterOpen: $filterOpen, dataSources: $dataSourceList.mappedDataSources))
                    
                    GeometryReader { geometry in
                        SideMenu(width: min(geometry.size.width - 56, 512),
                                 isOpen: self.menuOpen,
                                 menuClose: self.openMenu,
                                 dataSourceList: dataSourceList
                        )
                        .opacity(self.menuOpen ? 1 : 0)
                        .animation(.default, value: self.menuOpen)
                        .onReceive(switchTabPub) { output in
                            if let output = output as? String {
                                if output == "settings" {
                                    selection = "settings"
                                } else if output == "submitReport" {
                                    selection = "submitReport"
                                } else {
                                    selection = "\(output)List"
                                }
                                self.menuOpen = false
                            }
                        }
                    }
                }
                .if(UserDefaults.standard.hamburger) { view in
                    view.modifier(Hamburger(menuOpen: $menuOpen))
                }
                .navigationTitle("Marlin")
                .navigationBarTitleDisplayMode(.inline)
                NavigationLink(tag: "settings", selection: $selection) {
                    AboutView()
                } label: {
                    EmptyView()
                }
                .isDetailLink(false)
                .hidden()
                
                NavigationLink(tag: "submitReport", selection: $selection) {
                    SubmitReportView()
                } label: {
                    EmptyView()
                }
                .isDetailLink(false)
                .hidden()
            }
        }
        .tint(Color.onPrimaryColor)
        .navigationViewStyle(.stack)
    }
    
    func openMenu() {
        self.menuOpen.toggle()
    }
    
    func viewData(_ data: any DataSource) {
        NotificationCenter.default.post(name: .FocusMapOnItem, object: FocusMapOnItemNotification(item: nil))
        NotificationCenter.default.post(name:.DismissBottomSheet, object: nil)
        itemWrapper.dataSource = data
        itemWrapper.date = Date()
        activeRailItem = dataSourceList.allTabs.first(where: { item in
            item.dataSource == type(of: data.self)
        })
        
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
    
    @ViewBuilder
    func createListView(dataSource: DataSourceItem) -> some View {
        Group {
            if dataSource.key == Asam.key {
                MSIListView<Asam, EmptyView, EmptyView>(focusedItem: itemWrapper, watchFocusedItem: true)
            } else if dataSource.key == Modu.key {
                MSIListView<Modu, EmptyView, EmptyView>(focusedItem: itemWrapper, watchFocusedItem: true)
            } else if dataSource.key == Light.key {
                MSIListView<Light, EmptyView, EmptyView>(focusedItem: itemWrapper, watchFocusedItem: true)
            } else if dataSource.key == NavigationalWarning.key {
                NavigationalWarningListView()
            } else if dataSource.key == Port.key {
                MSIListView<Port, EmptyView, EmptyView>(focusedItem: itemWrapper, watchFocusedItem: true)
            } else if dataSource.key == RadioBeacon.key {
                MSIListView<RadioBeacon, EmptyView, EmptyView>(focusedItem: itemWrapper, watchFocusedItem: true)
            } else if dataSource.key == DifferentialGPSStation.key {
                MSIListView<DifferentialGPSStation, EmptyView, EmptyView>(focusedItem: itemWrapper, watchFocusedItem: true)
            } else if dataSource.key == DFRS.key {
                MSIListView<DFRS, EmptyView, EmptyView>(focusedItem: itemWrapper, watchFocusedItem: true)
            } else if dataSource.key == ElectronicPublication.key {
                ElectronicPublicationsList()
            } else if dataSource.key == NoticeToMariners.key {
                NoticeToMarinersView()
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(dataSource.dataSource.fullDataSourceName) List")
    }
    
    @ViewBuilder
    func topButtons() -> some View {
        HStack(alignment: .top, spacing: 8) {
            // top left button stack
            VStack(alignment: .leading, spacing: 8) {
                SearchView(mapState: marlinMap.mapState)
            }
            .padding(.leading, 8)
            .padding(.top, 16)
            Spacer()
            // top right button stack
            VStack(alignment: .trailing, spacing: 16) {
                NavigationLink {
                    MapSettings(mapState: marlinMap.mapState)
                } label: {
                    Label(
                        title: {},
                        icon: { Image(systemName: "square.3.stack.3d")
                                .renderingMode(.template)
                        }
                    )
                }
                .isDetailLink(false)
                .fixedSize()
                .buttonStyle(MaterialFloatingButtonStyle(type: .secondary, size: .mini))
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Map Settings Button")
            }
            .padding(.trailing, 8)
            .padding(.top, 16)
        }
    }
    
    @ViewBuilder
    func bottomButtons() -> some View {
        HStack(alignment: .bottom, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(dataSourceList.allTabs, id: \.self) { dataSource in
                    if dataSource.dataSource.isMappable {
                        Button(action: {
                            dataSource.showOnMap.toggle()
                        }) {
                            Label(title: {}) {
                                if let image = dataSource.dataSource.image {
                                    Image(uiImage: image)
                                        .renderingMode(.template)
                                        .tint(Color.white)
                                }
                            }
                        }
                        .buttonStyle(MaterialFloatingButtonStyle(type: .custom, size: .mini, foregroundColor: dataSource.showOnMap ? Color.white : Color.disabledColor, backgroundColor: dataSource.showOnMap ? Color(uiColor: dataSource.dataSource.color) : Color.disabledBackground))
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel("\(dataSource.dataSource.key) Map Toggle")
                    }
                }
            }
            .padding(.leading, 8)
            .padding(.bottom, 30)
            
            Spacer()
            // bottom right button stack
            VStack(alignment: .trailing, spacing: 16) {
                UserTrackingButton(mapState: marlinMap.mapState)
                    .fixedSize()
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("User Tracking")
            }
            .padding(.trailing, 8)
            .padding(.bottom, 30)
        }
    }
}
