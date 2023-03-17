//
//  LayerURLView.swift
//  Marlin
//
//  Created by Daniel Barela on 3/17/23.
//

import Foundation
import SwiftUI
import Combine

struct LayerURLView: View {
    @ObservedObject var viewModel: MapLayerViewModel
    @ObservedObject var mapState: MapState
    @FocusState var isInputActive: Bool
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            List {
                Section {
                    VStack(alignment: .leading) {
                        Text("Layer URL")
                            .overline()
                        TextField("Layer URL", text: $viewModel.url)
                            .keyboardType(.URL)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .underlineTextFieldWithLabel()
                            .focused($isInputActive)
                            .accessibilityElement()
                            .accessibilityLabel("Layer URL input")
                    }
                    .frame(maxWidth:.infinity)
                } header: {
                    EmptyView().frame(width: 0, height: 0, alignment: .leading)
                }
                
                if viewModel.retrievingWMSCapabilities {
                    HStack(alignment: .center) {
                        ProgressView()
                            .tint(Color.primaryColorVariant)
                        Text("Attempting to retrieve WMS Capabilities document...")
                            .primary()
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.backgroundColor)
                } else if viewModel.retrievingXYZTile {
                    HStack(alignment: .center) {
                        ProgressView()
                            .tint(Color.primaryColorVariant)
                        Text("Attempting to retrieve 0/0/0 tile...")
                            .primary()
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.backgroundColor)
                } else if viewModel.triedCapabilities && viewModel.triedXYZTile && viewModel.layerType == .unknown {
                    Section("Tile Server Information") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Unable to retrieve capabilities document or the 0/0/0 tile.  Please choose the correct type of tile server below.")
                                .primary()
                            Text("-or-")
                                .overline()
                            Button("Try again") {
                                viewModel.retrieveWMSCapabilitiesDocument()
                            }
                            .buttonStyle(MaterialButtonStyle())
                        }
                    }
                }
                
                HStack(alignment: .center) {
                    Spacer()
                    
                    Image(systemName: viewModel.layerType == .xyz ? "circle.inset.filled": "circle")
                        .foregroundColor(Color.primaryColor)
                        .onTapGesture {
                            viewModel.layerType = .xyz
                        }
                        .accessibilityElement()
                        .accessibilityLabel("XYZ")
                    Text("XYZ")
                        .overline()
                    Image(systemName: viewModel.layerType == .wms ? "circle.inset.filled": "circle")
                        .foregroundColor(Color.primaryColor)
                        .onTapGesture {
                            viewModel.layerType = .wms
                        }
                        .accessibilityElement()
                        .accessibilityLabel("WMS")
                    Text("WMS")
                        .overline()
                    Image(systemName: viewModel.layerType == .tms ? "circle.inset.filled": "circle")
                        .foregroundColor(Color.primaryColor)
                        .onTapGesture {
                            viewModel.layerType = .tms
                        }
                        .accessibilityElement()
                        .accessibilityLabel("TMS")
                    Text("TMS")
                        .overline()
                    Spacer()
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.backgroundColor)
                
                if viewModel.layerType == .wms {
                    if let capabilities = viewModel.capabilities {
                        Section("WMS Server Information") {
                            DisclosureGroup {
                                VStack(alignment: .leading, spacing: 8) {
                                    Property(property: "Layer Count", value: "\(capabilities.totalLayers)")
                                    Property(property: "WMS Version", value: capabilities.version)
                                    Property(property: "Contact Person", value: capabilities.contactPerson)
                                    Property(property: "Contact Organization", value: capabilities.contactOrganization)
                                    if let phone = capabilities.contactTelephone {
                                        Property(property: "Contact Telephone", valueView: AnyView(
                                            Link(phone, destination: URL(string: "tel:\(phone)")!)
                                                .font(Font.subheadline)
                                                .foregroundColor(Color.primaryColor)
                                        ))
                                    }
                                    if let email = capabilities.contactEmail {
                                        Property(property: "Contact Email", valueView: AnyView(
                                            Link(email, destination: URL(string: "mailto:\(email)")!)
                                                .font(Font.subheadline)
                                                .foregroundColor(Color.primaryColor)
                                        ))
                                    }
                                }
                                
                            } label : {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(capabilities.title ?? "WMS Server Information")
                                        .primary()
                                    Text(capabilities.abstract ?? "")
                                        .secondary()
                                }
                            }
                            .tint(Color.primaryColor)
                            .frame(maxWidth: .infinity)
                            .accessibilityElement(children: .contain)
                            .accessibilityLabel("More Server Information")
                        }
                    } else {
                        Section("WMS Server Information") {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Unable to retrieve capabilities document")
                                    .primary()
                                Button("Try again") {
                                    viewModel.retrieveWMSCapabilitiesDocument()
                                }
                                .buttonStyle(MaterialButtonStyle())
                            }
                        }
                    }
                } else if viewModel.layerType == .xyz || viewModel.layerType == .tms {
                    MarlinMap(name: "XYZ Layer Map", mixins: [BaseOverlaysMap(viewModel: viewModel)], mapState: mapState)
                        .frame(minHeight: 300, maxHeight: .infinity)
                }
            }
            .dataSourceDetailList()
            .listRowBackground(Color.white)
            
            NavigationLink {
                if viewModel.layerType == .wms {
                    WMSLayerEditView(viewModel: viewModel, mapState: mapState, isPresented: $isPresented)
                } else {
                    LayerConfiguration(viewModel: viewModel, mapState: mapState, isPresented: $isPresented)
                }
            } label: {
                Text("Confirm URL")
                    .tint(Color.primaryColor)
            }
            .buttonStyle(MaterialButtonStyle(type: .contained))
            .background(Color.backgroundColor)
            .disabled(!viewModel.urlOK)
            .padding(8)
        }
        .navigationTitle("Layer URL")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Create Map Layer")
                    .foregroundColor(Color.onPrimaryColor)
                    .tint(Color.onPrimaryColor)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    isPresented.toggle()
                }
            }
            ToolbarItem(placement: .keyboard) {
                Spacer()
            }
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    isInputActive = false
                }
                .tint(Color.primaryColorVariant)
            }
        }
    }
}
