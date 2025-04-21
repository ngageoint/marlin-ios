//
//  PortRouteSheetView.swift
//  Marlin
//
//  Created by Daniel Barela on 3/1/24.
//

import Foundation
import SwiftUI

struct PortRouteSheetView: View {
    var itemKey: String
    var focusNotification: NSNotification.Name
    @ObservedObject var routeViewModel: RouteViewModel
    @Binding var showBottomSheet: Bool

    @StateObject var viewModel: PortViewModel = PortViewModel()

    var body: some View {
        Group {
            switch viewModel.port {
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
            viewModel.getPort(portNumber: Int(itemKey) ?? -1)
        }
        .onChange(of: viewModel.port) {
            NotificationCenter.default.post(
                name: focusNotification,
                object: FocusMapOnItemNotification(
                    item: viewModel.port,
                    definition: DataSources.port
                )
            )
        }
        .onAppear {
            viewModel.getPort(portNumber: Int(itemKey) ?? -1)
        }
    }
}
