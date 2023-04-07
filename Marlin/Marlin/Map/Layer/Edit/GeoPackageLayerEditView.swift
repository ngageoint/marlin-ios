//
//  GeoPackageLayerEditView.swift
//  Marlin
//
//  Created by Daniel Barela on 3/31/23.
//

import SwiftUI
import MapKit

struct GeoPackageLayerEditView: View {
    @ObservedObject var viewModel: MapLayerViewModel
    @ObservedObject var mapState: MapState
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                ForEach(viewModel.tileLayers, id: \.self) { tileLayer in
                    GeoPackageTileLayerRow(viewModel: viewModel, tileLayer: tileLayer, mapState: mapState)
                }
                ForEach(viewModel.featureLayers, id: \.self) { featureLayer in
                    GeoPackageFeatureLayerRow(viewModel: viewModel, featureLayer: featureLayer, mapState: mapState)
                }
            }
            .tint(Color.primaryColor)
            .padding([.trailing, .leading], 8)
            .frame(minHeight: 0, maxHeight: .infinity)
            MarlinMap(name: "GeoPackage Layer Map", mixins: [BaseOverlaysMap(viewModel: viewModel)], mapState: mapState)
                .frame(minHeight: 0, maxHeight: .infinity)
            NavigationLink {
                LayerConfiguration(viewModel: viewModel, mapState: mapState, isPresented: $isPresented)
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
                    isPresented.toggle()
                }
            }
        }
    }
}

struct GeoPackageTileLayerRow: View {
    @ObservedObject var viewModel: MapLayerViewModel
    @ObservedObject var tileLayer: TileLayerInfo
    @ObservedObject var mapState: MapState
    
    var body: some View {
        Toggle(isOn: $tileLayer.selected, label: {
            HStack {
                Image(systemName: "square.3.layers.3d")
                    .tint(Color.onSurfaceColor)
                    .opacity(0.60)
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(tileLayer.name)")
                        .multilineTextAlignment(.leading)
                        .font(Font.body1)
                        .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                    Text("Zoom \(tileLayer.minZoom) - \(tileLayer.maxZoom)")
                        .multilineTextAlignment(.leading)
                        .font(Font.caption)
                        .foregroundColor(Color.onSurfaceColor.opacity(0.6))
                    Text(tileLayer.boundingBoxDisplay)
                        .multilineTextAlignment(.leading)
                        .font(Font.caption)
                        .foregroundColor(Color.onSurfaceColor.opacity(0.6))
                }
                .padding([.top, .bottom], 4)
                Spacer()
                Button(action: {
                    let latSpan = tileLayer.maxLatitude - tileLayer.minLatitude
                    let lonSpan = tileLayer.maxLongitude - tileLayer.minLongitude
                    let center: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: tileLayer.maxLatitude - (latSpan / 2.0), longitude: tileLayer.maxLongitude - (lonSpan / 2.0))
                    let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: latSpan, longitudeDelta: lonSpan)
                    mapState.forceCenter = MKCoordinateRegion(center: center, span: span)
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
        })
        .toggleStyle(iOSCheckboxToggleStyle())
        .contentShape(Rectangle())
        .onTapGesture {
            tileLayer.selected.toggle()
        }
        .tint(Color.primaryColor)
        .accessibilityElement()
        .accessibilityLabel("Tile Layer \(tileLayer.name) Toggle")
        .onChange(of: tileLayer.selected, perform: { newValue in
            viewModel.updateSelectedFileLayers(layer: tileLayer)
        })
    }
}

struct GeoPackageFeatureLayerRow: View {
    @ObservedObject var viewModel: MapLayerViewModel
    @ObservedObject var featureLayer: FeatureLayerInfo
    @ObservedObject var mapState: MapState
    
    var body: some View {
        Toggle(isOn: $featureLayer.selected, label: {
            HStack {
                Image(systemName: "square.3.layers.3d")
                    .tint(Color.onSurfaceColor)
                    .opacity(0.60)
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(featureLayer.name)")
                        .multilineTextAlignment(.leading)
                        .font(Font.body1)
                        .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                    Text("Feature Count: \(featureLayer.count)")
                        .multilineTextAlignment(.leading)
                        .font(Font.caption)
                        .foregroundColor(Color.onSurfaceColor.opacity(0.6))
                    Text("Bounding Box: \(featureLayer.boundingBoxDisplay)")
                        .multilineTextAlignment(.leading)
                        .font(Font.caption)
                        .foregroundColor(Color.onSurfaceColor.opacity(0.6))
                }
                .padding([.top, .bottom], 4)
                Spacer()
                Button(action: {
                    let latSpan = featureLayer.maxLatitude - featureLayer.minLatitude
                    let lonSpan = featureLayer.maxLongitude - featureLayer.minLongitude
                    let center: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: featureLayer.maxLatitude - (latSpan / 2.0), longitude: featureLayer.maxLongitude - (lonSpan / 2.0))
                    let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: latSpan, longitudeDelta: lonSpan)
                    mapState.forceCenter = MKCoordinateRegion(center: center, span: span)
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
        })
        .toggleStyle(iOSCheckboxToggleStyle())
        .contentShape(Rectangle())
        .onTapGesture {
            featureLayer.selected.toggle()
        }
        .tint(Color.primaryColor)
        .accessibilityElement()
        .accessibilityLabel("Feature Layer \(featureLayer.name) Toggle")
        .onChange(of: featureLayer.selected, perform: { newValue in
            viewModel.updateSelectedFileLayers(layer: featureLayer)
        })
    }
}
