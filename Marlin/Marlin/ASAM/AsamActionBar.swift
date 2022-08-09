//
//  AsamActionBar.swift
//  Marlin
//
//  Created by Daniel Barela on 7/3/22.
//

import SwiftUI
import MapKit
import MaterialComponents

struct AsamActionBar: View {
    var asam: Asam
    var showMoreDetailsButton = false
    var showFocusButton = true
    
    var body: some View {
        HStack(spacing:0) {
            if showMoreDetailsButton {
                Button(action: {
                    NotificationCenter.default.post(name: .ViewDataSource, object: self.asam)
                }) {
                    Text("More Details")
                        .foregroundColor(Color.primaryColorVariant)
                }
            } else {
                let coordinateButtonTitle = CLLocationCoordinate2D(latitude: asam.latitude?.doubleValue ?? 0.0, longitude: asam.longitude?.doubleValue ?? 0.0).toDisplay()
                
                Button(action: {
                    UIPasteboard.general.string = coordinateButtonTitle
                    MDCSnackbarManager.default.show(MDCSnackbarMessage(text: "Location \(coordinateButtonTitle) copied to clipboard"))
                }) {
                    Text(coordinateButtonTitle)
                        .foregroundColor(Color.primaryColorVariant)
                }
            }
            
            Spacer()
            Group {
                Button(action: {
                    let activityVC = UIActivityViewController(activityItems: [asam.description], applicationActivities: nil)
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
                        NotificationCenter.default.post(name: .FocusAsam, object: self.asam)
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

//struct AsamActionBar_Previews: PreviewProvider {
//    static var previews: some View {
//        AsamActionBar()
//    }
//}
