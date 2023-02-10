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
    @State var loadingData: Bool = false

    @State var activeRailItem: DataSourceItem? = nil
    
    @ObservedObject var dataSourceList: DataSourceList
        
    let viewDataSourcePub = NotificationCenter.default.publisher(for: .ViewDataSource)
    let switchTabPub = NotificationCenter.default.publisher(for: .SwitchTabs).map { notification in
        notification.object
    }
    let dataSourceLoadedPub = NotificationCenter.default.publisher(for: .DataSourceLoaded)
    let dataSourceLoadingPub = NotificationCenter.default.publisher(for: .DataSourceLoading)
    let mapFocus = NotificationCenter.default.publisher(for: .MapRequestFocus)
    
    @StateObject var itemWrapper: ItemWrapper = ItemWrapper()
    @State var selection: String? = nil
        
    var marlinMap: MarlinMap
    
    var body: some View {
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
            if let dataSource = output.object as? (any DataSource) {
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
        if dataSource.key == Asam.key {
            MSIListView<Asam, AnyView>(focusedItem: itemWrapper, watchFocusedItem: true, filterPublisher: UserDefaults.standard.publisher(for: \.asamFilter), sortPublisher: UserDefaults.standard.publisher(for: \.asamSort))
        } else if dataSource.key == Modu.key {
            MSIListView<Modu, AnyView>(focusedItem: itemWrapper, watchFocusedItem: true, filterPublisher: UserDefaults.standard.publisher(for: \.moduFilter), sortPublisher: UserDefaults.standard.publisher(for: \.moduSort))
        } else if dataSource.key == Light.key {
            MSIListView<Light, AnyView>(focusedItem: itemWrapper, watchFocusedItem: true, filterPublisher: UserDefaults.standard.publisher(for: \.lightFilter), sortPublisher: UserDefaults.standard.publisher(for: \.lightSort))
        } else if dataSource.key == NavigationalWarning.key {
            NavigationalWarningListView()
        } else if dataSource.key == Port.key {
            MSIListView<Port, AnyView>(focusedItem: itemWrapper, watchFocusedItem: true, filterPublisher: UserDefaults.standard.publisher(for: \.portFilter), sortPublisher: UserDefaults.standard.publisher(for: \.portSort))
        } else if dataSource.key == RadioBeacon.key {
            MSIListView<RadioBeacon, AnyView>(focusedItem: itemWrapper, watchFocusedItem: true, filterPublisher: UserDefaults.standard.publisher(for: \.radioBeaconFilter), sortPublisher: UserDefaults.standard.publisher(for: \.radioBeaconSort))
        } else if dataSource.key == DifferentialGPSStation.key {
            MSIListView<DifferentialGPSStation, AnyView>(focusedItem: itemWrapper, watchFocusedItem: true, filterPublisher: UserDefaults.standard.publisher(for: \.differentialGPSStationFilter), sortPublisher: UserDefaults.standard.publisher(for: \.differentialGPSStationSort))
        } else if dataSource.key == DFRS.key {
            MSIListView<DFRS, AnyView>(focusedItem: itemWrapper, watchFocusedItem: true, filterPublisher: UserDefaults.standard.publisher(for: \.dfrsFilter), sortPublisher: UserDefaults.standard.publisher(for: \.dfrsSort))
        } else if dataSource.key == ElectronicPublication.key {
            ElectronicPublicationsList()
        } else if dataSource.key == NoticeToMariners.key {
            NoticeToMarinersView()
        }
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
            }
            .padding(.trailing, 8)
            .padding(.bottom, 30)
        }
    }
}
