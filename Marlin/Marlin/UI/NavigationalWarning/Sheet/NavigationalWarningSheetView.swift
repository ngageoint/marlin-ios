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
        .onChange(of: itemKey) { newItemKey in
            let split = newItemKey.split(separator: "--")
            if split.count == 3 {
                viewModel.getNavigationalWarning(
                    msgYear: Int(split[0]) ?? -1,
                    msgNumber: Int(split[1]) ?? -1,
                    navArea: "\(split[2])"
                )
            }
        }
        .onChange(of: viewModel.navWarning) { model in
            NotificationCenter.default.post(
                name: focusNotification,
                object: FocusMapOnItemNotification(
                    item: model,
                    definition: DataSources.navWarning
                )
            )
        }
        .onAppear {
            viewModel.repository = navigationalWarningRepository
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
