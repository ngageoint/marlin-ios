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
    @StateObject var mixins: MapMixins = MapMixins()

    @FocusState var isInputActive: Bool
    @Binding var isPresented: Bool
    @State var chooseFile: Bool = false
    @State var showCredentials: Bool = false
    
    var marlinMap: MarlinMap {
        MarlinMap(name: "XYZ Layer Map", mixins: mixins)
    }

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Button("Import GeoPackage File") {
                        chooseFile = true
                    }
                    .buttonStyle(MaterialButtonStyle(type: .contained))
                }
                .frame(maxWidth: .infinity)
                .alert("Existing GeoPackage", isPresented: $viewModel.confirmFileOverwrite, actions: {
                    Button("Import As New", role: .destructive) {
                        if let geoPackageFileUrl = viewModel.fileUrl {
                            viewModel.fileChosen(url: geoPackageFileUrl, forceImport: true)
                        }
                    }
                    Button("Use Existing", role: .cancel) {
                        if let fileUrl = viewModel.fileUrl {
                            viewModel.useExistingFile(url: fileUrl)
                        }
                    }
                    Button("Cancel") {
                    }
                }, message: {
                    if let url = viewModel.fileUrl {
                        Text("An existing GeoPackage with the name \"**\(viewModel.importer.fileName(url: url))**\" has already been imported.  What would you like to do?")
                    } else {
                        Text("An existing GeoPackage with the same name has been imported.  What would you like to do?")
                    }
                })
                .background(Color.backgroundColor)
                .padding(16)

                HStack(alignment: .center) {
                    Spacer()
                    Text("-or-")
                        .overline()
                    Spacer()
                }
                .background(Color.backgroundColor)

                Text("Enter a layer URL, Marlin will do it's best to auto detect the type of your layer.  **NOTE: if tiles appear misaligned, toggle between XYZ and TMS types.**")
                    .padding(16)
                    .secondary()
                    .background(Color.backgroundColor)

                VStack(alignment: .leading, spacing: 2) {
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
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(Color.surfaceColor)
                
                HStack {
                    Button("Add Credentials") {
                        showCredentials = true
                    }
                    .buttonStyle(MaterialButtonStyle(type: .text))
                    Spacer()
                }
                .background(Color.backgroundColor)
                .padding(.leading, 16)
                    
                if showCredentials {
                    VStack(alignment: .center) {
                        Group {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Username")
                                    .overline()
                                TextField("Username", text: $viewModel.username)
                                    .textInputAutocapitalization(.never)
                                    .keyboardType(.default)
                                    .underlineTextFieldWithLabel()
                                    .focused($isInputActive)
                                    .accessibilityElement()
                                    .accessibilityLabel("Username input")
                            }
                        }
                        Group {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Password")
                                    .overline()
                                SecureField("Password", text: $viewModel.password)
                                    .textInputAutocapitalization(.never)
                                    .keyboardType(.default)
                                    .underlineTextFieldWithLabel()
                                    .focused($isInputActive)
                                    .accessibilityElement()
                                    .accessibilityLabel("Password input")
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.surfaceColor)
                }
                
                if let error = viewModel.error {
                    Text("Error: \(error)")
                        .background(Color.surfaceColor)
                        .padding(16)

                }
                
                if viewModel.retrievingWMSCapabilities {
                    HStack(alignment: .center, spacing: 16) {
                        ProgressView()
                            .tint(Color.primaryColorVariant)
                        Text("Attempting to retrieve WMS Capabilities document...")
                            .primary()
                    }
                    .background(Color.backgroundColor)
                    .padding(16)
                } else if viewModel.retrievingXYZTile {
                    HStack(alignment: .center, spacing: 16) {
                        ProgressView()
                            .tint(Color.primaryColorVariant)
                        Text("Attempting to retrieve 0/0/0 tile...")
                            .primary()
                    }
                    .background(Color.backgroundColor)
                    .padding(16)
                } else if viewModel.triedCapabilities && viewModel.triedXYZTile && viewModel.layerType == .unknown {
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
                    .padding(16)
                    .background(Color.surfaceColor)

                }
                
                if viewModel.urlOK {
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
                    .background(Color.backgroundColor)
                    .padding(16)
                }
                
                if viewModel.layerType == .wms {
                    if let capabilities = viewModel.capabilities {
                        Group {
                            Text("WMS Server Information")
                                .overline()
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
                                
                            } label: {
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
                        .background(Color.surfaceColor)
                        .padding(16)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Unable to retrieve capabilities document")
                                .primary()
                            Button("Try again") {
                                viewModel.retrieveWMSCapabilitiesDocument()
                            }
                            .buttonStyle(MaterialButtonStyle())
                        }
                        .padding(16)
                        .background(Color.surfaceColor)
                    }
                } else if viewModel.layerType == .xyz || viewModel.layerType == .tms {
                    marlinMap
                        .frame(minHeight: 300, maxHeight: .infinity)
                } else if viewModel.layerType == .geopackage {
                    Text("GeoPackage Information")
                        .overline()
                        VStack(alignment: .leading, spacing: 8) {
                            if let geoPackage = viewModel.geoPackage, let geoPackageName = geoPackage.name {
                                Property(property: "GeoPackage Name", value: "\(geoPackageName)")
                                Property(property: "Layer Count", value: "\(viewModel.fileLayers.count)")
                            }
                        }
                        .padding(16)
                        .background(Color.surfaceColor)

                }
            }
            
            NavigationLink {
                if viewModel.layerType == .wms {
                    WMSLayerEditView(viewModel: viewModel, isPresented: $isPresented)
                } else if viewModel.layerType == .geopackage {
                    GeoPackageLayerEditView(viewModel: viewModel, isPresented: $isPresented)
                } else {
                    LayerConfiguration(viewModel: viewModel, isPresented: $isPresented)
                }
            } label: {
                Text("Confirm Layer Source")
                    .tint(Color.primaryColor)
            }
            .buttonStyle(MaterialButtonStyle(type: .contained))
            .background(Color.backgroundColor)
            .disabled(!viewModel.urlOK && viewModel.geoPackage == nil)
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
                    viewModel.cancel()
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
        .onAppear {
            mixins.mixins.append(BaseOverlaysMap(viewModel: viewModel))
        }
        .sheet(isPresented: $chooseFile, content: {
            DocumentPicker(model: viewModel.documentPickerViewModel)
        })
    }
}
