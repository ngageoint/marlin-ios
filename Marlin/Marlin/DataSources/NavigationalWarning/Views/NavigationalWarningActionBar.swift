//
//  NavigationalWarningActionBar.swift
//  Marlin
//
//  Created by Daniel Barela on 7/3/22.
//

import SwiftUI
import MapKit

struct NavigationalWarningActionBar: View {    
    var navigationalWarning: NavigationalWarning
    var showMoreDetails: Bool
    var mapName: String?

    var body: some View {
        HStack(spacing:0) {
            if showMoreDetails {
                Button(action: {
                    NotificationCenter.default.post(name: .ViewDataSource, object: ViewDataSource(mapName: mapName, dataSource: self.navigationalWarning))
                }) {
                    Text("More Details")
                        .foregroundColor(Color.primaryColorVariant)
                }
            }
            Spacer()
            ShareButton(shareText: navigationalWarning.description)
            if !showMoreDetails {
                FocusButton(data: navigationalWarning)
            }
        }
        .buttonStyle(MaterialButtonStyle())
    }
}
