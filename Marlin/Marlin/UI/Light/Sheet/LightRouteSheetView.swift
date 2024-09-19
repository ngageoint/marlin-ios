//
//  LightRouteSheetView.swift
//  Marlin
//
//  Created by Daniel Barela on 3/1/24.
//

import Foundation
import SwiftUI

struct LightRouteSheetView: View {
    var itemKey: String
    var focusNotification: NSNotification.Name
    @ObservedObject var routeViewModel: RouteViewModel
    @Binding var showBottomSheet: Bool

    @StateObject var viewModel: LightViewModel = LightViewModel()

    var body: some View {
        Group {
            switch viewModel.lights.first {
            case .some(let model):
                VStack {
                    Text(model.itemTitle)
                    HStack {
                        Button("Add To Route") {
                            routeViewModel.addWaypoint(waypoint: model)
                            showBottomSheet.toggle()
                        }
                        .buttonStyle(MaterialButtonStyle(type: .text))
                    }
                }
            case nil:
                Text("Loading...")
            }
        }
        .onChange(of: itemKey) { newItemKey in
            let split = newItemKey.split(separator: "--")
            if split.count == 3 {
                Task {
                    await viewModel.getLights(featureNumber: "\(split[0])", volumeNumber: "\(split[1])")
                }
            }
        }
        .onChange(of: viewModel.lights) { model in
            NotificationCenter.default.post(
                name: focusNotification,
                object: FocusMapOnItemNotification(
                    item: model.first,
                    definition: DataSources.light
                )
            )
        }
        .task {
            let split = itemKey.split(separator: "--")
            if split.count == 3 {
                await viewModel.getLights(featureNumber: "\(split[0])", volumeNumber: "\(split[1])")
            }
        }
    }
}
