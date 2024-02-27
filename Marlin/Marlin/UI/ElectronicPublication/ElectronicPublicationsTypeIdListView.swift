//
//  ElectronicPublicationsListView.swift
//  Marlin
//
//  Created by Daniel Barela on 2/27/24.
//

import Foundation
import SwiftUI

struct ElectronicPublicationsTypeIdListView: View {
    @EnvironmentObject var repository: ElectronicPublicationRepository
    @StateObject var viewModel: ElectronicPublicationsTypeIdListViewModel = ElectronicPublicationsTypeIdListViewModel()
    var pubTypeId: Int

    var body: some View {
        List {
            ForEach(viewModel.publications) { epub in
                ElectronicPublicationSummaryView(s3Key: epub.s3Key ?? "")
                    .setShowSectionHeader(false)
                    .setShowMoreDetails(false)
                    .setShowTitle(true)
                    .padding([.top, .bottom], 16)
            }
        }
        .background(Color.backgroundColor)
        .navigationTitle((PublicationTypeEnum(rawValue: Int(pubTypeId)) ?? .unknown).description)
        .navigationBarTitleDisplayMode(.inline)
        .listRowBackground(Color.surfaceColor)
        .listStyle(.grouped)
        .task {
            viewModel.repository = repository
            viewModel.pubTypeId = pubTypeId
        }
    }
}
