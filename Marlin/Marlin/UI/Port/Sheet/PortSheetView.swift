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
                PortSummaryView(port: PortListModel(portModel: port))
                    .setShowMoreDetails(true)
                    .setShowSectionHeader(true)
                    .setShowTitle(true)

            }
        }
        .onChange(of: itemKey) { _ in
            viewModel.getPort(portNumber: Int(itemKey) ?? -1)
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
        .onAppear {
            viewModel.getPort(portNumber: Int(itemKey) ?? -1)
        }
    }
}
