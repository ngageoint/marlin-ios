//
//  RadioBeaconActionBar.swift
//  Marlin
//
//  Created by Daniel Barela on 8/25/22.
//

import SwiftUI

struct RadioBeaconActionBar: View {
    var radioBeacon: RadioBeacon
    var showMoreDetailsButton = false
    var showFocusButton = true
    
    var body: some View {
        HStack(spacing:0) {
            if showMoreDetailsButton {
                Button(action: {
                    NotificationCenter.default.post(name: .ViewDataSource, object: ViewDataSource(dataSource: radioBeacon))
                }) {
                    Text("More Details")
                }
                .accessibilityElement()
                .accessibilityLabel("More Details")
            } else {
                CoordinateButton(coordinate: radioBeacon.coordinate)
            }
            
            Spacer()
            Group {
                Button(action: {
                    let activityVC = UIActivityViewController(activityItems: [radioBeacon.description], applicationActivities: nil)
                    UIApplication.shared.keyWindow?.rootViewController?.present(activityVC, animated: true, completion: nil)
                }) {
                    Label(
                        title: {},
                        icon: { Image(systemName: "square.and.arrow.up")
                                .renderingMode(.template)
                                .foregroundColor(Color.primaryColorVariant)
                        })
                }
                .accessibilityElement()
                .accessibilityLabel("share")
                if showFocusButton {
                    Button(action: {
                        NotificationCenter.default.post(name: .TabRequestFocus, object: nil)
                        let notification = MapItemsTappedNotification(items: [self.radioBeacon])
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
