//
//  DFRSSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 8/30/22.
//

import SwiftUI

struct DFRSSummaryView: DataSourceSummaryView {
    var showBookmarkNotes: Bool = false

    var dfrs: DFRS
    var showMoreDetails: Bool = false
    var showSectionHeader: Bool = false
    var showTitle: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(dfrs.stationNumber ?? "")")
                .overline()
            if showTitle {
                Text("\(dfrs.stationName ?? "")")
                    .primary()
            }
            if showMoreDetails {
                Text(dfrs.areaName ?? "")
                    .secondary()
            }
            if showSectionHeader {
                Text(dfrs.areaName ?? "")
                    .secondary()
            }
            if let notes = dfrs.notes, notes != "" {
                Text(notes)
                    .primary()
            }
            if let remarks = dfrs.remarks, remarks != "" {
                Text(remarks)
                    .secondary()
            }
            DataSourceActionBar(data: dfrs, showMoreDetailsButton: showMoreDetails, showFocusButton: !showMoreDetails)
        }
    }
}
