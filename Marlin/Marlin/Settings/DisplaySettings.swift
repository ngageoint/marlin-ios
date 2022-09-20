//
//  DisplaySettings.swift
//  Marlin
//
//  Created by Daniel Barela on 9/13/22.
//

import SwiftUI

struct DisplaySettings: View {
    
    var body: some View {
        List {
            Section("Data Source Settings") {
                NavigationLink {
                    LightSettingsView()
                } label: {
                    if let lightSystemImageName = Light.systemImageName {
                        Image(systemName: lightSystemImageName)
                            .tint(Color.onSurfaceColor)
                            .opacity(0.60)
                    }
                    Text("Light Settings")
                        .font(Font.body1)
                        .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                }
            }
        }
        .navigationTitle("Display Settings")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.grouped)
        .listRowBackground(Color.surfaceColor)
        .background(Color.backgroundColor)
    }
}

struct DisplaySettings_Previews: PreviewProvider {
    static var previews: some View {
        DisplaySettings()
    }
}
