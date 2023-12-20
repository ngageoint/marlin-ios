//
//  WMSLayerEditView.swift
//  Marlin
//
//  Created by Daniel Barela on 3/6/23.
//

import Foundation
import SwiftUI
import MapKit

struct WMSLayerEditView: View {

    @ObservedObject var viewModel: MapLayerViewModel
    @StateObject var mixins: MapMixins = MapMixins()
    @StateObject var mapState: MapState = MapState()

    @State private var topExpanded: Bool = true
    @Binding var isPresented: Bool
    
    var marlinMap: MarlinMap {
        MarlinMap(name: "WMS Layer Map", mixins: mixins, mapState: mapState)
    }
    
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
            marlinMap
                            .frame(minHeight: 0, maxHeight: .infinity)
            NavigationLink {
                LayerConfiguration(viewModel: viewModel, isPresented: $isPresented)
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
        .onAppear {
            mixins.mixins.append(BaseOverlaysMap(viewModel: viewModel))

            if viewModel.mapLayer != nil {
                Metrics.shared.appRoute(["mapWMSEditLayerSettings"])
            } else {
                Metrics.shared.appRoute(["mapWMSCreateLayerSettings"])
            }
        }
    }
    
    @ViewBuilder
    func layerDisclosureGroup(layers: [WMSLayer], first: Bool = false, parentWebMercator: Bool = false) -> some View {
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
                        if first {
                            DisclosureGroup(isExpanded: $topExpanded) {
                                self.layerDisclosureGroup(
                                    layers: layers,
                                    parentWebMercator: parentWebMercator || layer.isWebMercator)
                            } label: {
                                LayerRow(
                                    viewModel: viewModel,
                                    layer: layer,
                                    mapState: mapState,
                                    parentWebMercator: parentWebMercator)
                            }
                        } else {
                            DisclosureGroup {
                                self.layerDisclosureGroup(
                                    layers: layers,
                                    parentWebMercator: parentWebMercator || layer.isWebMercator)
                            } label: {
                                LayerRow(
                                    viewModel: viewModel,
                                    layer: layer,
                                    mapState: marlinMap.mapState,
                                    parentWebMercator: parentWebMercator)
                            }
                        }
                    } else {
                        LayerRow(
                            viewModel: viewModel,
                            layer: layer,
                            mapState: mapState,
                            parentWebMercator: parentWebMercator)
                    }
                }
            }
        )
    }
}

struct LayerRow: View {
    @ObservedObject var viewModel: MapLayerViewModel
    @ObservedObject var layer: WMSLayer
    @ObservedObject var mapState: MapState
    @State var abstractLineLimit: Int? = 3
    
    var parentWebMercator: Bool = false
    var body: some View {
        buildRow()
    }

    @ViewBuilder
    func buildFolder(layers: [WMSLayer]) -> some View {
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
                        .lineLimit(abstractLineLimit)
                        .multilineTextAlignment(.leading)
                        .font(Font.caption)
                        .foregroundColor(Color.onSurfaceColor.opacity(0.6))
                        .onTapGesture {
                            if abstractLineLimit == 3 {
                                abstractLineLimit = nil
                            } else {
                                abstractLineLimit = 3
                            }
                        }
                }
            }
        }
    }

    @ViewBuilder
    func buildNonWebMercatorRow() -> some View {
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

    @ViewBuilder
    func centerButton() -> some View {
        Button(
            action: {
                if let boundingBox = layer.boundingBox,
                   let minLatitude = boundingBox.minLatitude,
                   let maxLatitude = boundingBox.maxLatitude,
                   let minLongitude = boundingBox.minLongitude,
                   let maxLongitude = boundingBox.maxLongitude {
                    let latSpan = maxLatitude - minLatitude
                    let lonSpan = maxLongitude - minLongitude
                    let center: CLLocationCoordinate2D = CLLocationCoordinate2D(
                        latitude: maxLatitude - (latSpan / 2.0),
                        longitude: maxLongitude - (lonSpan / 2.0))
                    let span: MKCoordinateSpan = MKCoordinateSpan(
                        latitudeDelta: latSpan,
                        longitudeDelta: lonSpan)
                    mapState.forceCenter = MKCoordinateRegion(center: center, span: span)
                }
            },
            label: {
                Label(
                    title: {},
                    icon: { Image(systemName: "scope")
                            .renderingMode(.template)
                            .foregroundColor(Color.primaryColorVariant)
                    })
            }
        )
        .padding([.trailing, .leading], 16)
        .accessibilityElement()
        .accessibilityLabel("focus")
    }

    @ViewBuilder
    func buildWebMercatorRow() -> some View {
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
                            .lineLimit(abstractLineLimit)
                            .multilineTextAlignment(.leading)
                            .font(Font.caption)
                            .foregroundColor(Color.onSurfaceColor.opacity(0.6))
                            .onTapGesture {
                                if abstractLineLimit == 3 {
                                    abstractLineLimit = nil
                                } else {
                                    abstractLineLimit = 3
                                }
                            }
                    }
                    if layer.boundingBox != nil {
                        Text(layer.boundingBoxDisplay)
                            .multilineTextAlignment(.leading)
                            .font(Font.caption)
                            .foregroundColor(Color.onSurfaceColor.opacity(0.6))
                    }
                }
                .padding([.top, .bottom], 4)
                Spacer()
                centerButton()
            }
        })
        .onChange(of: layer.selected, perform: { _ in
            viewModel.updateSelectedLayers(layer: layer)
        })
        .toggleStyle(ListCheckboxToggleStyle())
        .contentShape(Rectangle())
        .onTapGesture {
            layer.selected.toggle()
        }
        .tint(Color.primaryColor)
        .accessibilityElement()
        .accessibilityLabel("Layer \(layer.title ?? "") Toggle")
    }

    @ViewBuilder
    func buildRow() -> some View {
        if let layers = layer.layers, !layers.isEmpty {
            buildFolder(layers: layers)
        } else if parentWebMercator || layer.isWebMercator {
            // case where there are no sub layers
            // these will be the selectable layers
            buildWebMercatorRow()
        } else {
            buildNonWebMercatorRow()
        }
    }
}
