//
//  RadioBeaconSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 8/25/22.
//

import SwiftUI

struct RadioBeaconSummaryView: DataSourceSummaryView {
    @EnvironmentObject var bookmarkRepository: BookmarkRepositoryManager
    @EnvironmentObject var router: MarlinRouter

    var showTitle: Bool = false
    
    var showBookmarkNotes: Bool = false

    var radioBeacon: RadioBeaconListModel
    var showMoreDetails: Bool = false
    var showSectionHeader: Bool = false

    @StateObject var bookmarkViewModel: BookmarkViewModel = BookmarkViewModel()

    init(radioBeacon: RadioBeaconListModel, showMoreDetails: Bool = false, showSectionHeader: Bool = false) {
        self.radioBeacon = radioBeacon
        self.showMoreDetails = showMoreDetails
        self.showSectionHeader = showSectionHeader
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(radioBeacon.featureNumber ?? 0) \(radioBeacon.volumeNumber ?? "")")
                .overline()
            Text("\(radioBeacon.name ?? "")")
                .primary()
            if showMoreDetails || showSectionHeader {
                Text(radioBeacon.sectionHeader ?? "")
                    .secondary()
            }
            if let morseCode = radioBeacon.morseCode {
                Text(radioBeacon.morseLetter)
                    .primary()
                MorseCode(code: morseCode)
            }
            if let expandedCharacteristicWithoutCode = radioBeacon.expandedCharacteristicWithoutCode {
                Text(expandedCharacteristicWithoutCode)
                .secondary()
            }
            if let stationRemark = radioBeacon.stationRemark {
                Text(stationRemark)
                    .secondary()
            }
            bookmarkNotesView(radioBeacon)
            DataSourceActions(
                moreDetails: showMoreDetails ? RadioBeaconActions.Tap(
                    featureNumber: radioBeacon.featureNumber,
                    volumeNumber: radioBeacon.volumeNumber,
                    path: $router.path
                ) : nil,
                location: !showMoreDetails ? Actions.Location(latLng: radioBeacon.coordinate) : nil,
                zoom: !showMoreDetails ? RadioBeaconActions.Zoom(latLng: radioBeacon.coordinate, itemKey: radioBeacon.id) : nil,
                bookmark: radioBeacon.canBookmark ? Actions.Bookmark(
                    itemKey: radioBeacon.id,
                    bookmarkViewModel: bookmarkViewModel
                ) : nil,
                share: radioBeacon.itemTitle
            )
        }
    }
}
