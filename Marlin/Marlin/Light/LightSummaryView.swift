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
                .font(Font.overline)
                .foregroundColor(Color.onSurfaceColor)
                .opacity(0.45)
            Text("\(light.name ?? "")")
                .font(Font.headline6)
                .foregroundColor(Color.onSurfaceColor)
                .opacity(0.87)
            if showMoreDetails {
                Text(light.sectionHeader ?? "")
                    .font(Font.body2)
                    .foregroundColor(Color.onSurfaceColor)
                    .opacity(0.6)
            }
            Text(light.structure ?? "")
                .font(Font.body2)
                .foregroundColor(Color.onSurfaceColor)
                .opacity(0.6)
            LightActionBar(light: light, showMoreDetailsButton: showMoreDetails, showFocusButton: !showMoreDetails)
        }
    }
}

struct LightSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let light = try? context.fetchFirst(Light.self)
        LightSummaryView(light: light!)
    }
}
