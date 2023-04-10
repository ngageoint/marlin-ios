//
//  NewMapLayerView.swift
//  Marlin
//
//  Created by Daniel Barela on 2/28/23.
//

import Foundation
import SwiftUI
import Combine

struct MapLayerView: View {
    @StateObject var viewModel: MapLayerViewModel = MapLayerViewModel()
    @FocusState var isInputActive: Bool
    @StateObject var mapState: MapState = MapState()
    @Binding var isPresented: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            LayerURLView(viewModel: viewModel, mapState: mapState, isPresented: $isPresented)
        }
        .frame(maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .top)
        .background(Color.backgroundColor)
        .onChange(of: isPresented) { newValue in
            if !newValue {
                dismiss()
            }
        }
    }
}

struct listCheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }, label: {
            HStack {
                configuration.label
                Spacer()
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
            }
        })
        .buttonStyle(PlainButtonStyle())
        .foregroundColor(Color.primaryColorVariant)
    }
}

struct checkboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }, label: {
            HStack {
                configuration.label
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
            }
        })
        .buttonStyle(PlainButtonStyle())
        .foregroundColor(Color.primaryColorVariant)
    }
}
