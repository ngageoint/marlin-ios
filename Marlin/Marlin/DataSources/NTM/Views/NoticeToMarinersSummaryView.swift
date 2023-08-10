//
//  NoticeToMarinersSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 8/4/23.
//

import SwiftUI

struct NoticeToMarinersSummaryView: DataSourceSummaryView {
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
                if let itemKey = noticeToMariners.itemKey {
                    BookmarkButton(viewModel: BookmarkViewModel(itemKey: itemKey, dataSource: NoticeToMariners.key))
                }
            }
        
            bookmarkNotesView(noticeToMariners)
        }
    }
}
