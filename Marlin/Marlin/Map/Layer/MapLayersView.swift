//
//  MapLayersView.swift
//  Marlin
//
//  Created by Daniel Barela on 2/27/23.
//

import Foundation
import SwiftUI
import MapKit

struct MapLayerRow: View {
    @ObservedObject var layer: MapLayer
    @Binding var isVisible: Bool
    @ObservedObject var mapState: MapState
    
    var body: some View {
        Toggle(isOn: $isVisible) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(layer.displayName ?? layer.name ?? "Layer").font(Font.body1)
                        .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                    Text("\(layer.host ?? layer.name ?? "")")
                        .font(Font.caption)
                        .foregroundColor(Color.onSurfaceColor.opacity(0.6))
                    Text(layer.boundingBoxDisplay)
                        .font(Font.caption)
                        .foregroundColor(Color.onSurfaceColor.opacity(0.6))
                }
                .padding([.top, .bottom], 4)
                Spacer()
                Button(action: {
                    let latSpan = layer.maxLatitude - layer.minLatitude
                    let lonSpan = layer.maxLongitude - layer.minLongitude
                    let center: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: layer.maxLatitude - (latSpan / 2.0), longitude: layer.maxLongitude - (lonSpan / 2.0))
                    let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: latSpan, longitudeDelta: lonSpan)
                    mapState.forceCenter = MKCoordinateRegion(center: center, span: span)
                    
                    NotificationCenter.default.post(name: .MapRequestFocus, object: nil)
                }) {
                    Label(
                        title: {},
                        icon: { Image(systemName: "scope")
                                .renderingMode(.template)
                                .foregroundColor(Color.primaryColorVariant)
                        })
                }
                .padding([.trailing, .leading], 16)
                .accessibilityElement()
                .accessibilityLabel("focus")
            }
        }
        .toggleStyle(iOSCheckboxToggleStyle())
        .contentShape(Rectangle())
        .onTapGesture {
            isVisible.toggle()
        }
        .tint(Color.primaryColor)
        .accessibilityElement()
        .accessibilityLabel("\(isVisible ? "Hide" : "Show") \(layer.url ?? layer.filePath ?? "")")
    }
}

struct MapLayersView: View {
    @ObservedObject var mapState: MapState
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var model: MapLayersViewModel = MapLayersViewModel()
    @State var isMapLayersPresented: Bool = false
    
    var body: some View {
        ZStack {
            List {
                Section {
                    ForEach(model.layers, id: \.self) { layer in
                        MapLayerRow(layer: layer, isVisible: model.toggleVisibility(of: layer), mapState: mapState)
                    }
                    .onMove { from, to in
                        model.reorderLayers(fromOffsets: from, toOffset: to)
                    }
                    .onDelete { offsets in
                        model.deleteLayers(offsets: offsets)
                    }
                } header: {
                    VStack(alignment: .leading) {
                        Text("Map Layers")
                            .textCase(.uppercase)
                        Text("Reorder layers on the map with a long press and drag")
                            .textCase(nil)
                            .overline()
                        
                    }
                }
            }
            .navigationTitle("Map Layers")
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(.grouped)
        }
        .overlay(
            Button {
                isMapLayersPresented.toggle()
            } label: {
                HStack {
                    Image(systemName: "plus.square")
                    Text("Add New Layer")
                }
            }
            .buttonStyle(MaterialButtonStyle(type: .contained))
            .padding(.bottom, 16)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Add a new layer"),
            alignment: .bottom
        )
        .fullScreenCover(isPresented: $isMapLayersPresented) {
            NavigationView {
                MapLayerView(isPresented: $isMapLayersPresented)
            }
        }

        .onAppear {
            Metrics.shared.mapLayersView()
        }
    }
    
}
