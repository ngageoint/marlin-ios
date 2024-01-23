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
    var name: String
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
        .onChange(of: name) { newName in
            viewModel.getModu(name: newName)
            NotificationCenter.default.post(
                name: focusNotification,
                object: FocusMapOnItemNotification(
                    item: viewModel.modu
                )
            )
        }
        .onAppear {
            viewModel.repository = moduRepository
            viewModel.getModu(name: name)
            NotificationCenter.default.post(
                name: focusNotification,
                object: FocusMapOnItemNotification(
                    item: viewModel.modu
                )
            )
        }
    }
}
