//
//  NoticeToMarinersSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 8/4/23.
//

import SwiftUI

struct NoticeToMarinersSummaryView: DataSourceSummaryView {
    @StateObject var bookmarkViewModel: BookmarkViewModel = BookmarkViewModel()
    @EnvironmentObject var router: MarlinRouter

    var noticeToMariners: NoticeToMarinersListModel
    var showBookmarkNotes: Bool = false

    var showMoreDetails: Bool = false
    var showTitle: Bool = false
    var showSectionHeader: Bool = false
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(verbatim: "\(noticeToMariners.noticeNumber ?? 0)")
                        .overline()
                    Text(noticeToMariners.dateRange())
                        .secondary()
                }
                Spacer()
                BookmarkButton(
                    action: Actions.Bookmark(
                        itemKey: noticeToMariners.itemKey,
                        bookmarkViewModel: bookmarkViewModel
                    )
                )
            }
            bookmarkNotesView(bookmarkViewModel: bookmarkViewModel)
        }
        .task {
            await bookmarkViewModel.getBookmark(itemKey: noticeToMariners.itemKey, dataSource: noticeToMariners.key)
        }
    }
    
    @ViewBuilder
    func bookmarkNotesView(bookmarkViewModel: BookmarkViewModel?) -> some View {
        if showBookmarkNotes, let bookmarkViewModel = bookmarkViewModel {
            BookmarkNotes(bookmarkViewModel: bookmarkViewModel)
        }
    }
}
