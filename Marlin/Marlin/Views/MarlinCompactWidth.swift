//
//  MarlinCompactWidth.swift
//  Marlin
//
//  Created by Daniel Barela on 8/5/22.
//

import SwiftUI
import MapKit

struct MarlinCompactWidth: View {
    @StateObject var router: MarlinRouter = MarlinRouter()
    @AppStorage("selectedTab") var selectedTab: String = "map"
    
    @State var menuOpen: Bool = false
    
    @EnvironmentObject var dataSourceList: DataSourceList
    
    @Binding var filterOpen: Bool
    
    @StateObject var itemWrapper: ItemWrapper = ItemWrapper()
    
    let mapFocus = NotificationCenter.default.publisher(for: .TabRequestFocus)
    let switchTabPub = NotificationCenter.default.publisher(for: .SwitchTabs).map { notification in
        notification.object
    }
    
    var body: some View {
        Self._printChanges()
        return ZStack {
            TabView(selection: $selectedTab) {
                MapNavigationView(filterOpen: $filterOpen, menuOpen: $menuOpen)
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
                .environmentObject(router)
                
                ForEach(dataSourceList.tabs, id: \.self) { item in
                    DataSourceNavView(dataSource: item, focusedItem: itemWrapper)
                        .modifier(Hamburger(menuOpen: $menuOpen))
                        // This is deprecated, but in iOS16 this is the only way to set the back button color
                        .accentColor(Color.onPrimaryColor)
                        .tabItem {
                            if let imageName = item.dataSource.imageName {
                                Label(item.dataSource.name, image: imageName)
                                    .accessibilityElement(children: .contain)
                                    .accessibilityLabel("\(item.dataSource.key)List")
                            } else if let imageName = item.dataSource.systemImageName {
                                Label(item.dataSource.name, systemImage: imageName)
                                    .accessibilityElement(children: .contain)
                                    .accessibilityLabel("\(item.dataSource.key)List")
                            } else {
                                Label(item.dataSource.name, systemImage: "list.bullet.rectangle.fill")
                                    .accessibilityElement(children: .contain)
                                    .accessibilityLabel("\(item.dataSource.key)List")
                            }
                        }
                        .tag("\(item.dataSource.key)List")
                }
            }
            .onReceive(mapFocus) { output in
                let tab = output.object as? String ?? "map"
                selectedTab = tab
                router.path.removeLast(router.path.count)
            }
            .onReceive(switchTabPub) { output in
                if let output = output as? String {
                    if output == "settings" {
                        selectedTab = "map"
                    } else if output == "submitReport" {
                        selectedTab = "map"
                    } else if dataSourceList.tabs.contains(where: { item in
                        item.key == output
                    }) {
                        selectedTab = "\(output)List"
                    } else {
                        selectedTab = "map"
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
