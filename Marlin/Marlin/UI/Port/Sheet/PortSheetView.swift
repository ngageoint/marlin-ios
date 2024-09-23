//
//  PortSheetView.swift
//  Marlin
//
//  Created by Daniel Barela on 1/31/24.
//

import Foundation
import SwiftUI

struct PortSheetView: View {
    var itemKey: String
    var focusNotification: NSNotification.Name

    @StateObject var viewModel: PortViewModel = PortViewModel()

    var body: some View {
        VStack {
            if let port = viewModel.port {
                PortSummaryView(
                    showSectionHeader: true, port: PortListModel(portModel: port),
                    showMoreDetails: true,
                    showTitle: true
                )
//                    .setShowMoreDetails(true)
//                    .setShowSectionHeader(true)
//                    .setShowTitle(true)

            }
        }
        .onChange(of: itemKey) { _ in
            Task {
                await viewModel.getPort(portNumber: Int(itemKey) ?? -1)
            }
        }
        .onChange(of: viewModel.port) { model in
            NotificationCenter.default.post(
                name: focusNotification,
                object: FocusMapOnItemNotification(
                    item: model,
                    definition: DataSources.port
                )
            )
        }
        .task {
            await viewModel.getPort(portNumber: Int(itemKey) ?? -1)
        }
    }
}
