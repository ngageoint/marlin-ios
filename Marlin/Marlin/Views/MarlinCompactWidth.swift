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
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    
    @AppStorage("selectedTab") var selectedTab: String = "map"
    @AppStorage("initialDataLoaded") var initialDataLoaded: Bool = false
    
    @ObservedObject var dataSourceList: DataSourceList
    @State var menuOpen: Bool = false
    @State var selection: String? = nil
    @StateObject var itemWrapper: ItemWrapper = ItemWrapper()
    
    @Binding var filterOpen: Bool
    
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
                    VStack(spacing: 0) {
                        DataLoadedNotificationBanner()
                        CurrentLocation()
                        ZStack(alignment: .topLeading) {
                            marlinMap
                                .navigationTitle("Marlin")
                                .navigationBarTitleDisplayMode(.inline)
                                .navigationBarBackButtonHidden(true)
                                .if(UserDefaults.standard.hamburger) { view in
                                    view.modifier(Hamburger(menuOpen: $menuOpen))
                                }
                                .modifier(FilterButton(filterOpen: $filterOpen, dataSources: $dataSourceList.mappedDataSources))
                                .onAppear {
                                    Metrics.shared.mapView()
                                }
                                .ignoresSafeArea(edges: [.leading, .trailing])
                                .overlay(bottomButtons(), alignment: .bottom)
                                .overlay(topButtons(), alignment: .top)
                                .accessibilityElement(children: .contain)
                                .accessibilityLabel("Marlin Map")

                            loadingCapsule()
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
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel("Marlin Map Tab")
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
                                .accessibilityElement(children: .contain)
                                .accessibilityLabel("\(dataSource.key)List")
                        } else if let imageName = dataSource.dataSource.systemImageName {
                            Label(dataSource.dataSource.dataSourceName, systemImage: imageName)
                                .accessibilityElement(children: .contain)
                                .accessibilityLabel("\(dataSource.key)List")
                        } else {
                            Label(dataSource.dataSource.dataSourceName, systemImage: "list.bullet.rectangle.fill")
                                .accessibilityElement(children: .contain)
                                .accessibilityLabel("\(dataSource.key)List")
                        }
                    }
                    .tag("\(dataSource.key)List")
                }
            }
            .onReceive(viewDataSourcePub) { output in
                if let dataSource = output.object as? (any DataSource) {
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
                    } else if output == "submitReport" {
                        selectedTab = "map"
                        selection = "submitReport"
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
            GeometryReader { geometry in
                SideMenu(width: geometry.size.width - 56,
                         isOpen: self.menuOpen,
                         menuClose: self.openMenu,
                         dataSourceList: dataSourceList
                )
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Side Menu \(self.menuOpen ? "Open" : "Closed")")
            }
        }
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
                .fixedSize()
                .buttonStyle(MaterialFloatingButtonStyle(type: .secondary, size: .mini))
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Map Settings")
            }
            .padding(.trailing, 8)
            .padding(.top, 16)
        }
    }
    
    @ViewBuilder
    func bottomButtons() -> some View {
        HStack(alignment: .bottom, spacing: 0) {
            if verticalSizeClass != .compact {
                VStack(alignment: .leading, spacing: 8) {
                    dataSourceToggles()
                }
                .padding(.leading, 8)
                .padding(.bottom, 30)
            } else {
                HStack(alignment: .bottom, spacing: 8) {
                    dataSourceToggles()
                }
                .padding(.leading, 8)
                .padding(.bottom, 30)
            }
            
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
    
    @ViewBuilder
    func dataSourceToggles() -> some View {
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
    
    @ViewBuilder
    func createListView(dataSource: DataSourceItem) -> some View {
        if dataSource.key == Asam.key {
            MSIListView<Asam, EmptyView, EmptyView>()
        } else if dataSource.key == Modu.key {
            MSIListView<Modu, EmptyView, EmptyView>()
        } else if dataSource.key == Light.key {
            MSIListView<Light, EmptyView, EmptyView>()
        } else if dataSource.key == NavigationalWarning.key {
            NavigationalWarningListView()
        } else if dataSource.key == Port.key {
            MSIListView<Port, EmptyView, EmptyView>()
        } else if dataSource.key == RadioBeacon.key {
            MSIListView<RadioBeacon, EmptyView, EmptyView>()
        } else if dataSource.key == DifferentialGPSStation.key {
            MSIListView<DifferentialGPSStation, EmptyView, EmptyView>()
        } else if dataSource.key == DFRS.key {
            MSIListView<DFRS, EmptyView, EmptyView>()
        } else if dataSource.key == ElectronicPublication.key {
            ElectronicPublicationsList()
        } else if dataSource.key == NoticeToMariners.key {
            NoticeToMarinersView()
        }
    }
    
    func openMenu() {
        self.menuOpen.toggle()
    }
    
    func viewData(_ data: any DataSource) {
        NotificationCenter.default.post(name: .FocusMapOnItem, object: FocusMapOnItemNotification(item: nil))
        NotificationCenter.default.post(name:.DismissBottomSheet, object: nil)
        itemWrapper.dataSource = data
        itemWrapper.date = Date()
        selection = "detail"
    }
}

extension MarlinCompactWidth: BottomSheetDelegate {
    func bottomSheetDidDismiss() {
        filterOpen.toggle()
    }
}
