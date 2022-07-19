//
//  SideMenu.swift
//  Marlin
//
//  Created by Daniel Barela on 7/3/22.
//

import SwiftUI

struct SideMenuContent: View {
    @EnvironmentObject var scheme: MarlinScheme
    
    var body: some View {
        VStack {
            Color(scheme.containerScheme.colorScheme.primaryColor)
                .frame(maxWidth: .infinity, maxHeight: 1)
            List {
                Section("Data Source Tabs (Drag to reorder)") {
                    DataSourceCell<Asam>()
                    DataSourceCell<Modu>()
                    DataSourceCell<Light>()
                }
                Section("Data Sources (Drag to add to tabs)") {
                    DataSourceCell<NavigationalWarning>()
                }
            }.listStyle(.grouped)
        }.background(Color(scheme.containerScheme.colorScheme.primaryColor))
    }
}

struct SideMenuContent_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuContent()
    }
}
