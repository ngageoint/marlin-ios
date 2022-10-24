//
//  MapSettings.swift
//  Marlin
//
//  Created by Daniel Barela on 6/30/22.
//

import SwiftUI
import MapKit

struct MapSettings: View {
    @AppStorage("showMGRS") var showMGRS: Bool = false
    @AppStorage("showGARS") var showGARS: Bool = false
    @AppStorage("mapType") var mapType: Int = Int(MKMapType.standard.rawValue)
    @AppStorage("flyoverMapsEnabled") var flyoverMapsEnabled: Bool = false
    @AppStorage("showCurrentLocation") var showCurrentLocation: Bool = false
    var body: some View {
        List {
            Section("Map") {
                HStack(spacing: 4) {
                    Text("Standard").font(Font.body1)
                        .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                    Spacer()
                    Image(systemName: mapType == MKMapType.standard.rawValue ? "circle.inset.filled": "circle")
                        .foregroundColor(Color.primaryColor)
                        .onTapGesture {
                            mapType = Int(MKMapType.standard.rawValue)
                        }
                }
                .padding(.top, 4)
                .padding(.bottom, 4)
                HStack(spacing: 4) {
                    Text("Satellite").font(Font.body1)
                        .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                    Spacer()
                    Image(systemName: mapType == MKMapType.satellite.rawValue ? "circle.inset.filled": "circle")
                        .foregroundColor(Color.primaryColor)
                        .onTapGesture {
                            mapType = Int(MKMapType.satellite.rawValue)
                        }
                }
                .padding(.top, 4)
                .padding(.bottom, 4)
                HStack(spacing: 4) {
                    Text("Hybrid").font(Font.body1)
                        .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                    Spacer()
                    Image(systemName: mapType == MKMapType.hybrid.rawValue ? "circle.inset.filled": "circle")
                        .foregroundColor(Color.primaryColor)
                        .onTapGesture {
                            mapType = Int(MKMapType.hybrid.rawValue)
                        }
                }
                .padding(.top, 4)
                .padding(.bottom, 4)
                if flyoverMapsEnabled {
                    HStack(spacing: 4) {
                        Text("Satellite Flyover").font(Font.body1)
                            .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                        Spacer()
                        Image(systemName: mapType == MKMapType.satelliteFlyover.rawValue ? "circle.inset.filled": "circle")
                            .foregroundColor(Color.primaryColor)
                            .onTapGesture {
                                mapType = Int(MKMapType.satelliteFlyover.rawValue)
                            }
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 4)
                    HStack(spacing: 4) {
                        Text("Hybrid Flyover").font(Font.body1)
                            .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                        Spacer()
                        Image(systemName: mapType == MKMapType.hybridFlyover.rawValue ? "circle.inset.filled": "circle")
                            .foregroundColor(Color.primaryColor)
                            .onTapGesture {
                                mapType = Int(MKMapType.hybridFlyover.rawValue)
                            }
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 4)
                }
                HStack(spacing: 4) {
                    Text("Muted").font(Font.body1)
                        .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                    Spacer()
                    Image(systemName: mapType == MKMapType.mutedStandard.rawValue ? "circle.inset.filled": "circle")
                            .foregroundColor(Color.primaryColor)
                        .onTapGesture {
                            mapType = Int(MKMapType.mutedStandard.rawValue)
                        }
                }
                .padding(.top, 4)
                .padding(.bottom, 4)
                HStack(spacing: 4) {
                    Text("Open Street Map").font(Font.body1)
                                .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                    Spacer()
                    Image(systemName: mapType == ExtraMapTypes.osm.rawValue ? "circle.inset.filled": "circle")
                                .foregroundColor(Color.primaryColor)
                        .onTapGesture {
                            mapType = ExtraMapTypes.osm.rawValue
                        }
                }
                .padding(.top, 4)
                .padding(.bottom, 4)
            }
            Section("Grids") {
                Toggle(isOn: $showMGRS) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("MGRS").font(Font.body1)
                            .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                        Text("Military Grid Reference System")
                            .font(Font.caption)
                            .foregroundColor(Color.onSurfaceColor.opacity(0.6))
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 4)
                }
                .tint(Color.primaryColor)
                Toggle(isOn: $showGARS) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("GARS").font(Font.body1)
                            .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                        Text("Global Area Reference System")
                            .font(Font.caption)
                            .foregroundColor(Color.onSurfaceColor.opacity(0.6))
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 4)
                }
                .tint(Color.primaryColor)
            }
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
            
            Section("Display") {
                Toggle(isOn: $showCurrentLocation) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Show Current Location").font(Font.body1)
                            .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                        Text("Shows your curent latitude, longitude on the map")
                            .font(Font.caption)
                            .foregroundColor(Color.onSurfaceColor.opacity(0.6))
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 4)
                }
                .tint(Color.primaryColor)
            }
        }
        .navigationTitle("Map Settings")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.grouped)
        .onAppear {
            Metrics.shared.mapSettingsView()
        }
    }
}

struct MapSettings_Previews: PreviewProvider {
    static var previews: some View {
        MapSettings()
    }
}
