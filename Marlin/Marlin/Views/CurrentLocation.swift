//
//  CurrentLocation.swift
//  Marlin
//
//  Created by Daniel Barela on 10/14/22.
//

import SwiftUI

struct CurrentLocation: View {
    @EnvironmentObject var locationManager: LocationManager

    @AppStorage("showCurrentLocation") var showCurrentLocation: Bool = false

    var body: some View {
        if showCurrentLocation, let currentLocation = locationManager.lastLocation {
            HStack {
                Spacer()
                Text("Current Location: \(currentLocation.coordinate.format())")
                    .font(Font.overline)
                    .foregroundColor(Color.onPrimaryColor)
                    .opacity(0.87)
                    .padding(8)
                Spacer()
            }
            .accessibilityElement()
            .accessibilityLabel("Current Location")
            .background(Color.primaryColor)
            .onTapGesture {
                UIPasteboard.general.string = "\(currentLocation.coordinate.format())"
                NotificationCenter.default.post(
                    name: .SnackbarNotification,
                    object: SnackbarNotification(
                        snackbarModel: SnackbarModel(message: "Location \(currentLocation.coordinate.format()) copied to clipboard"))
                )
            }
        }
    }
}
