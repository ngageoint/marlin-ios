//
//  DifferentialGPSStationSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 8/30/22.
//

import SwiftUI

struct DifferentialGPSStationSummaryView: View {
    
    var differentialGPSStation: DifferentialGPSStation
    var showMoreDetails: Bool = false
    var showSectionHeader: Bool = false
    
    init(differentialGPSStation: DifferentialGPSStation, showMoreDetails: Bool = false, showSectionHeader: Bool = false) {
        self.differentialGPSStation = differentialGPSStation
        self.showMoreDetails = showMoreDetails
        self.showSectionHeader = showSectionHeader
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(differentialGPSStation.featureNumber) \(differentialGPSStation.volumeNumber ?? "")")
                .font(Font.overline)
                .foregroundColor(Color.onSurfaceColor)
                .opacity(0.45)
            Text("\(differentialGPSStation.name ?? "")")
                .font(Font.headline6)
                .foregroundColor(Color.onSurfaceColor)
                .opacity(0.87)
            if showMoreDetails {
                Text(differentialGPSStation.geopoliticalHeading ?? "")
                    .font(Font.body2)
                    .foregroundColor(Color.onSurfaceColor)
                    .opacity(0.6)
            }
            if showSectionHeader {
                Text(differentialGPSStation.sectionHeader ?? "")
                    .font(Font.body2)
                    .foregroundColor(Color.onSurfaceColor)
                    .opacity(0.6)
            }
            if let stationID = differentialGPSStation.stationID, stationID != "" {
                Text(stationID)
                    .font(Font.body2)
                    .foregroundColor(Color.onSurfaceColor)
                    .opacity(0.6)
            }
            if let remarks = differentialGPSStation.remarks, remarks != "" {
                Text(remarks)
                    .font(Font.body2)
                    .foregroundColor(Color.onSurfaceColor)
                    .opacity(0.6)
            }
            DifferentialGPSStationActionBar(differentialGPSStation: differentialGPSStation, showMoreDetailsButton: showMoreDetails, showFocusButton: !showMoreDetails)
        }
    }
}
