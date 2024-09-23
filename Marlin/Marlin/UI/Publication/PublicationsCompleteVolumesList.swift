//
//  PublicationsCompleteVolumesList.swift
//  Marlin
//
//  Created by Daniel Barela on 2/27/24.
//

import Foundation
import SwiftUI

struct PublicationsCompleteVolumesList: View {
    @StateObject var viewModel: PublicationsCompleteVolumeListViewModel = PublicationsCompleteVolumeListViewModel()
    var pubTypeId: Int

    var body: some View {
        List {
            Section("Complete Volume\(viewModel.publications.count == 1 ? "(s)" : "")") {
                ForEach(viewModel.publications) { epub in
                    PublicationSummaryView(
                        s3Key: epub.s3Key ?? "",
                        showTitle: true, showSectionHeader: false,
                        showMoreDetails: false
                    )
//                        .setShowSectionHeader(false)
//                        .setShowMoreDetails(false)
//                        .setShowTitle(true)
                        .padding([.top, .bottom], 16)
                }
            }
        }
        .background(Color.backgroundColor)
        .navigationTitle((PublicationTypeEnum(rawValue: pubTypeId) ?? .unknown).description)
        .navigationBarTitleDisplayMode(.inline)
        .listRowBackground(Color.surfaceColor)
        .listStyle(.grouped)
        .task {
            viewModel.pubTypeId = pubTypeId
            Metrics.shared.appRoute(["epubs", PublicationTypeEnum(rawValue: pubTypeId)?.description ?? "pubs"])
        }
    }
}
