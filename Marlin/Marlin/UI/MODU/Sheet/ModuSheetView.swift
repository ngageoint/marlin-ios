//
//  ModuSheetView.swift
//  Marlin
//
//  Created by Daniel Barela on 1/23/24.
//

import Foundation
import SwiftUI

struct ModuSheetView: View {
    @EnvironmentObject var moduRepository: ModuRepository
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
        .onChange(of: itemKey) { newItemKey in
            viewModel.getModu(name: newItemKey)
        }
        .onChange(of: viewModel.modu) { model in
            NotificationCenter.default.post(
                name: focusNotification,
                object: FocusMapOnItemNotification(
                    item: model,
                    definition: DataSources.modu
                )
            )
        }
        .onAppear {
            viewModel.repository = moduRepository
            viewModel.getModu(name: itemKey)
        }
    }
}
