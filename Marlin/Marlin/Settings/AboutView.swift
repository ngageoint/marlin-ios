//
//  SettingsView.swift
//  Marlin
//
//  Created by Daniel Barela on 9/2/22.
//

import SwiftUI

struct AboutView: View {
    let version = Bundle.main.releaseVersionNumber ?? ""
    let buildVersion = Bundle.main.buildVersionNumber ?? ""
    @State var tapCount: Int = 1
    
    @AppStorage("flyoverMapsEnabled") var flyoverMapsEnabled = false
    @AppStorage("showUnparsedNavigationalWarnings") var showUnparsedNavigationalWarnings = false
    @AppStorage("showNavigationalWarningsOnMainMap") var showNavigationalWarningsOnMainMap = false

    var body: some View {
        List {
            NavigationLink {
                ScrollView {
                    DisclaimerView()
                }
                .navigationTitle("Disclaimer")
            } label: {
                Image(systemName: "shield.lefthalf.filled")
                    .tint(Color.onSurfaceColor)
                    .opacity(0.60)
                Text("Disclaimer")
                    .primary()
            }

            HStack {
                Image(systemName: "envelope")
                    .tint(Color.onSurfaceColor)
                    .opacity(0.60)
                Link("Contact Us", destination: URL(string: "mailto:marlin@nga.mil")!)
                    .primary()
                    .tint(Color.onSurfaceColor)
            }
            
            NavigationLink {
                AcknowledgementsView()
                .navigationTitle("Acknowledgements")
            } label: {
                Image(systemName: "hands.clap")
                    .tint(Color.onSurfaceColor)
                    .opacity(0.60)
                Text("Acknowledgements")
                    .primary()
            }

            HStack {
                Image("marlin_small")
                    .tint(Color.onSurfaceColor)
                    .opacity(0.60)
                Text("Marlin v\(version)\(tapCount > 5 ? " (\(buildVersion))" : "")")
                    .primary()
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                tapCount += 1
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Marlin")
            
            if tapCount > 5 {
                Section("Developer Tools") {
                    Toggle(isOn: $flyoverMapsEnabled, label: {
                        HStack {
                            Image(systemName: "rotate.3d")
                            Text("Enable 3D Map Types")
                                .primary()
                        }
                    })
                    .tint(Color.primaryColor)
                    .padding([.top, .bottom], 8)
                    
                    Toggle(isOn: $showUnparsedNavigationalWarnings, label: {
                        HStack {
                            Image(systemName: "mappin.slash")
                            Text("Show Navigation Warnings With No Parsed Location")
                                .primary()
                        }
                    })
                    .tint(Color.primaryColor)
                    .padding([.top, .bottom], 8)
                }
                .toggleStyle(SwitchToggleStyle(tint: .primaryColorVariant))
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.grouped)
        .listRowBackground(Color.surfaceColor)
        .background(Color.backgroundColor)
        .onAppear {
            Metrics.shared.aboutView()
        }
    }
}
