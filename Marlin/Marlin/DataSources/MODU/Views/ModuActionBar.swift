//
//  ModuActionBar.swift
//  Marlin
//
//  Created by Daniel Barela on 7/3/22.
//

import SwiftUI
import MapKit

struct ModuActionBar: View {
    var modu: Modu
    var showMoreDetailsButton = false
    var showFocusButton = true
    
    var body: some View {
        HStack(spacing:0) {
            if showMoreDetailsButton {
                Button(action: {
                    NotificationCenter.default.post(name: .ViewDataSource, object: ViewDataSource(dataSource: modu))
                }) {
                    Text("More Details")
                        .foregroundColor(Color.primaryColorVariant)
                }
                .accessibilityElement()
                .accessibilityLabel("More Details")
            } else {
                CoordinateButton(coordinate: modu.coordinate)
            }
            
            Spacer()
            Group {
                Button(action: {
                    let activityVC = UIActivityViewController(activityItems: [modu.description], applicationActivities: nil)
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
                        let notification = MapItemsTappedNotification(items: [self.modu])
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
