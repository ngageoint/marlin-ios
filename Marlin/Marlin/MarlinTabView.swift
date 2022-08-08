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
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject var scheme: MarlinScheme
    
    @StateObject var dataSourceList: DataSourceList = DataSourceList()
    @State var menuOpen: Bool = false
    
    var marlinMap = MarlinMap()
        .mixin(AsamMap())
        .mixin(ModuMap())
        .mixin(LightMap())
        .mixin(BottomSheetMixin())
        .mixin(PersistedMapState())
    
    var body: some View {

        if horizontalSizeClass == .compact {
            MarlinCompactWidth(dataSourceList: dataSourceList, marlinMap: marlinMap)
        } else {
            NavigationView {
                ZStack {
            MarlinRegularWidth(dataSourceList: dataSourceList, marlinMap: marlinMap)
                    GeometryReader { geometry in
                        SideMenu(width: min(geometry.size.width - 56, 512),
                                 isOpen: self.menuOpen,
                                 menuClose: self.openMenu,
                                 dataSourceList: dataSourceList
                        )
                    }
                }
                .modifier(Hamburger(menuOpen: $menuOpen))
                .navigationTitle("Marlin")
                .navigationBarTitleDisplayMode(.inline)
            }
            .tint(Color(scheme.containerScheme.colorScheme.onPrimaryColor))
            .navigationViewStyle(.stack)
        }
    }
    
    func openMenu() {
        self.menuOpen.toggle()
    }
}
