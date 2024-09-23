//
//  PublicationsChaptersList.swift
//  Marlin
//
//  Created by Daniel Barela on 2/27/24.
//

import Foundation
import SwiftUI

struct PublicationsChaptersList: View {
    @StateObject var viewModel: PublicationsChaptersListViewModel = 
        PublicationsChaptersListViewModel()
    var pubTypeId: Int
    var title: String
    var chapterTitle: String

    var body: some View {
        List {
            if !viewModel.completeVolumes.isEmpty {
                Section(title) {
                    ForEach(viewModel.completeVolumes) { epub in
                        PublicationSummaryView(s3Key: epub.s3Key ?? "")
                            .padding([.top, .bottom], 16)
                    }
                }
            }
            if !viewModel.chapters.isEmpty {
                Section(chapterTitle) {
                    ForEach(viewModel.chapters) { epub in
                        PublicationSummaryView(
                            s3Key: epub.s3Key ?? "",
                            showTitle: true, showSectionHeader: false,
                            showMoreDetails: false
                        )
//                            .setShowSectionHeader(false)
//                            .setShowMoreDetails(false)
//                            .setShowTitle(true)
                            .padding([.top, .bottom], 16)
                    }
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
