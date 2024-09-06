//
//  NavigationalWarningRouteSheetView.swift
//  Marlin
//
//  Created by Daniel Barela on 3/1/24.
//

import Foundation
import SwiftUI

struct NavigationalWarningRouteSheetView: View {
    var itemKey: String
    var focusNotification: NSNotification.Name
    @ObservedObject var routeViewModel: RouteViewModel
    @Binding var showBottomSheet: Bool

    @StateObject var viewModel: NavigationalWarningViewModel = NavigationalWarningViewModel()

    var body: some View {
        Group {
            switch viewModel.navWarning {
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
                viewModel.getNavigationalWarning(
                    msgYear: Int(split[0]) ?? -1,
                    msgNumber: Int(split[1]) ?? -1,
                    navArea: "\(split[2])"
                )
            }
        }
        .onChange(of: viewModel.navWarning) { model in
            NotificationCenter.default.post(
                name: focusNotification,
                object: FocusMapOnItemNotification(
                    item: model,
                    definition: DataSources.navWarning
                )
            )
        }
        .onAppear {
            let split = itemKey.split(separator: "--")
            if split.count == 3 {
                viewModel.getNavigationalWarning(
                    msgYear: Int(split[0]) ?? -1,
                    msgNumber: Int(split[1]) ?? -1,
                    navArea: "\(split[2])"
                )
            }
        }
    }
}
