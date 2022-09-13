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
    
    var body: some View {
        List {
            NavigationLink {
                DisplaySettings()
            } label: {
                Image(systemName: "dial")
                    .tint(Color.onSurfaceColor)
                    .opacity(0.60)
                Text("Display Settings")
            }
            
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
                    Toggle(isOn: $showMapScale, label: {
                        Image(systemName: "ruler.fill")
                        Text("Show Map Scale (requires restart)")
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
