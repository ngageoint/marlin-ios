//
//  RadioBeaconSheetView.swift
//  Marlin
//
//  Created by Daniel Barela on 2/8/24.
//

import Foundation
import SwiftUI

struct RadioBeaconSheetView: View {

    @EnvironmentObject var radioBeaconRepository: RadioBeaconRepository
    var featureNumber: Int
    var volumeNumber: String
    var focusNotification: NSNotification.Name

    @StateObject var viewModel: RadioBeaconViewModel = RadioBeaconViewModel()

    var body: some View {
        VStack {
            if let radioBeacon = viewModel.radioBeacon {
                RadioBeaconSummaryView(radioBeacon: RadioBeaconListModel(radioBeaconModel: radioBeacon))
                    .setShowMoreDetails(true)
                    .setShowSectionHeader(true)
                    .setShowTitle(true)
            }
        }
        .onChange(of: featureNumber) { newFeatureNumber in
            viewModel.getRadioBeacon(featureNumber: newFeatureNumber, volumeNumber: volumeNumber)
            NotificationCenter.default.post(
                name: focusNotification,
                object: FocusMapOnItemNotification(
                    item: viewModel.radioBeacon
                )
            )
        }
        .onChange(of: volumeNumber) { newVolumeNumber in
            viewModel.getRadioBeacon(featureNumber: featureNumber, volumeNumber: newVolumeNumber)
            NotificationCenter.default.post(
                name: focusNotification,
                object: FocusMapOnItemNotification(
                    item: viewModel.radioBeacon
                )
            )
        }
        .onAppear {
            viewModel.repository = radioBeaconRepository
            viewModel.getRadioBeacon(featureNumber: featureNumber, volumeNumber: volumeNumber)
            NotificationCenter.default.post(
                name: focusNotification,
                object: FocusMapOnItemNotification(
                    item: viewModel.radioBeacon
                )
            )
        }
    }
}
