//
//  AsamRouteSheetView.swift
//  Marlin
//
//  Created by Daniel Barela on 3/1/24.
//

import Foundation
import SwiftUI

struct AsamRouteSheetView: View {
    var itemKey: String
    var focusNotification: NSNotification.Name
    @ObservedObject var routeViewModel: RouteViewModel
    @Binding var showBottomSheet: Bool

    @StateObject var viewModel: AsamViewModel = AsamViewModel()

    var body: some View {
        Group {
            switch viewModel.asam {
            case .some(let asam):
                VStack {
                    Text(asam.itemTitle)
                    HStack {
                        Button("Add To Route") {
                            routeViewModel.addWaypoint(waypoint: asam)
                            showBottomSheet.toggle()
                        }
                        .buttonStyle(MaterialButtonStyle(type: .text))
                    }
                }
            case nil:
                Text("Loading...")
            }
        }
        .onChange(of: itemKey) { newReference in
            Task {
                await viewModel.getAsam(reference: newReference)
            }
        }
        .onChange(of: viewModel.asam) { model in
            NotificationCenter.default.post(
                name: focusNotification,
                object: FocusMapOnItemNotification(
                    item: model,
                    definition: DataSources.asam
                )
            )
        }
        .task {
            await viewModel.getAsam(reference: itemKey)
        }
    }
}
