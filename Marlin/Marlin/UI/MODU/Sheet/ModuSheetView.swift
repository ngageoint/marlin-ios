//
//  ModuSheetView.swift
//  Marlin
//
//  Created by Daniel Barela on 1/23/24.
//

import Foundation
import SwiftUI

struct ModuSheetView: View {
    var itemKey: String
    var focusNotification: NSNotification.Name

    @StateObject var viewModel: ModuViewModel = ModuViewModel()

    var body: some View {
        Self._printChanges()

        return VStack {
            if let modu = viewModel.modu {
                ModuSummaryView(modu: ModuListModel(moduModel: modu))
                    .setShowMoreDetails(true)
                    .setShowSectionHeader(true)
                    .setShowTitle(true)

            }
        }
        .onChange(of: itemKey) {
            viewModel.getModu(name: itemKey)
        }
        .onChange(of: viewModel.modu) {
            NotificationCenter.default.post(
                name: focusNotification,
                object: FocusMapOnItemNotification(
                    item: viewModel.modu,
                    definition: DataSources.modu
                )
            )
        }
        .onAppear {
            viewModel.getModu(name: itemKey)
        }
    }
}
