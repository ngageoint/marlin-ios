//
//  RadioBeaconSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 8/25/22.
//

import SwiftUI

struct RadioBeaconSummaryView: View {
    
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
            Text(radioBeacon.expandedCharacteristicWithoutCode ?? "")
                .secondary()
            Text(radioBeacon.stationRemark ?? "")
                .secondary()
            RadioBeaconActionBar(radioBeacon: radioBeacon, showMoreDetailsButton: showMoreDetails, showFocusButton: !showMoreDetails)
        }
    }
}

struct RadioBeaconSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let radioBeacon = try? context.fetchFirst(RadioBeacon.self)
        RadioBeaconSummaryView(radioBeacon: radioBeacon!)
    }
}