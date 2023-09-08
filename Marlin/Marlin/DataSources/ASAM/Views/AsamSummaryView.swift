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
        
    var asam: any AsamModel
    var showMoreDetails: Bool = false
    var showTitle: Bool = true
    var showBookmarkNotes: Bool = false
    
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
            if let asam = asam as? Bookmarkable {
                bookmarkNotesView(asam)
                
            }
            if let asam = asam as? DataSource {
                DataSourceActionBar(data: asam, showMoreDetailsButton: showMoreDetails, showFocusButton: !showMoreDetails)
            }
        }
    }
}
