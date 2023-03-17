//
//  WMSLayerEditView.swift
//  Marlin
//
//  Created by Daniel Barela on 3/6/23.
//

import Foundation
import SwiftUI

struct WMSLayerEditView: View {

    @ObservedObject var viewModel: MapLayerViewModel
    @ObservedObject var mapState: MapState
    @State private var topExpanded: Bool = true
    @Binding var isPresented: Bool
    var body: some View {
        VStack(spacing: 0) {
            Group {
                ScrollView {
                    if let capabilities = viewModel.capabilities {
                        layerDisclosureGroup(layers: capabilities.layers ?? [], first: true)
                            .tint(Color.primaryColor)
                    }
                }
            }
            .padding([.trailing, .leading], 8)
            .frame(minHeight: 0, maxHeight: .infinity)
            MarlinMap(name: "WMS Layer Map", mixins: [BaseOverlaysMap(viewModel: viewModel)], mapState: mapState)
                            .frame(minHeight: 0, maxHeight: .infinity)
            NavigationLink {
                LayerConfiguration(viewModel: viewModel, mapState: mapState, isPresented: $isPresented)
            } label: {
                Text("Confirm WMS Layers")
                    .tint(Color.primaryColor)
                    .padding(8)
            }
            .buttonStyle(MaterialButtonStyle(type: .contained))
            .disabled(!viewModel.layersOK)
            .padding(8)
        }
        .navigationTitle("WMS Layers")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("WMS Layers")
                    .foregroundColor(Color.onPrimaryColor)
                    .tint(Color.onPrimaryColor)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    isPresented.toggle()
                }
            }
        }
    }
    
    @ViewBuilder
    func layerDisclosureGroup(layers: [Layer], first: Bool = false, parentWebMercator: Bool = false) -> some View {
        AnyView(
            VStack(alignment: .leading) {
                ForEach(layers.sorted(by: { one, two in
                    if one.isWebMercator && two.isWebMercator {
                        return (one.title ?? "").lowercased() < (two.title ?? "").lowercased()
                    } else if !one.isWebMercator && !two.isWebMercator {
                        return (one.title ?? "").lowercased() < (two.title ?? "").lowercased()
                    } else if one.isWebMercator {
                        return true
                    }
                    return false
                })) { layer in
                    if let layers = layer.layers {
                        DisclosureGroup(isExpanded: first ? $topExpanded : Binding.constant(false)) {
                            self.layerDisclosureGroup(layers: layers, parentWebMercator: parentWebMercator || layer.isWebMercator)
                        } label: {
                            LayerRow(viewModel: viewModel, layer: layer, parentWebMercator: parentWebMercator)
                        }
                    } else {
                        LayerRow(viewModel: viewModel, layer: layer, parentWebMercator: parentWebMercator)
                    }
                }
            }
        )
    }
}

struct LayerRow: View {
    @ObservedObject var viewModel: MapLayerViewModel
    @ObservedObject var layer: Layer
    var parentWebMercator: Bool = false
    var body: some View {
        buildRow()
    }
    
    @ViewBuilder
    func buildRow() -> some View {
        if let layers = layer.layers, !layers.isEmpty {
            HStack {
                Image(systemName: "folder")
                    .tint(Color.onSurfaceColor)
                    .opacity(0.60)
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(layer.title ?? "Layer Group")")
                        .multilineTextAlignment(.leading)
                        .font(Font.body1)
                        .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                    if let abstract = layer.abstract {
                        Text(abstract)
                            .multilineTextAlignment(.leading)
                            .font(Font.caption)
                            .foregroundColor(Color.onSurfaceColor.opacity(0.6))
                    }
                }
            }
        } else if parentWebMercator || layer.isWebMercator {
            // case where there are no sub layers
            // these will be the selectable layers
            Toggle(isOn: $layer.selected, label: {
                HStack {
                    Image(systemName: "square.3.layers.3d")
                        .tint(Color.onSurfaceColor)
                        .opacity(0.60)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(layer.title ?? "Layer")")
                            .multilineTextAlignment(.leading)
                            .font(Font.body1)
                            .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                        if let abstract = layer.abstract {
                            Text(abstract)
                                .multilineTextAlignment(.leading)
                                .font(Font.caption)
                                .foregroundColor(Color.onSurfaceColor.opacity(0.6))
                        }
                    }
                    .padding([.top, .bottom], 4)
                }
            })
            .onChange(of: layer.selected, perform: { newValue in
                viewModel.updateTemplate()
            })
            .toggleStyle(iOSCheckboxToggleStyle())
            .contentShape(Rectangle())
            .onTapGesture {
                layer.selected.toggle()
            }
            .tint(Color.primaryColor)
            .accessibilityElement()
            .accessibilityLabel("Layer \(layer.title ?? "") Toggle")
        } else {
            HStack {
                Image(systemName: "nosign")
                    .tint(Color.disabledColor)
                    .opacity(0.60)
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(layer.title ?? "Layer")")
                        .multilineTextAlignment(.leading)
                        .font(Font.body1)
                        .foregroundColor(Color.disabledColor.opacity(0.87))
                    Text("Layer is not availabe in web mercator")
                        .font(Font.caption)
                        .foregroundColor(Color.disabledColor.opacity(0.87))
                }
                .padding([.top, .bottom], 4)
            }
        }
    }
}
