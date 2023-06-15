//
//  AsamSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/15/22.
//

import SwiftUI

struct AsamSummaryView: View {
        
    var asam: Asam
    var showMoreDetails: Bool = false
    var showTitle: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(asam.dateString ?? "")
                .overline()
            if showTitle {
                Text("\(asam.hostility ?? "")\(asam.hostility != nil && asam.victim != nil ? ": " : "")\(asam.victim ?? "")")
                    .primary()
            }
            Text(asam.asamDescription ?? "")
                .lineLimit(8)
                .secondary()
            DataSourceActionBar(data: asam, showMoreDetailsButton: showMoreDetails, showFocusButton: !showMoreDetails)
        }
    }
}
