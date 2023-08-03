//
//  AsamSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/15/22.
//

import SwiftUI

struct AsamSummaryView: DataSourceSummaryView {
    var showSectionHeader: Bool = false
    
    var bookmark: Bookmark?
        
    var asam: Asam
    var showMoreDetails: Bool = false
    var showTitle: Bool = true
    
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
            BookmarkNotes(notes: bookmark?.notes)
            DataSourceActionBar(data: asam, showMoreDetailsButton: showMoreDetails, showFocusButton: !showMoreDetails)
        }
    }
}
