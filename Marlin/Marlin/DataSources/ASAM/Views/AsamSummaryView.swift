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
    
    init(asam: Asam, showMoreDetails: Bool = false) {
        self.asam = asam
        self.showMoreDetails = showMoreDetails
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(asam.dateString ?? "")
                .overline()
            Text("\(asam.hostility ?? "")\(asam.hostility != nil ? ": " : "")\(asam.victim ?? "")")
                .primary()
            Text(asam.asamDescription ?? "")
                .lineLimit(8)
                .secondary()
            AsamActionBar(asam: asam, showMoreDetailsButton: showMoreDetails, showFocusButton: !showMoreDetails)
        }
    }
}
