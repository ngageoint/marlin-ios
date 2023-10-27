//
//  NoticeToMarinersSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 8/4/23.
//

import SwiftUI

struct NoticeToMarinersSummaryView: DataSourceSummaryView {
    @EnvironmentObject var bookmarkRepository: BookmarkRepositoryManager
    @StateObject var bookmarkViewModel: BookmarkViewModel = BookmarkViewModel()

    var noticeToMariners: NoticeToMariners
    var showBookmarkNotes: Bool = false

    var showMoreDetails: Bool = false
    var showTitle: Bool = false
    var showSectionHeader: Bool = false
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(verbatim: "\(noticeToMariners.noticeNumber)")
                        .overline()
                    Text(noticeToMariners.dateRange())
                        .secondary()
                }
                Spacer()
                BookmarkButton(viewModel: bookmarkViewModel)
            }
            bookmarkNotesView(noticeToMariners)
        }
        .onAppear {
            bookmarkViewModel.repository = bookmarkRepository
            bookmarkViewModel.getBookmark(itemKey: noticeToMariners.itemKey, dataSource: noticeToMariners.key)
        }
    }
}
