//
//  WMSLayerEditView.swift
//  Marlin
//
//  Created by Daniel Barela on 3/6/23.
//

import Foundation
import SwiftUI

struct WMSLayerEditView: View {

    @ObservedObject var viewModel: NewMapLayerViewModel
    @ObservedObject var mapState: MapState
    @State private var topExpanded: Bool = true
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
            MarlinMap(name: "WMS Layer Map", mixins: [WMSMap(viewModel: viewModel)], mapState: mapState)
                            .frame(minHeight: 0, maxHeight: .infinity)
            NavigationLink {
                LayerConfiguration(viewModel: viewModel, mapState: mapState)
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
