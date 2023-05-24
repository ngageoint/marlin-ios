//
//  MarlinCompactWidth.swift
//  Marlin
//
//  Created by Daniel Barela on 8/5/22.
//

import SwiftUI
import MapKit

class MarlinMainNavState: ObservableObject {
    @Published var popToRoot: Bool = false
}

struct MarlinCompactWidth: View {
    @StateObject var marlinMainNavState: MarlinMainNavState = MarlinMainNavState()
    
    @AppStorage("selectedTab") var selectedTab: String = "map"
    
    @State var menuOpen: Bool = false
    @State var selection: String? = nil
    
    @EnvironmentObject var dataSourceList: DataSourceList
    
    @Binding var filterOpen: Bool
    
    let mapFocus = NotificationCenter.default.publisher(for: .TabRequestFocus)
    let switchTabPub = NotificationCenter.default.publisher(for: .SwitchTabs).map { notification in
        notification.object
    }
    
    var body: some View {
        Self._printChanges()
        return ZStack {
            TabView(selection: $selectedTab) {
                MapNavigationView(filterOpen: $filterOpen, selection: $selection, menuOpen: $menuOpen)
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
                        DataSourceListView(dataSource: dataSource)
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
            .onReceive(self.marlinMainNavState.$popToRoot) { popToRoot in
                if popToRoot {
                    self.marlinMainNavState.popToRoot = false
                }
            }
            .onReceive(mapFocus) { output in
                selectedTab = output.object as? String ?? "map"
                selection = nil
                self.marlinMainNavState.popToRoot = true
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
                         menuClose: self.openMenu
                )
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Side Menu \(self.menuOpen ? "Open" : "Closed")")
            }
        }
    }
    
    func openMenu() {
        self.menuOpen.toggle()
    }
}

extension MarlinCompactWidth: BottomSheetDelegate {
    func bottomSheetDidDismiss() {
        filterOpen.toggle()
    }
}
