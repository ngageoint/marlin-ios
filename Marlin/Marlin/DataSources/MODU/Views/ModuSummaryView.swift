//
//  ModuSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/17/22.
//

import SwiftUI

struct ModuSummaryView: DataSourceSummaryView {
    var showSectionHeader: Bool = false
    
    var bookmark: Bookmark?
    
    var modu: Modu
    var showMoreDetails: Bool = false
    var showTitle: Bool = true
    
    init(modu: Modu, showMoreDetails: Bool = false, showTitle: Bool = true) {
        self.modu = modu
        self.showMoreDetails = showMoreDetails
        self.showTitle = showTitle
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(modu.dateString ?? "")
                .overline()
            if showTitle {
                Text("\(modu.name ?? "")")
                    .primary()
            }
            Text("\(modu.rigStatus ?? "")")
                .lineLimit(1)
                .secondary()
            Text("\(modu.specialStatus ?? "")")
                .lineLimit(1)
                .secondary()
            BookmarkNotes(notes: bookmark?.notes)

            DataSourceActionBar(data: modu, showMoreDetailsButton: showMoreDetails, showFocusButton: !showMoreDetails)
        }
    }
}
