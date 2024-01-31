//
//  PortSheetView.swift
//  Marlin
//
//  Created by Daniel Barela on 1/31/24.
//

import Foundation
import SwiftUI

struct PortSheetView: View {
    @EnvironmentObject var portRepository: PortRepository
    var portNumber: Int64
    var focusNotification: NSNotification.Name

    @StateObject var viewModel: PortViewModel = PortViewModel()

    var body: some View {
        Self._printChanges()

        return VStack {
            if let port = viewModel.port {
                PortSummaryView(port: PortListModel(portModel: port))
                    .setShowMoreDetails(true)
                    .setShowSectionHeader(true)
                    .setShowTitle(true)

            }
        }
        .onChange(of: portNumber) { newPortNumber in
            viewModel.getPort(portNumber: newPortNumber)
            NotificationCenter.default.post(
                name: focusNotification,
                object: FocusMapOnItemNotification(
                    item: viewModel.port
                )
            )
        }
        .onAppear {
            viewModel.repository = portRepository
            viewModel.getPort(portNumber: portNumber)
            NotificationCenter.default.post(
                name: focusNotification,
                object: FocusMapOnItemNotification(
                    item: viewModel.port
                )
            )
        }
    }
}
