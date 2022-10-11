//
//  DifferentialGPSStationActionBar.swift
//  Marlin
//
//  Created by Daniel Barela on 8/30/22.
//

import SwiftUI

struct DifferentialGPSStationActionBar: View {
    var differentialGPSStation: DifferentialGPSStation
    var showMoreDetailsButton = false
    var showFocusButton = true
    
    var body: some View {
        HStack(spacing:0) {
            if showMoreDetailsButton {
                Button(action: {
                    NotificationCenter.default.post(name: .ViewDataSource, object: self.differentialGPSStation)
                }) {
                    Text("More Details")
                }
            } else {
                let coordinateButtonTitle = differentialGPSStation.coordinate.toDisplay()
                
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
            }
            
            Spacer()
            Group {
                Button(action: {
                    let activityVC = UIActivityViewController(activityItems: [differentialGPSStation.description], applicationActivities: nil)
                    UIApplication.shared.keyWindow?.rootViewController?.present(activityVC, animated: true, completion: nil)
                }) {
                    Label(
                        title: {},
                        icon: { Image(systemName: "square.and.arrow.up")
                                .renderingMode(.template)
                                .foregroundColor(Color.primaryColorVariant)
                        })
                }
                if showFocusButton {
                    Button(action: {
                        NotificationCenter.default.post(name: .MapRequestFocus, object: nil)
                        let notification = MapItemsTappedNotification(items: [self.differentialGPSStation])
                        NotificationCenter.default.post(name: .MapItemsTapped, object: notification)
                    }) {
                        Label(
                            title: {},
                            icon: { Image(systemName: "scope")
                                    .renderingMode(.template)
                                    .foregroundColor(Color.primaryColorVariant)
                            })
                    }
                }
            }.padding(.trailing, -8)
        }
        .buttonStyle(MaterialButtonStyle())
    }
}