//
//  TabView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/13/22.
//

import SwiftUI

struct MarlinTabView: View {
    
    @EnvironmentObject var scheme: MarlinScheme
    
    var body: some View {
        TabView {
            NavigationView {
                MarlinMap()
                    .navigationTitle("Marlin")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        ToolbarItem (placement: .navigation)  {
                            Image(systemName: "line.3.horizontal")
                                .foregroundColor(Color(scheme.containerScheme.colorScheme.onPrimaryColor))
                                .onTapGesture {
                                    self.showHamburger()
                                }
                        }
                    }
            }.tabItem {
                Label("Map", systemImage: "map.fill")
            }
            // this affects text buttons, image buttons need .foregroundColor set on them
            .tint(Color(scheme.containerScheme.colorScheme.onPrimaryColor))
            .navigationViewStyle(.stack)
            .statusBar(hidden: false)
            
            ContentView()
                .tabItem {
                    Label("ASAMs", image: "asam")
                }
        }
        .accentColor(Color(scheme.containerScheme.colorScheme.primaryColorVariant))
    }
    
    private func showHamburger() {
    }
}

struct MarlinTabView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MarlinTabView().environmentObject(MarlinScheme.init()).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
