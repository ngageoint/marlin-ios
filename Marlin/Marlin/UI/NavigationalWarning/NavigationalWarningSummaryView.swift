//
//  NavigationalWarningSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/23/22.
//

import SwiftUI
import MapKit

struct NavigationalWarningSummaryView: DataSourceSummaryView {
    var showSectionHeader: Bool = false
    
    var showBookmarkNotes: Bool = false

    var navigationalWarning: NavigationalWarning
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
            bookmarkNotesView(navigationalWarning)
            NavigationalWarningActionBar(
                navigationalWarning: navigationalWarning,
                showMoreDetails: showMoreDetails,
                mapName: mapName
            )
        }
    }
}
