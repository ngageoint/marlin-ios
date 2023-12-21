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
    @State var reference: String
    @StateObject var viewModel: AsamViewModel = AsamViewModel()

    var body: some View {
        VStack {
            if let asamListModel = viewModel.asamListModel {
                AsamSummaryView(asam: asamListModel)
                
            }
        }
        .onChange(of: reference) { _ in
            viewModel.getAsam(reference: reference)
        }
        .onAppear {
            viewModel.repository = asamRepository
            viewModel.getAsam(reference: reference)
        }
    }
}
