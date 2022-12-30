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
    
    @AppStorage("showMapScale") var showMapScale = false
    @AppStorage("flyoverMapsEnabled") var flyoverMapsEnabled = false

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
                    Toggle(isOn: $showMapScale, label: {
                        HStack {
                            Image(systemName: "ruler.fill")
                            Text("Show Map Scale (requires restart)")
                                .primary()
                        }
                    })
                    .padding([.top, .bottom], 8)
                    
                    Toggle(isOn: $flyoverMapsEnabled, label: {
                        HStack {
                            Image(systemName: "rotate.3d")
                            Text("Enable Flyover Map Types")
                                .primary()
                        }
                    })
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
            Metrics.shared.settingsView()
        }
    }
}
