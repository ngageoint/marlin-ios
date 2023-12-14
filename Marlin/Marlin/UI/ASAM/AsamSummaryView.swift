//
//  AsamSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/15/22.
//

import SwiftUI

struct AsamSummaryView: DataSourceSummaryView {
    @EnvironmentObject var bookmarkRepository: BookmarkRepositoryManager

    var showSectionHeader: Bool = false
    
    var bookmark: Bookmark?
        
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
                bookmarkNotesView(asam)
                
            }
            DataSourceActions(
                moreDetails: showMoreDetails ? AsamActions.Tap(reference: asam.reference) : nil,
                location: !showMoreDetails ? Actions.Location(latLng: asam.coordinate) : nil,
                zoom: !showMoreDetails ? AsamActions.Zoom(latLng: asam.coordinate, itemKey: asam.id) : nil,
                bookmark: asam.canBookmark ? AsamActions.Bookmark(itemKey: asam.id, bookmarkViewModel: bookmarkViewModel) : nil
            )
//            DataSourceActionBar(data: asam, showMoreDetailsButton: showMoreDetails, showFocusButton: !showMoreDetails)
        }
        .onAppear {
            bookmarkViewModel.repository = bookmarkRepository
            bookmarkViewModel.getBookmark(itemKey: asam.id, dataSource: DataSources.asam.key)
        }
    }
}
