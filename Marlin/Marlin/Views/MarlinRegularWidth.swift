//
//  MarlinRegularWidth.swift
//  Marlin
//
//  Created by Daniel Barela on 8/5/22.
//

import SwiftUI
import MapKit

struct MarlinRegularWidth: View {
    @AppStorage("selectedTab") var selectedTab: String = "map"
    @State var activeRailItem: DataSourceItem? = nil
    
    @ObservedObject var dataSourceList: DataSourceList
    
    let viewDataSourcePub = NotificationCenter.default.publisher(for: .ViewDataSource)
    let switchTabPub = NotificationCenter.default.publisher(for: .SwitchTabs).map { notification in
        notification.object
    }
    
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
                .navigationBarHidden(true)
            }.navigationViewStyle(.stack)
        }
        .onReceive(viewDataSourcePub) { output in
            if let dataSource = output.object as? DataSource {
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
    }
    
    func viewData(_ data: DataSource) {
        NotificationCenter.default.post(name: .MapAnnotationFocused, object: MapAnnotationFocusedNotification(annotation: nil))
        NotificationCenter.default.post(name:.DismissBottomSheet, object: nil)
        itemWrapper.dataSource = data
        itemWrapper.date = Date()
        activeRailItem = dataSourceList.allTabs.first(where: { item in
            item.dataSource == type(of: data.self)
        })
        
    }
    
    @ViewBuilder
    func createListView(dataSource: DataSourceItem) -> some View {
        if dataSource.key == Asam.key {
            AsamListView(focusedItem: itemWrapper, watchFocusedItem: true)
        } else if dataSource.key == Modu.key {
            ModuListView(focusedItem: itemWrapper, watchFocusedItem: true)
        } else if dataSource.key == Light.key {
            LightsListView(focusedItem: itemWrapper, watchFocusedItem: true)
        } else if dataSource.key == NavigationalWarning.key {
            NavigationalWarningListView()
        } else if dataSource.key == Port.key {
            PortListView(focusedItem: itemWrapper, watchFocusedItem: true)
        } else if dataSource.key == RadioBeacon.key {
            RadioBeaconListView(focusedItem: itemWrapper, watchFocusedItem: true)
        } else if dataSource.key == DifferentialGPSStation.key {
            DifferentialGPSStationListView(focusedItem: itemWrapper, watchFocusedItem: true)
        } else if dataSource.key == DFRS.key {
            DFRSListView(focusedItem: itemWrapper, watchFocusedItem: true)
        }
    }
}
