//
//  TabView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/13/22.
//

import SwiftUI

class ItemWrapper : ObservableObject {
    @Published var asam: Asam?
    @Published var modu: Modu?
    @Published var dataSource: DataSource?
}

struct MarlinTabView: View {
    @EnvironmentObject var scheme: MarlinScheme
    @EnvironmentObject var appState: AppState
    
    @StateObject var itemWrapper: ItemWrapper = ItemWrapper()
    @State var selection: String? = nil
    @State private var selectedTab = "map"
    @State var menuOpen: Bool = false
    
    @StateObject var dataSourceList: DataSourceList = DataSourceList()
    
    let viewDataSourcePub = NotificationCenter.default.publisher(for: .ViewDataSource)
    let mapFocus = NotificationCenter.default.publisher(for: .MapRequestFocus)
    let switchTabPub = NotificationCenter.default.publisher(for: .SwitchTabs).map { notification in
        notification.object
    }
    
    var marlinMap = MarlinMap()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                TabView(selection: $selectedTab) {
                    NavigationView {
                        VStack {
                            ZStack(alignment: .topLeading) {
                                marlinMap
                                    .mixin(AsamMap())
                                    .mixin(ModuMap())
                                    .mixin(LightMap())
                                    .mixin(BottomSheetMixin())
                                    .mixin(PersistedMapState())
                                    .navigationTitle("Marlin")
                                    .navigationBarTitleDisplayMode(.inline)
                                    .navigationBarBackButtonHidden(true)
                                    .toolbar {
                                        ToolbarItem (placement: .navigationBarLeading)  {
                                            Image(systemName: "line.3.horizontal")
                                                .foregroundColor(Color(scheme.containerScheme.colorScheme.onPrimaryColor))
                                                .onTapGesture {
                                                    self.openMenu()
                                                }
                                        }
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
                                                MaterialFloatingButton(imageName: .constant("square.3.stack.3d"))
                                            }
                                            .isDetailLink(false)
                                            .offset(x: -8, y: 16)
                                            .fixedSize()
                                        }
                                    }
                                    Spacer()
                                    // bottom of map
                                    HStack(alignment: .bottom, spacing: 0) {
                                        Spacer()
                                        // bottom right button stack
                                        VStack(alignment: .trailing, spacing: 16) {
                                            UserTrackingButton(mapView: marlinMap.mutatingWrapper.mapView)
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
                    .tint(Color(scheme.containerScheme.colorScheme.onPrimaryColor))
                    .navigationViewStyle(.stack)
                    .statusBar(hidden: false)
                    
                    ForEach(dataSourceList.tabs, id: \.self) { dataSource in
                        NavigationView {
                            createListView(dataSource: dataSource)
                        }
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
            AsamListView()
        } else if dataSource.key == Modu.key {
            ModuListView()
        } else if dataSource.key == Light.key {
            LightsListView()
        } else if dataSource.key == NavigationalWarning.key {
            NavigationalWarningListView()
        }
    }
    
    func openMenu() {
        self.menuOpen.toggle()
    }
    
    func viewData(_ data: DataSource) {
        NotificationCenter.default.post(name: .MapAnnotationFocused, object: MapAnnotationFocusedNotification(annotation: nil, mapView: nil))
        NotificationCenter.default.post(name:.DismissBottomSheet, object: nil)
        itemWrapper.dataSource = data
        selection = "detail"
    }
}
