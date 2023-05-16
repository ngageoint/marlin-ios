//
//  NavigationalWarningSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/23/22.
//

import SwiftUI

struct NavigationalWarningSummaryView: View {
    var navigationalWarning: NavigationalWarning
    var showMoreDetails: Bool
    
    init(navigationalWarning: NavigationalWarning, showMoreDetails: Bool) {
        self.navigationalWarning = navigationalWarning
        self.showMoreDetails = showMoreDetails
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(navigationalWarning.dateString ?? "")
                .overline()
            Text("\(navigationalWarning.navAreaName) \(String(navigationalWarning.msgNumber))/\(String(navigationalWarning.msgYear)) (\(navigationalWarning.subregion ?? ""))")
                .primary()
            Text("\(navigationalWarning.text ?? "")")
                .multilineTextAlignment(.leading)
                .lineLimit(8)
                .secondary()
            NavigationalWarningActionBar(navigationalWarning: navigationalWarning, showMoreDetails: showMoreDetails)
        }
    }
}
