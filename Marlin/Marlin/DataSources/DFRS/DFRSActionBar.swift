//
//  DFRSActionBar.swift
//  Marlin
//
//  Created by Daniel Barela on 8/30/22.
//

import SwiftUI
import MapKit

struct DFRSActionBar: View {
    var dfrs: DFRS
    var showMoreDetailsButton = false
    var showFocusButton = true
    
    var body: some View {
        HStack(spacing:0) {
            if showMoreDetailsButton {
                Button(action: {
                    NotificationCenter.default.post(name: .ViewDataSource, object: self.dfrs)
                }) {
                    Text("More Details")
                }
            } else if CLLocationCoordinate2DIsValid(dfrs.coordinate) {
                let coordinateButtonTitle = dfrs.coordinate.toDisplay()
                
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
                    let activityVC = UIActivityViewController(activityItems: [dfrs.description], applicationActivities: nil)
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
                        NotificationCenter.default.post(name: .FocusDFRS, object: self.dfrs)
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
