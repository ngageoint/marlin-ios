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
                .overline()
            Text("\(differentialGPSStation.name ?? "")")
                .primary()
            if showMoreDetails {
                Text(differentialGPSStation.geopoliticalHeading ?? "")
                    .secondary()
            }
            if showSectionHeader {
                Text(differentialGPSStation.sectionHeader ?? "")
                    .secondary()
            }
            if let stationID = differentialGPSStation.stationID, stationID != "" {
                Text(stationID)
                    .secondary()
            }
            if let remarks = differentialGPSStation.remarks, remarks != "" {
                Text(remarks)
                    .secondary()
            }
            DifferentialGPSStationActionBar(differentialGPSStation: differentialGPSStation, showMoreDetailsButton: showMoreDetails, showFocusButton: !showMoreDetails)
        }
    }
}
