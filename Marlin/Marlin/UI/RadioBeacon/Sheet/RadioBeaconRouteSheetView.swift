//
//  RadioBeaconRouteSheetView.swift
//  Marlin
//
//  Created by Daniel Barela on 3/1/24.
//

import Foundation
import SwiftUI

struct RadioBeaconRouteSheetView: View {
    @EnvironmentObject var radioBeaconRepository: RadioBeaconRepository
    var itemKey: String
    var focusNotification: NSNotification.Name
    @ObservedObject var routeViewModel: RouteViewModel
    @Binding var showBottomSheet: Bool

    @StateObject var viewModel: RadioBeaconViewModel = RadioBeaconViewModel()

    var body: some View {
        Group {
            switch viewModel.radioBeacon {
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
                viewModel.getRadioBeacon(featureNumber: Int(split[0]) ?? -1, volumeNumber: "\(split[1])")
            }
        }
        .onChange(of: viewModel.radioBeacon) { model in
            NotificationCenter.default.post(
                name: focusNotification,
                object: FocusMapOnItemNotification(
                    item: model,
                    definition: DataSources.radioBeacon
                )
            )
        }
        .onAppear {
            viewModel.repository = radioBeaconRepository
            let split = itemKey.split(separator: "--")
            if split.count == 2 {
                viewModel.getRadioBeacon(featureNumber: Int(split[0]) ?? -1, volumeNumber: "\(split[1])")
            }
        }
    }
}
