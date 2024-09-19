//
//  AsamSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/15/22.
//

import SwiftUI

struct AsamSummaryView: DataSourceSummaryView {
    @EnvironmentObject var router: MarlinRouter

    var showSectionHeader: Bool = false

    var asam: AsamListModel
    var showMoreDetails: Bool = false
    var showTitle: Bool = true
    var showBookmarkNotes: Bool = false
    
    @StateObject var bookmarkViewModel: BookmarkViewModel = BookmarkViewModel()
        
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
}
