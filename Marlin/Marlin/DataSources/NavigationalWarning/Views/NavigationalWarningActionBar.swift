//
//  NavigationalWarningActionBar.swift
//  Marlin
//
//  Created by Daniel Barela on 7/3/22.
//

import SwiftUI
import MapKit

struct NavigationalWarningActionBar: View {
    @EnvironmentObject var navState: NavState
    
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
            Button(action: {
                let activityVC = UIActivityViewController(activityItems: [navigationalWarning.description], applicationActivities: nil)
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
            if !showMoreDetails {
                Button(action: {
                    NotificationCenter.default.post(name: .TabRequestFocus, object: navState.navGroupName)
                    let notification = MapItemsTappedNotification(items: [self.navigationalWarning], mapName: mapName, zoom: true)
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
        }
        .buttonStyle(MaterialButtonStyle())
    }
}
