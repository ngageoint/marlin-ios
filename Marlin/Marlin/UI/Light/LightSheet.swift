//
//  LightSheet.swift
//  Marlin
//
//  Created by Daniel Barela on 2/5/24.
//

import Foundation
import SwiftUI

struct LightSheetView: View {
    @EnvironmentObject var lightRepository: LightRepository
    var featureNumber: String?
    var volumeNumber: String?
    var focusNotification: NSNotification.Name

    @StateObject var viewModel: LightViewModel = LightViewModel()

    var body: some View {
        VStack {
            if let light = viewModel.lights.first {
                LightSummaryView(light: LightListModel(lightModel: light))
                    .setShowMoreDetails(true)
                    .setShowSectionHeader(true)
                    .setShowTitle(true)
            }
        }
        .onChange(of: featureNumber) { newFeatureNumber in
            viewModel.getLights(featureNumber: newFeatureNumber, volumeNumber: volumeNumber)
            NotificationCenter.default.post(
                name: focusNotification,
                object: FocusMapOnItemNotification(
                    item: viewModel.lights.first
                )
            )
        }
        .onChange(of: volumeNumber) { newVolumeNumber in
            viewModel.getLights(featureNumber: featureNumber, volumeNumber: newVolumeNumber)
            NotificationCenter.default.post(
                name: focusNotification,
                object: FocusMapOnItemNotification(
                    item: viewModel.lights.first
                )
            )
        }
        .onAppear {
            viewModel.repository = lightRepository
            viewModel.getLights(featureNumber: featureNumber, volumeNumber: volumeNumber)
            NotificationCenter.default.post(
                name: focusNotification,
                object: FocusMapOnItemNotification(
                    item: viewModel.lights.first
                )
            )
        }
    }
}
