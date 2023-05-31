//
//  ModuSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/17/22.
//

import SwiftUI

struct ModuSummaryView: View {
        
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
            Text("Rig Status: \(modu.rigStatus ?? "")")
                .lineLimit(1)
                .secondary()
            Text("Special Status: \(modu.specialStatus ?? "")")
                .lineLimit(1)
                .secondary()
            ModuActionBar(modu: modu, showMoreDetailsButton: showMoreDetails, showFocusButton: !showMoreDetails)
        }
    }
}
