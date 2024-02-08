//
//  DifferentialGPSStationSheetView.swift
//  Marlin
//
//  Created by Daniel Barela on 2/8/24.
//

import Foundation
import SwiftUI

struct DifferentialGPSStationSheetView: View {
    @EnvironmentObject var dgpsRepository: DifferentialGPSStationRepository
    var featureNumber: Int
    var volumeNumber: String
    var focusNotification: NSNotification.Name

    @StateObject var viewModel: DifferentialGPSStationViewModel = DifferentialGPSStationViewModel()

    var body: some View {
        return VStack {
            if let differentialGPSStation = viewModel.differentialGPSStation {
                DifferentialGPSStationSummaryView(
                    differentialGPSStation: DifferentialGPSStationListModel(
                        differentialGPSStationModel: differentialGPSStation
                    )
                )
                .setShowMoreDetails(true)
                .setShowSectionHeader(true)
                .setShowTitle(true)
            }
        }
        .onChange(of: featureNumber) { newFeatureNumber in
            viewModel.getDifferentialGPSStation(featureNumber: newFeatureNumber, volumeNumber: volumeNumber)
            NotificationCenter.default.post(
                name: focusNotification,
                object: FocusMapOnItemNotification(
                    item: viewModel.differentialGPSStation
                )
            )
        }
        .onChange(of: volumeNumber) { newVolumeNumber in
            viewModel.getDifferentialGPSStation(featureNumber: featureNumber, volumeNumber: newVolumeNumber)
            NotificationCenter.default.post(
                name: focusNotification,
                object: FocusMapOnItemNotification(
                    item: viewModel.differentialGPSStation
                )
            )
        }
        .onAppear {
            viewModel.repository = dgpsRepository
            viewModel.getDifferentialGPSStation(featureNumber: featureNumber, volumeNumber: volumeNumber)
            NotificationCenter.default.post(
                name: focusNotification,
                object: FocusMapOnItemNotification(
                    item: viewModel.differentialGPSStation
                )
            )
        }
    }
}
