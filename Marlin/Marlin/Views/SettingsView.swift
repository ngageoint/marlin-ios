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
    
    @AppStorage("lifeSizeLights") var lifeSizeLights = false
    
    var body: some View {
        List {
            NavigationLink {
                VStack {
                    Text("""
                     NGA makes no representations or warranties regarding the accuracy or completeness of the content of the products. 10 USC 456. You acknowledge and agree that all content is provided “as is” and may differ from actual, existing geographic information and features. Please exercise judgment in use of the content.
                    """)
                    .font(Font.body2)
                    Spacer()
                }
                .padding([.leading, .top, .bottom, .trailing], 16)
                .navigationTitle("Disclaimer")
            } label: {
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
                Text("About")
            }
            HStack {
                Text("Marlin v\(version)")
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                tapCount += 1
            }
            
            if tapCount > 5 {
                Section("Developer Tools") {
                    Toggle(isOn: $lifeSizeLights, label: {
                        Image(systemName: "lightbulb.fill")
                        Text("Lights Show Distance")
                    })
                    .padding([.top, .bottom], 8)
                    .toggleStyle(SwitchToggleStyle(tint: .primaryColorVariant))
                }
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
