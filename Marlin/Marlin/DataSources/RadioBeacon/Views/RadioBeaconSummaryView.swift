//
//  RadioBeaconSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 8/25/22.
//

import SwiftUI

struct RadioBeaconSummaryView: DataSourceSummaryView {
    var showTitle: Bool = false
    
    var bookmark: Bookmark?
    
    var radioBeacon: RadioBeacon
    var showMoreDetails: Bool = false
    var showSectionHeader: Bool = false
    
    init(radioBeacon: RadioBeacon, showMoreDetails: Bool = false, showSectionHeader: Bool = false) {
        self.radioBeacon = radioBeacon
        self.showMoreDetails = showMoreDetails
        self.showSectionHeader = showSectionHeader
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(radioBeacon.featureNumber) \(radioBeacon.volumeNumber ?? "")")
                .overline()
            Text("\(radioBeacon.name ?? "")")
                .primary()
            if showMoreDetails || showSectionHeader {
                Text(radioBeacon.sectionHeader ?? "")
                    .secondary()
            }
            if let morseCode = radioBeacon.morseCode {
                Text(radioBeacon.morseLetter)
                    .primary()
                MorseCode(code: morseCode)
            }
            if let expandedCharacteristicWithoutCode = radioBeacon.expandedCharacteristicWithoutCode {
                Text(expandedCharacteristicWithoutCode)
                .secondary()
            }
            if let stationRemark = radioBeacon.stationRemark {
                Text(stationRemark)
                    .secondary()
            }
            BookmarkNotes(notes: bookmark?.notes)

            DataSourceActionBar(data: radioBeacon, showMoreDetailsButton: showMoreDetails, showFocusButton: !showMoreDetails)
        }
    }
}
