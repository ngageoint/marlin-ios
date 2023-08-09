//
//  DifferentialGPSStationSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 8/30/22.
//

import SwiftUI

struct DifferentialGPSStationSummaryView: DataSourceSummaryView {
    var showBookmarkNotes: Bool = false

    var differentialGPSStation: DifferentialGPSStation
    var showMoreDetails: Bool = false
    var showSectionHeader: Bool = false
    var showTitle: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(differentialGPSStation.featureNumber) \(differentialGPSStation.volumeNumber ?? "")")
                .overline()
            if showTitle {
                Text("\(differentialGPSStation.name ?? "")")
                    .primary()
            }
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
            bookmarkNotesView(differentialGPSStation)

            DataSourceActionBar(data: differentialGPSStation, showMoreDetailsButton: showMoreDetails, showFocusButton: !showMoreDetails)
        }
    }
}
