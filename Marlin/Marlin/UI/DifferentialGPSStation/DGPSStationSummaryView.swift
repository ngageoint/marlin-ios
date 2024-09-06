//
//  DGPSStationSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 8/30/22.
//

import SwiftUI

struct DGPSStationSummaryView: DataSourceSummaryView {
    @EnvironmentObject var router: MarlinRouter
    var showBookmarkNotes: Bool = false

    var dgpsStation: DGPSStationListModel
    var showMoreDetails: Bool = false
    var showSectionHeader: Bool = false
    var showTitle: Bool = true

    @StateObject var bookmarkViewModel: BookmarkViewModel = BookmarkViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(dgpsStation.featureNumber ?? 0) \(dgpsStation.volumeNumber ?? "")")
                .overline()
            if showTitle {
                Text("\(dgpsStation.name ?? "")")
                    .primary()
            }
            if showMoreDetails {
                Text(dgpsStation.geopoliticalHeading ?? "")
                    .secondary()
            }
            if showSectionHeader {
                Text(dgpsStation.sectionHeader ?? "")
                    .secondary()
            }
            if let stationID = dgpsStation.stationID, stationID != "" {
                Text(stationID)
                    .secondary()
            }
            if let remarks = dgpsStation.remarks, remarks != "" {
                Text(remarks)
                    .secondary()
            }
            if dgpsStation.canBookmark {
                bookmarkNotesView(bookmarkViewModel: bookmarkViewModel)
            }

            DataSourceActions(
                moreDetails: showMoreDetails ? DGPSStationActions.Tap(
                    featureNumber: dgpsStation.featureNumber,
                    volumeNumber: dgpsStation.volumeNumber,
                    path: $router.path
                ) : nil,
                location: !showMoreDetails ? Actions.Location(latLng: dgpsStation.coordinate) : nil,
                zoom: !showMoreDetails ? DGPSStationActions.Zoom(
                    latLng: dgpsStation.coordinate,
                    itemKey: dgpsStation.id
                ) : nil,
                bookmark: dgpsStation.canBookmark ? Actions.Bookmark(
                    itemKey: dgpsStation.id,
                    bookmarkViewModel: bookmarkViewModel
                ) : nil,
                share: dgpsStation.itemTitle
            )
        }
        .onAppear {
            bookmarkViewModel.getBookmark(itemKey: dgpsStation.id, dataSource: DataSources.dgps.key)
        }
    }
}
