//
//  GeoPackageLayerEditView.swift
//  Marlin
//
//  Created by Daniel Barela on 3/31/23.
//

import SwiftUI
import MapKit

// struct GeoPackageLayerMapView: View {
//    @ObservedObject var viewModel: MapLayerViewModel
// }

struct GeoPackageLayerEditView: View {
    @ObservedObject var viewModel: MapLayerViewModel
    @StateObject var mixins: MapMixins = MapMixins()
    @StateObject var mapState = MapState()

    @Binding var isPresented: Bool
    
    var marlinMap: MarlinMap {
        MarlinMap(name: "GeoPackage Layer Map", mixins: mixins, mapState: mapState)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                ForEach(viewModel.tileLayers, id: \.self) { tileLayer in
                    GeoPackageTileLayerRow(viewModel: viewModel, layer: tileLayer, mapState: mapState)
                }
                ForEach(viewModel.featureLayers, id: \.self) { featureLayer in
                    GeoPackageFeatureLayerRow(viewModel: viewModel, layer: featureLayer, mapState: mapState)
                }
            }
            .tint(Color.primaryColor)
            .padding([.trailing, .leading], 8)
            .frame(minHeight: 0, maxHeight: .infinity)
            marlinMap
                .onAppear {
                    mixins.mixins.append(BaseOverlaysMap(viewModel: viewModel))
                }
                .frame(minHeight: 0, maxHeight: .infinity)
            NavigationLink {
                LayerConfiguration(viewModel: viewModel, isPresented: $isPresented)
            } label: {
                Text("Confirm GeoPackage Layers")
                    .tint(Color.primaryColor)
                    .padding(8)
            }
            .buttonStyle(MaterialButtonStyle(type: .contained))
            .disabled(!viewModel.layersOK)
            .padding(8)
        }
        .navigationTitle("GeoPackage Layers")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("GeoPackage Layers")
                    .foregroundColor(Color.onPrimaryColor)
                    .tint(Color.onPrimaryColor)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    viewModel.cancel()
                    isPresented.toggle()
                }
            }
        }
        .onAppear {
            mixins.mixins.append(BaseOverlaysMap(viewModel: viewModel))
            if viewModel.mapLayer != nil {
                Metrics.shared.appRoute(["mapEditGPLayerSettings"])
            } else {
                Metrics.shared.appRoute(["mapCreateGPLayerSettings"])
            }
        }
    }
}

struct GeoPackageTileLayerRow: View {
    @ObservedObject var viewModel: MapLayerViewModel
    @ObservedObject var layer: TileLayerInfo
    @ObservedObject var mapState: MapState
    
    var body: some View {
        Toggle(isOn: $layer.selected, label: {
            HStack {
                Image(systemName: "square.3.layers.3d")
                    .tint(Color.onSurfaceColor)
                    .opacity(0.60)
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(layer.name ?? "")")
                        .multilineTextAlignment(.leading)
                        .font(Font.body1)
                        .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                    Text("Zoom \(layer.minZoom) - \(layer.maxZoom)")
                        .multilineTextAlignment(.leading)
                        .font(Font.caption)
                        .foregroundColor(Color.onSurfaceColor.opacity(0.6))
                    Text(layer.boundingBoxDisplay)
                        .multilineTextAlignment(.leading)
                        .font(Font.caption)
                        .foregroundColor(Color.onSurfaceColor.opacity(0.6))
                }
                .padding([.top, .bottom], 4)
                Spacer()
                Button(
                    action: {
                        if let maxLatitude = layer.boundingBox?.maxLatitude,
                            let minLatitude = layer.boundingBox?.minLatitude,
                            let maxLongitude = layer.boundingBox?.maxLongitude,
                            let minLongitude = layer.boundingBox?.minLongitude {
                            let latSpan = maxLatitude - minLatitude
                            let lonSpan = maxLongitude - minLongitude
                            let center: CLLocationCoordinate2D = CLLocationCoordinate2D(
                                latitude: maxLatitude - (latSpan / 2.0),
                                longitude: maxLongitude - (lonSpan / 2.0))
                            let span: MKCoordinateSpan = MKCoordinateSpan(
                                latitudeDelta: latSpan,
                                longitudeDelta: lonSpan
                            )
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
        })
        .toggleStyle(ListCheckboxToggleStyle())
        .contentShape(Rectangle())
        .onTapGesture {
            layer.selected.toggle()
        }
        .tint(Color.primaryColor)
        .accessibilityElement()
        .accessibilityLabel("Tile Layer \(layer.name ?? "") Toggle")
        .onChange(of: layer.selected, perform: { _ in
            viewModel.updateSelectedLayers(layer: layer)
        })
    }
}

struct GeoPackageFeatureLayerRow: View {
    @ObservedObject var viewModel: MapLayerViewModel
    @ObservedObject var layer: FeatureLayerInfo
    @ObservedObject var mapState: MapState
    
    var body: some View {
        Toggle(isOn: $layer.selected, label: {
            HStack {
                Image(systemName: "square.3.layers.3d")
                    .tint(Color.onSurfaceColor)
                    .opacity(0.60)
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(layer.name ?? "")")
                        .multilineTextAlignment(.leading)
                        .font(Font.body1)
                        .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                    Text("Feature Count: \(layer.count)")
                        .multilineTextAlignment(.leading)
                        .font(Font.caption)
                        .foregroundColor(Color.onSurfaceColor.opacity(0.6))
                    Text("Bounding Box: \(layer.boundingBoxDisplay)")
                        .multilineTextAlignment(.leading)
                        .font(Font.caption)
                        .foregroundColor(Color.onSurfaceColor.opacity(0.6))
                }
                .padding([.top, .bottom], 4)
                Spacer()
                Button(
                    action: {
                        if let maxLatitude = layer.boundingBox?.maxLatitude,
                            let minLatitude = layer.boundingBox?.minLatitude,
                            let maxLongitude = layer.boundingBox?.maxLongitude,
                            let minLongitude = layer.boundingBox?.minLongitude {
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
        })
        .toggleStyle(ListCheckboxToggleStyle())
        .contentShape(Rectangle())
        .onTapGesture {
            layer.selected.toggle()
        }
        .tint(Color.primaryColor)
        .accessibilityElement()
        .accessibilityLabel("Feature Layer \(layer.name ?? "") Toggle")
        .onChange(of: layer.selected, perform: { _ in
            viewModel.updateSelectedLayers(layer: layer)
        })
    }
}
