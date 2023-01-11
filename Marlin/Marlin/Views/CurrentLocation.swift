//
//  CurrentLocation.swift
//  Marlin
//
//  Created by Daniel Barela on 10/14/22.
//

import SwiftUI

struct CurrentLocation: View {
    @ObservedObject var locationManager: LocationManager = LocationManager.shared

    @AppStorage("showCurrentLocation") var showCurrentLocation: Bool = false

    var body: some View {
        if showCurrentLocation, let currentLocation = locationManager.lastLocation {
            HStack {
                Spacer()
                Text("Current Location: \(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)")
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
                UIPasteboard.general.string = "\(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)"
                NotificationCenter.default.post(
                    name: .SnackbarNotification,
                    object: SnackbarNotification(
                        snackbarModel: SnackbarModel(message: "Location \(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude) copied to clipboard"))
                )
            }
        }
    }
}
