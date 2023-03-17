//
//  MapLayersView.swift
//  Marlin
//
//  Created by Daniel Barela on 2/27/23.
//

import Foundation
import SwiftUI

struct MapLayerRow: View {
    @ObservedObject var layer: MapLayer
    @Binding var isVisible: Bool
    
    var body: some View {
        Toggle(isOn: $isVisible) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(layer.displayName ?? layer.name ?? "Layer").font(Font.body1)
                        .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                    Text("\(layer.host ?? layer.filePath ?? "")")
                        .font(Font.caption)
                        .foregroundColor(Color.onSurfaceColor.opacity(0.6))
                }
                .padding(.top, 4)
                .padding(.bottom, 4)
            }
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
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var model: MapLayersViewModel = MapLayersViewModel()
    @State var isMapLayersPresented: Bool = false
    
    var body: some View {
        List {
            Section("") {
                HStack {
                    Image(systemName: "plus.square")
                        .tint(Color.onSurfaceColor)
                        .opacity(0.60)
                    Text("Add a new layer")
                        .font(Font.body1)
                        .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    isMapLayersPresented.toggle()
                }
                .fullScreenCover(isPresented: $isMapLayersPresented) {
                    NavigationView {
                        MapLayerView(isPresented: $isMapLayersPresented)
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Add a new layer")
            }
            Section("Additional Layers - Drag to reorder on the map") {
                ForEach(model.layers, id: \.self) { layer in
                    MapLayerRow(layer: layer, isVisible: model.toggleVisibility(of: layer))
                }
                .onMove { from, to in
                    model.reorderLayers(fromOffsets: from, toOffset: to)
                }
                .onDelete { offsets in
                    model.deleteLayers(offsets: offsets)
                }
            }
        }
        .navigationTitle("Map Layers")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.grouped)
        .onAppear {
            Metrics.shared.mapLayersView()
        }
    }
    
}
