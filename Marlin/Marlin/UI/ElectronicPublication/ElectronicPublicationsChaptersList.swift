//
//  ElectronicPublicationsChaptersList.swift
//  Marlin
//
//  Created by Daniel Barela on 2/27/24.
//

import Foundation
import SwiftUI

struct ElectronicPublicationsChaptersList: View {
    @EnvironmentObject var repository: ElectronicPublicationRepository
    @StateObject var viewModel: ElectronicPublicationsChaptersListViewModel = ElectronicPublicationsChaptersListViewModel()
    var pubTypeId: Int
    var title: String
    var chapterTitle: String

    var body: some View {
        List {
            if !viewModel.completeVolumes.isEmpty {
                Section(title) {
                    ForEach(viewModel.completeVolumes) { epub in
                        ElectronicPublicationSummaryView(s3Key: epub.s3Key ?? "")
                            .padding([.top, .bottom], 16)
                    }
                }
            }
            if !viewModel.chapters.isEmpty {
                Section(chapterTitle) {
                    ForEach(viewModel.chapters) { epub in
                        ElectronicPublicationSummaryView(s3Key: epub.s3Key ?? "")
                            .setShowSectionHeader(false)
                            .setShowMoreDetails(false)
                            .setShowTitle(true)
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
            viewModel.repository = repository
            viewModel.pubTypeId = pubTypeId
        }
    }
}
