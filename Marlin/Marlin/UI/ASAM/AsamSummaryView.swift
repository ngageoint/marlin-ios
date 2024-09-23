//
//  AsamSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/15/22.
//

import SwiftUI

struct AsamSummaryView: View {
    var asam: AsamListModel
    @EnvironmentObject var router: MarlinRouter
    @StateObject var bookmarkViewModel: BookmarkViewModel = BookmarkViewModel()

    var showSectionHeader: Bool = false

    var showMoreDetails: Bool = false
    var showTitle: Bool = true
    var showBookmarkNotes: Bool = false
        
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(asam.dateString ?? "")
                .overline()
            if showTitle {
                Text(asam.itemTitle)
                    .primary()
            }
            Text(asam.asamDescription ?? "")
                .lineLimit(8)
                .secondary()
            if asam.canBookmark {
                bookmarkNotesView(bookmarkViewModel: bookmarkViewModel)
            }
            DataSourceActions(
                moreDetails: showMoreDetails ? AsamActions.Tap(reference: asam.reference, path: $router.path) : nil,
                location: Actions.Location(latLng: asam.coordinate),
                zoom: !showMoreDetails ? AsamActions.Zoom(latLng: asam.coordinate, itemKey: asam.id) : nil,
                bookmark: asam.canBookmark ? Actions.Bookmark(
                    itemKey: asam.id,
                    bookmarkViewModel: bookmarkViewModel
                ) : nil,
                share: asam.itemTitle
            )
        }
        .task {
            await bookmarkViewModel.getBookmark(itemKey: asam.id, dataSource: DataSources.asam.key)
        }
    }
    
    @ViewBuilder
    func bookmarkNotesView(bookmarkViewModel: BookmarkViewModel?) -> some View {
        if showBookmarkNotes, let bookmarkViewModel = bookmarkViewModel {
            BookmarkNotes(bookmarkViewModel: bookmarkViewModel)
        }
    }
}
