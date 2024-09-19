//
//  PublicationSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 10/25/22.
//

import SwiftUI

struct PublicationSummaryView: DataSourceSummaryView {
    @StateObject var bookmarkViewModel: BookmarkViewModel = BookmarkViewModel()

    var s3Key: String

    var showTitle: Bool = false
    
    var showSectionHeader: Bool = false
    
    var showBookmarkNotes: Bool = false

    var showMoreDetails: Bool = false

    @StateObject var viewModel: PublicationViewModel = PublicationViewModel()

    var bcf: ByteCountFormatter {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useAll]
        bcf.countStyle = .file
        return bcf
    }
    
    var body: some View {
        switch viewModel.publication {
        case nil:
            Color.clear.task {
                await viewModel.setupModel(s3Key: s3Key)
            }
        case .some(let publication):
            VStack(alignment: .leading, spacing: 8) {
                Text("\(publication.sectionDisplayName ?? "")")
                    .primary()
                Text("File Size: \(bcf.string(fromByteCount: Int64(publication.fileSize ?? 0)))")
                    .secondary()
                if let uploadTime = publication.uploadTime {
                    Text("Upload Time: \(uploadTime.formatted())")
                        .overline()
                }
                bookmarkNotesView(bookmarkViewModel: bookmarkViewModel)
                PublicationActionBar(viewModel: viewModel)
            }
            .task {
                await bookmarkViewModel.getBookmark(itemKey: publication.itemKey, dataSource: DataSources.epub.key)
            }
        }
    }
}
