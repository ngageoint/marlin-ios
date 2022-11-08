//
//  LightSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 7/6/22.
//

import SwiftUI

struct LightSummaryView: View {
    
    var light: Light
    var showMoreDetails: Bool = false
    
    init(light: Light, showMoreDetails: Bool = false) {
        self.light = light
        self.showMoreDetails = showMoreDetails
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(light.featureNumber ?? "") \(light.internationalFeature ?? "") \(light.volumeNumber ?? "")")
                .overline()
            Text("\(light.name ?? "")")
                .primary()
            if showMoreDetails {
                Text(light.sectionHeader ?? "")
                    .secondary()
            }
            Text(light.structure ?? "")
                .secondary()
            LightActionBar(light: light, showMoreDetailsButton: showMoreDetails, showFocusButton: !showMoreDetails)
        }
    }
}
