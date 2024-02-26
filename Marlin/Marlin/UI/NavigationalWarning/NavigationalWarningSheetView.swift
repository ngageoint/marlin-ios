//
//  NavigationalWarningSheetView.swift
//  Marlin
//
//  Created by Daniel Barela on 2/24/24.
//

import Foundation
import SwiftUI

struct NavigationalWarningSheetView: View {
    @EnvironmentObject var navigationalWarningRepository: NavigationalWarningRepository
    var msgYear: Int
    var msgNumber: Int
    var navArea: String
    var focusNotification: NSNotification.Name

    @StateObject var viewModel: NavigationalWarningViewModel = NavigationalWarningViewModel()

    var body: some View {
        return VStack {
            if let navWarning = viewModel.navWarning {
                NavigationalWarningSummaryView(navigationalWarning: navWarning)
                    .setShowMoreDetails(true)
                    .setShowSectionHeader(true)
                    .setShowTitle(true)
            }
        }
        .onChange(of: msgYear) { newMsgYear in
            viewModel.getNavigationalWarning(msgYear: newMsgYear, msgNumber: msgNumber, navArea: navArea)
            NotificationCenter.default.post(
                name: focusNotification,
                object: FocusMapOnItemNotification(
                    item: viewModel.navWarning
                )
            )
        }
        .onChange(of: msgNumber) { newMsgNumber in
            viewModel.getNavigationalWarning(msgYear: msgYear, msgNumber: newMsgNumber, navArea: navArea)
            NotificationCenter.default.post(
                name: focusNotification,
                object: FocusMapOnItemNotification(
                    item: viewModel.navWarning
                )
            )
        }
        .onChange(of: navArea) { newNavArea in
            viewModel.getNavigationalWarning(msgYear: msgYear, msgNumber: msgNumber, navArea: newNavArea)
            NotificationCenter.default.post(
                name: focusNotification,
                object: FocusMapOnItemNotification(
                    item: viewModel.navWarning
                )
            )
        }
        .onAppear {
            viewModel.repository = navigationalWarningRepository
            viewModel.getNavigationalWarning(msgYear: msgYear, msgNumber: msgNumber, navArea: navArea)
            NotificationCenter.default.post(
                name: focusNotification,
                object: FocusMapOnItemNotification(
                    item: viewModel.navWarning
                )
            )
        }
    }
}
