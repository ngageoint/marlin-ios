//
//  DFRSSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 8/30/22.
//

import SwiftUI

struct DFRSSummaryView: View {
    
    var dfrs: DFRS
    var showMoreDetails: Bool = false
    var showSectionHeader: Bool = false
    
    init(dfrs: DFRS, showMoreDetails: Bool = false, showSectionHeader: Bool = false) {
        self.dfrs = dfrs
        self.showMoreDetails = showMoreDetails
        self.showSectionHeader = showSectionHeader
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(dfrs.stationNumber ?? "")")
                .font(Font.overline)
                .foregroundColor(Color.onSurfaceColor)
                .opacity(0.45)
            Text("\(dfrs.stationName ?? "")")
                .font(Font.headline6)
                .foregroundColor(Color.onSurfaceColor)
                .opacity(0.87)
            if showMoreDetails {
                Text(dfrs.areaName ?? "")
                    .font(Font.body2)
                    .foregroundColor(Color.onSurfaceColor)
                    .opacity(0.6)
            }
            if showSectionHeader {
                Text(dfrs.areaName ?? "")
                    .font(Font.body2)
                    .foregroundColor(Color.onSurfaceColor)
                    .opacity(0.6)
            }
            if let notes = dfrs.notes, notes != "" {
                Text(notes)
                    .font(Font.body2)
                    .foregroundColor(Color.onSurfaceColor)
                    .opacity(0.6)
            }
            if let remarks = dfrs.remarks, remarks != "" {
                Text(remarks)
                    .font(Font.body2)
                    .foregroundColor(Color.onSurfaceColor)
                    .opacity(0.6)
            }
            DFRSActionBar(dfrs: dfrs, showMoreDetailsButton: showMoreDetails, showFocusButton: !showMoreDetails)
        }
    }
}
