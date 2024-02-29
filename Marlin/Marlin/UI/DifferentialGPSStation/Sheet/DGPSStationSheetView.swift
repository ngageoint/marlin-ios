//
//  DGPSStationSheetView.swift
//  Marlin
//
//  Created by Daniel Barela on 2/8/24.
//

import Foundation
import SwiftUI

struct DGPSStationSheetView: View {
    @EnvironmentObject var dgpsRepository: DGPSStationRepository
    var featureNumber: Int
    var volumeNumber: String
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
        .onChange(of: featureNumber) { newFeatureNumber in
            viewModel.getDGPSStation(featureNumber: newFeatureNumber, volumeNumber: volumeNumber)
            NotificationCenter.default.post(
                name: focusNotification,
                object: FocusMapOnItemNotification(
                    item: viewModel.dgpsStation
                )
            )
        }
        .onChange(of: volumeNumber) { newVolumeNumber in
            viewModel.getDGPSStation(featureNumber: featureNumber, volumeNumber: newVolumeNumber)
            NotificationCenter.default.post(
                name: focusNotification,
                object: FocusMapOnItemNotification(
                    item: viewModel.dgpsStation
                )
            )
        }
        .onAppear {
            viewModel.repository = dgpsRepository
            viewModel.getDGPSStation(featureNumber: featureNumber, volumeNumber: volumeNumber)
            NotificationCenter.default.post(
                name: focusNotification,
                object: FocusMapOnItemNotification(
                    item: viewModel.dgpsStation
                )
            )
        }
    }
}
