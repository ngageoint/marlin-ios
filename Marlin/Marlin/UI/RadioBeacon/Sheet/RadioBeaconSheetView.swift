//
//  RadioBeaconSheetView.swift
//  Marlin
//
//  Created by Daniel Barela on 2/8/24.
//

import Foundation
import SwiftUI

struct RadioBeaconSheetView: View {

    var itemKey: String
    var focusNotification: NSNotification.Name

    @StateObject var viewModel: RadioBeaconViewModel = RadioBeaconViewModel()

    var body: some View {
        VStack {
            if let radioBeacon = viewModel.radioBeacon {
                RadioBeaconSummaryView(
                    radioBeacon: RadioBeaconListModel(radioBeaconModel: radioBeacon),
                    showMoreDetails: true,
                    showSectionHeader: true
                )
//                    .setShowMoreDetails(true)
//                    .setShowSectionHeader(true)
//                    .setShowTitle(true)
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
            let split = itemKey.split(separator: "--")
            if split.count == 2 {
                viewModel.getRadioBeacon(featureNumber: Int(split[0]) ?? -1, volumeNumber: "\(split[1])")
            }
        }
    }
}
