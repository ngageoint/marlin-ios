//
//  DGPSStationSheetView.swift
//  Marlin
//
//  Created by Daniel Barela on 2/8/24.
//

import Foundation
import SwiftUI

struct DGPSStationSheetView: View {
    var itemKey: String
    var focusNotification: NSNotification.Name

    @StateObject var viewModel: DGPSStationViewModel = DGPSStationViewModel()

    var body: some View {
        VStack {
            if let dgpsStation = viewModel.dgpsStation {
                DGPSStationSummaryView(
                    dgpsStation: DGPSStationListModel(
                        dgpsStationModel: dgpsStation
                    )
                )
                .setShowMoreDetails(true)
                .setShowSectionHeader(true)
                .setShowTitle(true)
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
            let split = itemKey.split(separator: "--")
            if split.count == 2 {
                viewModel.getDGPSStation(featureNumber: Int(split[0]) ?? -1, volumeNumber: "\(split[1])")
            }
        }
    }
}
