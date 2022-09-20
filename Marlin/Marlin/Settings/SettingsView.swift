//
//  SettingsView.swift
//  Marlin
//
//  Created by Daniel Barela on 9/2/22.
//

import SwiftUI

struct SettingsView: View {
    //First get the nsObject by defining as an optional anyObject
    let version = Bundle.main.releaseVersionNumber ?? ""
    let buildVersion = Bundle.main.buildVersionNumber ?? ""
    @State var tapCount: Int = 1
    
    @AppStorage("showMapScale") var showMapScale = false
    @AppStorage("flyoverMapsEnabled") var flyoverMapsEnabled = false
    @AppStorage("searchEnabled") var searchEnabled = false
    
    var body: some View {
        List {
            NavigationLink {
                DisclaimerView()
            } label: {
                Image(systemName: "shield.lefthalf.filled")
                    .tint(Color.onSurfaceColor)
                    .opacity(0.60)
                Text("Disclaimer")
            }
            
            NavigationLink {
                VStack {
                    Text("Marlin v\(version)b\(buildVersion)")
                    .font(Font.headline6)
                    Spacer()
                }
                .padding([.leading, .top, .bottom, .trailing], 16)
                .navigationTitle("About Marlin v\(version)")
            } label: {
                Image(systemName: "info.circle")
                    .tint(Color.onSurfaceColor)
                    .opacity(0.60)
                Text("About")
            }
            HStack {
                Image("marlin_small")
                    .tint(Color.onSurfaceColor)
                    .opacity(0.60)
                Text("Marlin v\(version)")
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                tapCount += 1
            }
            
            if tapCount > 5 {
                Section("Developer Tools") {
                    Toggle(isOn: $searchEnabled, label: {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            Text("Search Enabled")
                        }
                    })
                    .padding([.top, .bottom], 8)
                    Toggle(isOn: $showMapScale, label: {
                        HStack {
                            Image(systemName: "ruler.fill")
                            Text("Show Map Scale (requires restart)")
                        }
                    })
                    .padding([.top, .bottom], 8)
                    Toggle(isOn: $flyoverMapsEnabled, label: {
                        HStack {
                            Image(systemName: "rotate.3d")
                            Text("Enable Flyover Map Types")
                        }
                    })
                    .padding([.top, .bottom], 8)
                }.toggleStyle(SwitchToggleStyle(tint: .primaryColorVariant))
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.grouped)
        .listRowBackground(Color.surfaceColor)
        .background(Color.backgroundColor)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
