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
    var itemKey: String
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
        .onChange(of: itemKey) { newItemKey in
            let split = newItemKey.split(separator: "--")
            if split.count == 3 {
                viewModel.getLights(featureNumber: "\(split[0])", volumeNumber: "\(split[1])")
            }
        }
        .onChange(of: viewModel.lights) { model in
            NotificationCenter.default.post(
                name: focusNotification,
                object: FocusMapOnItemNotification(
                    item: model.first,
                    definition: DataSources.light
                )
            )
        }
        .onAppear {
            viewModel.repository = lightRepository
            let split = itemKey.split(separator: "--")
            if split.count == 3 {
                viewModel.getLights(featureNumber: "\(split[0])", volumeNumber: "\(split[1])")
            }
        }
    }
}
