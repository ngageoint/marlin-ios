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
                    NotificationCenter.default.post(name: .ViewDataSource, object: self.featureItem)
                }) {
                    Text("More Details")
                        .foregroundColor(Color.primaryColorVariant)
                }
            } else if let coordinate = featureItem.coordinate {
                let coordinateButtonTitle = coordinate.toDisplay()
                
                Button(action: {
                    UIPasteboard.general.string = coordinateButtonTitle
                    NotificationCenter.default.post(name: .SnackbarNotification,
                                                    object: SnackbarNotification(snackbarModel:
                                                                                    SnackbarModel(message: "Location \(coordinateButtonTitle) copied to clipboard"))
                    )
                }) {
                    Text(coordinateButtonTitle)
                        .foregroundColor(Color.primaryColorVariant)
                }
                .accessibilityLabel("Location")
            }
            
            Spacer()
            Group {
                if showFocusButton {
                    Button(action: {
                        NotificationCenter.default.post(name: .MapRequestFocus, object: nil)
                        let notification = MapItemsTappedNotification(items: [self.featureItem])
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
