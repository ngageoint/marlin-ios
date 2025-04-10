//
//  NavigationalWarningSheetView.swift
//  Marlin
//
//  Created by Daniel Barela on 2/24/24.
//

import Foundation
import SwiftUI

struct NavigationalWarningSheetView: View {
    var itemKey: String
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
        .onChange(of: itemKey) {
            let split = itemKey.split(separator: "--")
            if split.count == 3 {
                viewModel.getNavigationalWarning(
                    msgYear: Int(split[0]) ?? -1,
                    msgNumber: Int(split[1]) ?? -1,
                    navArea: "\(split[2])"
                )
            }
        }
        .onChange(of: viewModel.navWarning) {
            NotificationCenter.default.post(
                name: focusNotification,
                object: FocusMapOnItemNotification(
                    item: viewModel.navWarning,
                    definition: DataSources.navWarning
                )
            )
        }
        .onAppear {
            let split = itemKey.split(separator: "--")
            if split.count == 3 {
                viewModel.getNavigationalWarning(
                    msgYear: Int(split[0]) ?? -1,
                    msgNumber: Int(split[1]) ?? -1,
                    navArea: "\(split[2])"
                )
            }
        }
    }
}
