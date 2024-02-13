//
//  ElectronicPublicationSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 10/25/22.
//

import SwiftUI

struct ElectronicPublicationSummaryView: DataSourceSummaryView {
    @EnvironmentObject var bookmarkRepository: BookmarkRepositoryManager
    @StateObject var bookmarkViewModel: BookmarkViewModel = BookmarkViewModel()

    var showTitle: Bool = false
    
    var showSectionHeader: Bool = false
    
    var showBookmarkNotes: Bool = false

    var electronicPublication: ElectronicPublication
    var showMoreDetails: Bool = false

    var bcf: ByteCountFormatter {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useAll]
        bcf.countStyle = .file
        return bcf
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(electronicPublication.sectionDisplayName ?? "")")
                .primary()
            Text("File Size: \(bcf.string(fromByteCount: electronicPublication.fileSize))")
                .secondary()
            if let uploadTime = electronicPublication.uploadTime {
                Text("Upload Time: \(uploadTime.formatted())")
                    .overline()
            }
            bookmarkNotesView(bookmarkViewModel: bookmarkViewModel)
            ElectronicPublicationActionBar(electronicPublication: electronicPublication)
        }
        .onAppear {
            bookmarkViewModel.repository = bookmarkRepository
            bookmarkViewModel.getBookmark(itemKey: electronicPublication.itemKey, dataSource: DataSources.epub.key)
        }
    }
}
