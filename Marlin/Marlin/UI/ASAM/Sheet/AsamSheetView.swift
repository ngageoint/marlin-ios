//
//  AsamSheetView.swift
//  Marlin
//
//  Created by Daniel Barela on 11/28/23.
//

import Foundation
import SwiftUI

struct AsamSheetView: View {
    var itemKey: String
    var focusNotification: NSNotification.Name

    @StateObject var viewModel: AsamViewModel = AsamViewModel()

    var body: some View {
        Self._printChanges()

        return VStack {
            if let asam = viewModel.asam {
                AsamSummaryView(asam: AsamListModel(asamModel: asam), showSectionHeader: true, showMoreDetails: true, showTitle: true)
//                    .setShowMoreDetails(true)
//                    .setShowSectionHeader(true)
//                    .setShowTitle(true)
            }
        }
        .onChange(of: itemKey) { newReference in
            Task {
                await viewModel.getAsam(reference: newReference)
            }
        }
        .onChange(of: viewModel.asam) { model in
            NotificationCenter.default.post(
                name: focusNotification,
                object: FocusMapOnItemNotification(
                    item: model,
                    definition: DataSources.asam
                )
            )
        }
        .task {
            await viewModel.getAsam(reference: itemKey)
        }
    }
}
