//
//  AsamSheetView.swift
//  Marlin
//
//  Created by Daniel Barela on 11/28/23.
//

import Foundation
import SwiftUI

struct AsamSheetView: View {
    @EnvironmentObject var asamRepository: AsamRepository
    var reference: String
    var focusNotification: NSNotification.Name

    @StateObject var viewModel: AsamViewModel = AsamViewModel()

    var body: some View {
        Self._printChanges()

        return VStack {
            if let asam = viewModel.asam {
                AsamSummaryView(asam: AsamListModel(asamModel: asam))
                    .setShowMoreDetails(true)
                    .setShowSectionHeader(true)
                    .setShowTitle(true)
            }
        }
        .onChange(of: reference) { newReference in
            viewModel.getAsam(reference: newReference)
            NotificationCenter.default.post(
                name: focusNotification,
                object: FocusMapOnItemNotification(
                    item: viewModel.asam
                )
            )
        }
        .onAppear {
            viewModel.repository = asamRepository
            viewModel.getAsam(reference: reference)
            NotificationCenter.default.post(
                name: focusNotification,
                object: FocusMapOnItemNotification(
                    item: viewModel.asam
                )
            )
        }
    }
}
