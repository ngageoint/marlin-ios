//
//  LayerConfigurationView.swift
//  Marlin
//
//  Created by Daniel Barela on 3/17/23.
//

import Foundation
import SwiftUI
import Combine

struct LayerConfiguration: View {
    @ObservedObject var viewModel: MapLayerViewModel
    @StateObject var mixins: MapMixins = MapMixins()
    
    @FocusState var isInputActive: Bool
    @Binding var isPresented: Bool
    
    var marlinMap: MarlinMap {
        MarlinMap(name: "Layer Map", mixins: mixins)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Group {
                ScrollView {
                    Group {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Layer Name")
                                .overline()
                            TextField("Layer Name", text: $viewModel.displayName)
                                .keyboardType(.default)
                                .underlineTextFieldWithLabel()
                                .focused($isInputActive)
                                .accessibilityElement()
                                .accessibilityLabel("Layer Name input")
                        }
                    }
                    Group {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Zoom Level Constraints")
                                .overline()
                            HStack {
                                TextField("Min Zoom", value: $viewModel.minimumZoom, format: .number.grouping(.never))
                                    .keyboardType(.numberPad)
                                    .underlineTextFieldWithLabel()
                                    .focused($isInputActive)
                                    .accessibilityElement()
                                    .accessibilityLabel("Minimum Zoom input")
                                Text("to")
                                    .overline()
                                TextField("Max Zoom", value: $viewModel.maximumZoom, format: .number.grouping(.never))
                                    .keyboardType(.numberPad)
                                    .underlineTextFieldWithLabel()
                                    .focused($isInputActive)
                                    .accessibilityElement()
                                    .accessibilityLabel("Maximum Zoom input")
                            }
                        }
                    }
                    Group {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Refresh Rate")
                                .overline()
                            HStack {
                                Picker("Refresh Rate Units", selection: $viewModel.refreshRateUnits) {
                                    ForEach(RefreshRateUnit.allCases, id: \.self) { value in
                                        Text(value.name)
                                            .tag(value)
                                    }
                                }
                                .scaledToFill()
                                .labelsHidden()
                                .tint(Color.primaryColorVariant)
                                
                                if viewModel.refreshRateUnits != .none {
                                    TextField(
                                        "Refresh Rate",
                                        value: $viewModel.refreshRate,
                                        format: .number.grouping(.never)
                                    )
                                    .keyboardType(.numberPad)
                                    .underlineTextFieldWithLabel()
                                    .focused($isInputActive)
                                    .accessibilityElement()
                                    .accessibilityLabel("Refresh Rate input")
                                } else {
                                    Spacer()
                                }
                            }
                            .padding(.leading, -8)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(8)
            }
            .frame(minHeight: 0, maxHeight: .infinity)
            
            marlinMap
                .frame(minHeight: 0, maxHeight: .infinity)
            
            Button("\(viewModel.mapLayer != nil ? "Update" : "Create") Layer") {
                viewModel.create()
                isPresented.toggle()
            }
            .buttonStyle(MaterialButtonStyle(type: .contained))
            .tint(viewModel.displayName.count != 0 ? Color.primaryColorVariant : Color.disabledColor)
            .disabled(viewModel.displayName.count == 0)
            .padding(8)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Layer Configuration")
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
            if viewModel.mapLayer != nil {
                Metrics.shared.appRoute(["mapEditGridLayerSettings"])
            } else {
                Metrics.shared.appRoute(["mapCreateGridLayerSettings"])
            }
        }
    }
}
