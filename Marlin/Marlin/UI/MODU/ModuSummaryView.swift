//
//  ModuSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/17/22.
//

import SwiftUI

struct ModuSummaryView: DataSourceSummaryView {
    @EnvironmentObject var bookmarkRepository: BookmarkRepositoryManager
    @EnvironmentObject var router: MarlinRouter

    @StateObject var bookmarkViewModel: BookmarkViewModel = BookmarkViewModel()

    var showSectionHeader: Bool = false
    
    var showBookmarkNotes: Bool = false

    var modu: ModuListModel
    var showMoreDetails: Bool = false
    var showTitle: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(modu.dateString ?? "")
                .overline()
            if showTitle {
                Text("\(modu.name ?? "")")
                    .primary()
            }
            Text("\(modu.rigStatus ?? "")")
                .lineLimit(1)
                .secondary()
            Text("\(modu.specialStatus ?? "")")
                .lineLimit(1)
                .secondary()
            if modu.canBookmark {
                bookmarkNotesView(bookmarkViewModel: bookmarkViewModel)
            }

            DataSourceActions(
                moreDetails: showMoreDetails ? ModuActions.Tap(name: modu.name, path: $router.path) : nil,
                location: !showMoreDetails ? Actions.Location(latLng: modu.coordinate) : nil,
                zoom: !showMoreDetails ? ModuActions.Zoom(latLng: modu.coordinate, itemKey: modu.id) : nil,
                bookmark: modu.canBookmark ? Actions.Bookmark(
                    itemKey: modu.id,
                    bookmarkViewModel: bookmarkViewModel
                ) : nil,
                share: modu.itemTitle
            )
        }
        .onAppear {
            bookmarkViewModel.repository = bookmarkRepository
            bookmarkViewModel.getBookmark(itemKey: modu.itemKey, dataSource: DataSources.modu.key)
        }
    }
}
