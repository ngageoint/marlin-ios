//
//  LightSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 7/6/22.
//

import SwiftUI

struct LightSummaryView: View {
    @EnvironmentObject var scheme: MarlinScheme
    
    var light: Lights
    var showMoreDetails: Bool = false
    
    init(light: Lights, showMoreDetails: Bool = false) {
        self.light = light
        self.showMoreDetails = showMoreDetails
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(light.featureNumber ?? "") \(light.internationalFeature ?? "")")
                .font(Font(scheme.containerScheme.typographyScheme.overline))
                .foregroundColor(Color(scheme.containerScheme.colorScheme.onSurfaceColor))
                .opacity(0.45)
            Text("\(light.name ?? "")")
                .font(Font(scheme.containerScheme.typographyScheme.headline6))
                .foregroundColor(Color(scheme.containerScheme.colorScheme.onSurfaceColor))
                .opacity(0.87)
            if showMoreDetails {
                Text(light.sectionHeader ?? "")
                    .font(Font(scheme.containerScheme.typographyScheme.body2))
                    .foregroundColor(Color(scheme.containerScheme.colorScheme.onSurfaceColor))
                    .opacity(0.6)
            }
            Text(light.structure ?? "")
                .font(Font(scheme.containerScheme.typographyScheme.body2))
                .foregroundColor(Color(scheme.containerScheme.colorScheme.onSurfaceColor))
                .opacity(0.6)
            LightActionBar(light: light, showMoreDetailsButton: showMoreDetails, showFocusButton: !showMoreDetails)
        }
    }
}

struct LightSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let light = try? context.fetchFirst(Lights.self)
        LightSummaryView(light: light!)
    }
}
