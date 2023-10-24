//
//  ModuSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/17/22.
//

import SwiftUI

struct ModuSummaryView: DataSourceSummaryView {
    var showSectionHeader: Bool = false
    
    var showBookmarkNotes: Bool = false

    var modu: ModuModel
    var showMoreDetails: Bool = false
    var showTitle: Bool = true
    
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
            bookmarkNotesView(modu)

            DataSourceActionBar(data: modu, showMoreDetailsButton: showMoreDetails, showFocusButton: !showMoreDetails)
        }
    }
}
