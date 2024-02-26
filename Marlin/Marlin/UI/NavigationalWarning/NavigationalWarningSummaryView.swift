//
//  NavigationalWarningSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/23/22.
//

import SwiftUI
import MapKit

struct NavigationalWarningSummaryView: DataSourceSummaryView {
    @EnvironmentObject var router: MarlinRouter
    @EnvironmentObject var bookmarkRepository: BookmarkRepositoryManager
    @StateObject var bookmarkViewModel: BookmarkViewModel = BookmarkViewModel()
    
    var showSectionHeader: Bool = false
    
    var showBookmarkNotes: Bool = false

    var navigationalWarning: NavigationalWarningModel
    var showMoreDetails: Bool = false
    var mapName: String?
    var showTitle: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(navigationalWarning.dateString ?? "")
                .overline()
            if showTitle {
                Text(navigationalWarning.itemTitle)
                    .primary()
            }
            Text("\(navigationalWarning.text ?? "")")
                .multilineTextAlignment(.leading)
                .lineLimit(8)
                .secondary()
            if navigationalWarning.canBookmark {
                bookmarkNotesView(bookmarkViewModel: bookmarkViewModel)
            }
            DataSourceActions(
                moreDetails: showMoreDetails ? NavigationalWarningActions.Tap(
                    msgYear: navigationalWarning.msgYear,
                    msgNumber: navigationalWarning.msgNumber,
                    navArea: navigationalWarning.navArea,
                    path: $router.path
                ) : nil,
                location: Actions.Location(latLng: navigationalWarning.coordinate),
                zoom: !showMoreDetails ? NavigationalWarningActions.Zoom(
                    latLng: navigationalWarning.coordinate,
                    itemKey: navigationalWarning.itemKey
                ) : nil,
                bookmark: navigationalWarning.canBookmark ? Actions.Bookmark(
                    itemKey: navigationalWarning.itemKey,
                    bookmarkViewModel: bookmarkViewModel
                ) : nil,
                share: navigationalWarning.itemTitle
            )
        }
        .onAppear {
            bookmarkViewModel.repository = bookmarkRepository
            bookmarkViewModel.getBookmark(itemKey: navigationalWarning.itemKey, dataSource: DataSources.navWarning.key)
        }
    }
}
