//
//  CoordinateButton.swift
//  Marlin
//
//  Created by Daniel Barela on 6/15/23.
//

import SwiftUI
import MapKit

struct CoordinateButton: View {
    var coordinate: CLLocationCoordinate2D?

    @AppStorage("coordinateDisplay") var coordinateDisplay: CoordinateDisplayType = .latitudeLongitude
    
    var body: some View {
        if let coordinate = coordinate {
            Button(
                action: {
                    UIPasteboard.general.string = coordinateDisplay.format(coordinate: coordinate)
                    NotificationCenter.default.post(
                        name: .SnackbarNotification,
                        object: SnackbarNotification(
                            snackbarModel: SnackbarModel(
                                message:
                                    "Location \(coordinateDisplay.format(coordinate: coordinate)) copied to clipboard"
                            )
                        )
                    )
                },
                label: {
                    Text(coordinateDisplay.format(coordinate: coordinate))
                        .foregroundColor(Color.primaryColorVariant)
                }
            )
            .accessibilityElement()
            .accessibilityLabel("Location")
        } else {
            EmptyView()
        }
    }
}

struct CoordinateButton2: View {
    var action: Actions.Location
        
    @AppStorage("coordinateDisplay") var coordinateDisplay: CoordinateDisplayType = .latitudeLongitude

    var body: some View {
        Button(action: action.action) {
            Text(coordinateDisplay.format(coordinate: action.latLng))
                .foregroundColor(Color.primaryColorVariant)
        }
        .accessibilityElement()
        .accessibilityLabel("Location")
    }
}
