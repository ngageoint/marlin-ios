//
//  NavigationalWarningSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/23/22.
//

import SwiftUI
import MapKit

struct NavigationalWarningSummaryView: View {
    var navigationalWarning: NavigationalWarning
    var showMoreDetails: Bool
    var mapName: String?
    var showTitle: Bool = true
    
    init(navigationalWarning: NavigationalWarning, showMoreDetails: Bool, mapName: String? = nil, showTitle: Bool = true) {
        self.navigationalWarning = navigationalWarning
        self.showMoreDetails = showMoreDetails
        self.mapName = mapName
        self.showTitle = showTitle
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(navigationalWarning.dateString ?? "")
                .overline()
            if showTitle {
                Text("\(navigationalWarning.navAreaName) \(String(navigationalWarning.msgNumber))/\(String(navigationalWarning.msgYear)) (\(navigationalWarning.subregion ?? ""))")
                    .primary()
            }
            Text("\(navigationalWarning.text ?? "")")
                .multilineTextAlignment(.leading)
                .lineLimit(8)
                .secondary()
            NavigationalWarningActionBar(navigationalWarning: navigationalWarning, showMoreDetails: showMoreDetails, mapName: mapName)
        }
    }
}
