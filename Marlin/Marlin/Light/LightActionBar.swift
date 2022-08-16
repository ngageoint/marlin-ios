//
//  LightActionBar.swift
//  Marlin
//
//  Created by Daniel Barela on 7/7/22.
//

import SwiftUI
import MaterialComponents

struct LightActionBar: View {
    var light: Light
    var showMoreDetailsButton = false
    var showFocusButton = true
    
    var body: some View {
        HStack(spacing:0) {
            if showMoreDetailsButton {
                Button(action: {
                    NotificationCenter.default.post(name: .ViewDataSource, object: self.light)
                }) {
                    Text("More Details")
                }
            } else {
                let coordinateButtonTitle = light.coordinate.toDisplay()
                
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
                    let activityVC = UIActivityViewController(activityItems: [light.description], applicationActivities: nil)
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
                        NotificationCenter.default.post(name: .FocusLight, object: self.light)
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

//struct LightActionBar_Previews: PreviewProvider {
//    static var previews: some View {
//        LightActionBar()
//    }
//}
