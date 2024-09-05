//
//  DGPSStationRouteSheetView.swift
//  Marlin
//
//  Created by Daniel Barela on 3/1/24.
//

import Foundation
import SwiftUI

struct DGPSStationRouteSheetView: View {
    @EnvironmentObject var dgpsRepository: DGPSStationRepository
    var itemKey: String
    var focusNotification: NSNotification.Name
    @ObservedObject var routeViewModel: RouteViewModel
    @Binding var showBottomSheet: Bool

    @StateObject var viewModel: DGPSStationViewModel = DGPSStationViewModel()

    var body: some View {
        Group {
            switch viewModel.dgpsStation {
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
            if split.count == 2 {
                viewModel.getDGPSStation(featureNumber: Int(split[0]) ?? -1, volumeNumber: "\(split[1])")
            }
        }
        .onChange(of: viewModel.dgpsStation) { model in
            NotificationCenter.default.post(
                name: focusNotification,
                object: FocusMapOnItemNotification(
                    item: model,
                    definition: DataSources.dgps
                )
            )
        }
        .onAppear {
            viewModel.repository = dgpsRepository
            let split = itemKey.split(separator: "--")
            if split.count == 2 {
                viewModel.getDGPSStation(featureNumber: Int(split[0]) ?? -1, volumeNumber: "\(split[1])")
            }
        }
    }
}
