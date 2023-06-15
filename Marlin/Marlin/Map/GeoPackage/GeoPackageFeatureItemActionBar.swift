//
//  GeoPackageFeatureItemActionBar.swift
//  Marlin
//
//  Created by Daniel Barela on 4/11/23.
//

import SwiftUI

struct GeoPackageFeatureItemActionBar: View {
    var featureItem: GeoPackageFeatureItem
    var showMoreDetailsButton = false
    var showFocusButton = true
    
    var body: some View {
        HStack(spacing:0) {
            if showMoreDetailsButton {
                Button(action: {
                    NotificationCenter.default.post(name: .ViewDataSource, object: ViewDataSource(dataSource: featureItem))
                }) {
                    Text("More Details")
                        .foregroundColor(Color.primaryColorVariant)
                }
            } else {
                CoordinateButton(coordinate: featureItem.coordinate)
            }
            
            Spacer()
            Group {
                if showFocusButton {
                    Button(action: {
                        NotificationCenter.default.post(name: .TabRequestFocus, object: nil)
                        let notification = MapItemsTappedNotification(items: [featureItem])
                        NotificationCenter.default.post(name: .MapItemsTapped, object: notification)
                    }) {
                        Label(
                            title: {},
                            icon: { Image(systemName: "scope")
                                    .renderingMode(.template)
                                    .foregroundColor(Color.primaryColorVariant)
                            })
                    }
                    .accessibilityElement()
                    .accessibilityLabel("focus")
                }
            }.padding(.trailing, -8)
        }
        .buttonStyle(MaterialButtonStyle())
    }
}
