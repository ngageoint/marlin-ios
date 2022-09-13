//
//  DisplaySettings.swift
//  Marlin
//
//  Created by Daniel Barela on 9/13/22.
//

import SwiftUI

struct DisplaySettings: View {
    @AppStorage("actualRangeLights") var actualRangeLights = false
    @AppStorage("actualRangeSectorLights") var actualRangeSectorLights = false
    
    var body: some View {
        List {
            Section("Lights") {
                Toggle(isOn: $actualRangeSectorLights, label: {
                    HStack {
                        Image(systemName: "rays")
                            .tint(Color.onSurfaceColor)
                            .opacity(0.60)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Show Light Sector Ranges")
                                .font(Font.body1)
                                .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                            Text("Display the range of light sectors on the map")
                                .font(Font.caption)
                                .foregroundColor(Color.onSurfaceColor.opacity(0.6))
                        }
                        .padding([.top, .bottom], 4)
                    }
                })
                .tint(Color.primaryColor)
                
                Toggle(isOn: $actualRangeLights, label: {
                    HStack {
                        Image(systemName: "smallcircle.filled.circle.fill")
                            .tint(Color.onSurfaceColor)
                            .opacity(0.60)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Show Light Ranges")
                                .font(Font.body1)
                                .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                            Text("Display the range of lights on the map")
                                .font(Font.caption)
                                .foregroundColor(Color.onSurfaceColor.opacity(0.6))
                        }
                        .padding([.top, .bottom], 4)
                    }
                })
                .tint(Color.primaryColor)
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
