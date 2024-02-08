//
//  DifferentialGPSStationSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 8/30/22.
//

import SwiftUI

struct DifferentialGPSStationSummaryView: DataSourceSummaryView {
    @EnvironmentObject var bookmarkRepository: BookmarkRepositoryManager
    @EnvironmentObject var router: MarlinRouter
    var showBookmarkNotes: Bool = false

    var differentialGPSStation: DifferentialGPSStationListModel
    var showMoreDetails: Bool = false
    var showSectionHeader: Bool = false
    var showTitle: Bool = true

    @StateObject var bookmarkViewModel: BookmarkViewModel = BookmarkViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(differentialGPSStation.featureNumber ?? 0) \(differentialGPSStation.volumeNumber ?? "")")
                .overline()
            if showTitle {
                Text("\(differentialGPSStation.name ?? "")")
                    .primary()
            }
            if showMoreDetails {
                Text(differentialGPSStation.geopoliticalHeading ?? "")
                    .secondary()
            }
            if showSectionHeader {
                Text(differentialGPSStation.sectionHeader ?? "")
                    .secondary()
            }
            if let stationID = differentialGPSStation.stationID, stationID != "" {
                Text(stationID)
                    .secondary()
            }
            if let remarks = differentialGPSStation.remarks, remarks != "" {
                Text(remarks)
                    .secondary()
            }
            if differentialGPSStation.canBookmark {
                bookmarkNotesView(differentialGPSStation)
            }

            DataSourceActions(
                moreDetails: showMoreDetails ? DifferentialGPSStationActions.Tap(
                    featureNumber: differentialGPSStation.featureNumber,
                    volumeNumber: differentialGPSStation.volumeNumber,
                    path: $router.path
                ) : nil,
                location: !showMoreDetails ? Actions.Location(latLng: differentialGPSStation.coordinate) : nil,
                zoom: !showMoreDetails ? DifferentialGPSStationActions.Zoom(
                    latLng: differentialGPSStation.coordinate,
                    itemKey: differentialGPSStation.id
                ) : nil,
                bookmark: differentialGPSStation.canBookmark ? Actions.Bookmark(
                    itemKey: differentialGPSStation.id,
                    bookmarkViewModel: bookmarkViewModel
                ) : nil,
                share: differentialGPSStation.itemTitle
            )
        }
        .onAppear {
            bookmarkViewModel.repository = bookmarkRepository
            bookmarkViewModel.getBookmark(itemKey: differentialGPSStation.id, dataSource: DataSources.dgps.key)
        }
    }
}
