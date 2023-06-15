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
    var showTitle: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(light.featureNumber ?? "") \(light.internationalFeature ?? "") \(light.volumeNumber ?? "")")
                .overline()
            if showTitle {
                Text("\(light.name ?? "")")
                    .primary()
            }
            if showMoreDetails {
                Text(light.sectionHeader ?? "")
                    .secondary()
            }
            if let structure = light.structure?.trimmingCharacters(in: .whitespacesAndNewlines) {
                Text(structure)
                    .secondary()
            }
            DataSourceActionBar(data: light, showMoreDetailsButton: showMoreDetails, showFocusButton: !showMoreDetails)
        }
    }
}
