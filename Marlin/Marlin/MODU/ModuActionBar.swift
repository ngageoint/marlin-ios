//
//  ModuActionBar.swift
//  Marlin
//
//  Created by Daniel Barela on 7/3/22.
//

import SwiftUI
import MapKit
import MaterialComponents

struct ModuActionBar: View {
    @EnvironmentObject var scheme: MarlinScheme
    var modu: Modu
    var showMoreDetailsButton = false
    var showFocusButton = true
    
    var body: some View {
        HStack(spacing:0) {
            if showMoreDetailsButton {
                Button(action: {
                    NotificationCenter.default.post(name: .ViewDataSource, object: self.modu)
                }) {
                    Text("More Details")
                        .foregroundColor(Color(scheme.containerScheme.colorScheme.primaryColorVariant))
                }
            } else {
                let coordinateButtonTitle = CLLocationCoordinate2D(latitude: modu.latitude?.doubleValue ?? 0.0, longitude: modu.longitude?.doubleValue ?? 0.0).toDisplay()
                
                Button(action: {
                    UIPasteboard.general.string = coordinateButtonTitle
                    MDCSnackbarManager.default.show(MDCSnackbarMessage(text: "Location \(coordinateButtonTitle) copied to clipboard"))
                }) {
                    Text(coordinateButtonTitle)
                        .foregroundColor(Color(scheme.containerScheme.colorScheme.primaryColorVariant))
                }
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
                                .foregroundColor(Color(scheme.containerScheme.colorScheme.primaryColorVariant))
                        })
                }
                if showFocusButton {
                    Button(action: {
                        NotificationCenter.default.post(name: .MapRequestFocus, object: nil)
                        NotificationCenter.default.post(name: .FocusModu, object: self.modu)
                    }) {
                        Label(
                            title: {},
                            icon: { Image(systemName: "scope")
                                    .renderingMode(.template)
                                    .foregroundColor(Color(scheme.containerScheme.colorScheme.primaryColorVariant))
                            })
                    }
                }
            }.padding(.trailing, -8)
        }
        .buttonStyle(MaterialButtonStyle())
    }
}

//struct ModuActionBar_Previews: PreviewProvider {
//    static var previews: some View {
//        ModuActionBar()
//    }
//}
