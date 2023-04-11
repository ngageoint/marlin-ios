//
//  GeoPackageFeatureItemSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 4/11/23.
//

import SwiftUI

struct GeoPackageFeatureItemSummaryView: View {
    var featureItem: GeoPackageFeatureItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let date = featureItem.dateString {
                Text(date)
                    .overline()
            }
            Text(featureItem.itemTitle)
                .primary()
            if let secondary = featureItem.secondaryTitle {
                Text(secondary)
                    .lineLimit(8)
                    .secondary()
            }
            Text(featureItem.layerName ?? "")
                .overline()
            GeoPackageFeatureItemActionBar(featureItem: featureItem, showMoreDetailsButton: true, showFocusButton: false)
        }
    }
}
