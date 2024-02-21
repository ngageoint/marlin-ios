//
//  ElectronicPublicationSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 10/25/22.
//

import SwiftUI

struct ElectronicPublicationSummaryView: DataSourceSummaryView {
    @EnvironmentObject var repository: ElectronicPublicationRepository
    @EnvironmentObject var bookmarkRepository: BookmarkRepositoryManager
    @StateObject var bookmarkViewModel: BookmarkViewModel = BookmarkViewModel()

    var s3Key: String

    var showTitle: Bool = false
    
    var showSectionHeader: Bool = false
    
    var showBookmarkNotes: Bool = false

    var showMoreDetails: Bool = false

    @StateObject var viewModel: ElectronicPublicationViewModel = ElectronicPublicationViewModel()

    var bcf: ByteCountFormatter {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useAll]
        bcf.countStyle = .file
        return bcf
    }
    
    var body: some View {
        switch viewModel.electronicPublication {
        case nil:
            Color.clear.onAppear {
                viewModel.setupModel(repository: repository, s3Key: s3Key)
            }
        case .some(let electronicPublication):
            VStack(alignment: .leading, spacing: 8) {
                Text("\(electronicPublication.sectionDisplayName ?? "")")
                    .primary()
                Text("File Size: \(bcf.string(fromByteCount: Int64(electronicPublication.fileSize ?? 0)))")
                    .secondary()
                if let uploadTime = electronicPublication.uploadTime {
                    Text("Upload Time: \(uploadTime.formatted())")
                        .overline()
                }
                bookmarkNotesView(bookmarkViewModel: bookmarkViewModel)
                ElectronicPublicationActionBar(viewModel: viewModel)
            }
            .onAppear {
                bookmarkViewModel.repository = bookmarkRepository
                bookmarkViewModel.getBookmark(itemKey: electronicPublication.itemKey, dataSource: DataSources.epub.key)
            }
        }
    }
}
