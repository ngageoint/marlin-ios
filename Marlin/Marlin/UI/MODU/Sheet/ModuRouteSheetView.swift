//
//  ModuRouteSheetView.swift
//  Marlin
//
//  Created by Daniel Barela on 3/1/24.
//

import Foundation
import SwiftUI

struct ModuRouteSheetView: View {
    var itemKey: String
    var focusNotification: NSNotification.Name
    @ObservedObject var routeViewModel: RouteViewModel
    @Binding var showBottomSheet: Bool

    @StateObject var viewModel: ModuViewModel = ModuViewModel()

    var body: some View {
        Group {
            switch viewModel.modu {
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
        .onChange(of: itemKey) {
            viewModel.getModu(name: itemKey)
        }
        .onChange(of: viewModel.modu) {
            NotificationCenter.default.post(
                name: focusNotification,
                object: FocusMapOnItemNotification(
                    item: viewModel.modu,
                    definition: DataSources.modu
                )
            )
        }
        .onAppear {
            viewModel.getModu(name: itemKey)
        }
    }
}
