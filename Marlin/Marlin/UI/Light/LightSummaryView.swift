//
//  LightSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 7/6/22.
//

import SwiftUI

struct LightSummaryView: DataSourceSummaryView {
    @EnvironmentObject var bookmarkRepository: BookmarkRepositoryManager
    @EnvironmentObject var router: MarlinRouter

    var showSectionHeader: Bool = false
    
    var showBookmarkNotes: Bool = false

    var light: LightListModel
    var showMoreDetails: Bool = false
    var showTitle: Bool = true
    @StateObject var bookmarkViewModel: BookmarkViewModel = BookmarkViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(light.featureNumber ?? "") \(light.internationalFeature ?? "") \(light.volumeNumber ?? "")")
                .overline()
            if showTitle {
                Text("\(light.name ?? "")")
                    .primary()
            }
            if showMoreDetails {
                Text(light.sectionHeader ?? "")
                    .secondary()
            }
            if let structure = light.structure?.trimmingCharacters(in: .whitespacesAndNewlines) {
                Text(structure)
                    .secondary()
            }
            if light.canBookmark {
                bookmarkNotesView(bookmarkViewModel: bookmarkViewModel)
            }

            DataSourceActions(
                moreDetails: showMoreDetails ? 
                LightActions.Tap(volume: light.volumeNumber, featureNumber: light.featureNumber, path: $router.path)
                : nil,
                location: !showMoreDetails ? Actions.Location(latLng: light.coordinate) : nil,
                zoom: !showMoreDetails ? LightActions.Zoom(latLng: light.coordinate, itemKey: light.id) : nil,
                bookmark: light.canBookmark ? Actions.Bookmark(
                    itemKey: light.id,
                    bookmarkViewModel: bookmarkViewModel
                ) : nil,
                share: light.itemTitle
            )
        }
        .onAppear {
            bookmarkViewModel.repository = bookmarkRepository
            bookmarkViewModel.getBookmark(itemKey: light.itemKey, dataSource: DataSources.light.key)
        }
    }
}
