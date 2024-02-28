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
    @AppStorage("showMapScale") var showMapScale = false
    @AppStorage("coordinateDisplay") var coordinateDisplay: CoordinateDisplayType = .latitudeLongitude
    @AppStorage("searchType") var searchType: SearchType = .native

    var body: some View {
        Self._printChanges()
        return List {
            Section("Map Base Layer") {
                HStack(spacing: 4) {
                    Text("Standard").font(Font.body1)
                        .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                    Spacer()
                    Image(systemName: mapType == MKMapType.standard.rawValue ? "circle.inset.filled": "circle")
                        .foregroundColor(Color.primaryColorVariant)
                        .onTapGesture {
                            mapType = Int(MKMapType.standard.rawValue)
                        }
                        .accessibilityElement()
                        .accessibilityLabel("Standard Map")
                }
                .padding(.top, 4)
                .padding(.bottom, 4)
                HStack(spacing: 4) {
                    Text("Satellite").font(Font.body1)
                        .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                    Spacer()
                    Image(systemName: mapType == MKMapType.satellite.rawValue ? "circle.inset.filled": "circle")
                        .foregroundColor(Color.primaryColorVariant)
                        .onTapGesture {
                            mapType = Int(MKMapType.satellite.rawValue)
                        }
                        .accessibilityElement()
                        .accessibilityLabel("Satellite Map")
                }
                .padding(.top, 4)
                .padding(.bottom, 4)
                HStack(spacing: 4) {
                    Text("Hybrid").font(Font.body1)
                        .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                    Spacer()
                    Image(systemName: mapType == MKMapType.hybrid.rawValue ? "circle.inset.filled": "circle")
                        .foregroundColor(Color.primaryColorVariant)
                        .onTapGesture {
                            mapType = Int(MKMapType.hybrid.rawValue)
                        }
                        .accessibilityElement()
                        .accessibilityLabel("Hybrid Map")
                }
                .padding(.top, 4)
                .padding(.bottom, 4)
                if flyoverMapsEnabled {
                    HStack(spacing: 4) {
                        Text("Satellite 3D").font(Font.body1)
                            .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                        Spacer()
                        Image(
                            systemName: mapType
                            == MKMapType.satelliteFlyover.rawValue ? "circle.inset.filled": "circle"
                        )
                        .foregroundColor(Color.primaryColorVariant)
                        .onTapGesture {
                            mapType = Int(MKMapType.satelliteFlyover.rawValue)
                        }
                        .accessibilityElement()
                        .accessibilityLabel("Satellite Flyover Map")
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 4)
                    HStack(spacing: 4) {
                        Text("Hybrid 3D").font(Font.body1)
                            .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                        Spacer()
                        Image(
                            systemName: mapType == MKMapType.hybridFlyover.rawValue ? "circle.inset.filled": "circle"
                        )
                        .foregroundColor(Color.primaryColorVariant)
                        .onTapGesture {
                            mapType = Int(MKMapType.hybridFlyover.rawValue)
                        }
                        .accessibilityElement()
                        .accessibilityLabel("Hybrid Flyover Map")
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 4)
                }
                HStack(spacing: 4) {
                    Text("Muted").font(Font.body1)
                        .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                    Spacer()
                    Image(systemName: mapType == MKMapType.mutedStandard.rawValue ? "circle.inset.filled": "circle")
                            .foregroundColor(Color.primaryColorVariant)
                        .onTapGesture {
                            mapType = Int(MKMapType.mutedStandard.rawValue)
                        }
                        .accessibilityElement()
                        .accessibilityLabel("Muted Map")
                }
                .padding(.top, 4)
                .padding(.bottom, 4)
                HStack(spacing: 4) {
                    Text("Open Street Map").font(Font.body1)
                                .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                    Spacer()
                    Image(systemName: mapType == ExtraMapTypes.osm.rawValue ? "circle.inset.filled": "circle")
                                .foregroundColor(Color.primaryColorVariant)
                        .onTapGesture {
                            mapType = ExtraMapTypes.osm.rawValue
                        }
                        .accessibilityElement()
                        .accessibilityLabel("Open Street Map")
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
                .contentShape(Rectangle())
                .onTapGesture {
                    showMGRS.toggle()
                }
                .tint(Color.primaryColorVariant)
                .accessibilityElement()
                .accessibilityLabel("Toggle MGRS Grid")

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
                .contentShape(Rectangle())
                .onTapGesture {
                    showGARS.toggle()
                }
                .tint(Color.primaryColorVariant)
                .accessibilityElement()
                .accessibilityLabel("Toggle GARS Grid")

            }

            Section("Layers") {
                NavigationLink(value: MarlinRoute.mapLayers) {
                    Image(systemName: "square.3.layers.3d")
                        .tint(Color.onSurfaceColor)
                        .opacity(0.60)
                    Text("Additional Map Layers")
                        .font(Font.body1)
                        .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Additional Map Layers")

            }

            Section("Data Source Settings") {
                NavigationLink(value: MarlinRoute.lightSettings) {
                    if let lightSystemImageName = Light.systemImageName {
                        Image(systemName: lightSystemImageName)
                            .tint(Color.onSurfaceColor)
                            .opacity(0.60)
                    }
                    Text("Light Settings")
                        .font(Font.body1)
                        .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Light Settings")
            }
            
            Section {
                HStack(spacing: 4) {
                    Text("Apple Maps").font(Font.body1)
                        .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                    Spacer()
                    Image(systemName: searchType == .native ? "circle.inset.filled": "circle")
                        .foregroundColor(Color.primaryColor)
                        .onTapGesture {
                            searchType = .native
                        }
                        .accessibilityElement()
                        .accessibilityLabel("Apple Maps Search")
                }
                .padding(.top, 4)
                .padding(.bottom, 4)
                HStack(spacing: 4) {
                    Text("Nominatim").font(Font.body1)
                        .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                    Spacer()
                    Image(systemName: searchType == .nominatim ? "circle.inset.filled": "circle")
                        .foregroundColor(Color.primaryColor)
                        .onTapGesture {
                            searchType = .nominatim
                        }
                        .accessibilityElement()
                        .accessibilityLabel("Nominatim Search")
                }
                .padding(.top, 4)
                .padding(.bottom, 4)
            } header: {
                Text("Location Search")
            } footer: {
                Text("Nominatim data is provided by [OpenStreetMap](https://www.openstreetmap.org/copyright).")
                    .tint(Color.blue)
            }
            
            Section("Display") {
                Toggle(isOn: $showCurrentLocation) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Show Current Location").font(Font.body1)
                            .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                        Text("Display your current position on the map")
                            .font(Font.caption)
                            .foregroundColor(Color.onSurfaceColor.opacity(0.6))
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 4)
                }
                .tint(Color.primaryColorVariant)
                Toggle(isOn: $showMapScale, label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Show Map Scale").font(Font.body1)
                            .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                        Text("Show a scale bar indicating the current map scale")
                            .font(Font.caption)
                            .foregroundColor(Color.onSurfaceColor.opacity(0.6))
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 4)
                })
                .tint(Color.primaryColorVariant)
                .padding([.top, .bottom], 8)
                
                NavigationLink(value: MarlinRoute.coordinateDisplaySettings) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Coordinate Display Settings").font(Font.body1)
                            .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                        Text(coordinateDisplay.description)
                            .font(Font.caption)
                            .foregroundColor(Color.onSurfaceColor.opacity(0.6))
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 4)
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Coordinate Display Settings")
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
