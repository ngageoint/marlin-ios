//
//  CoordinateButton.swift
//  Marlin
//
//  Created by Daniel Barela on 6/15/23.
//

import SwiftUI
import MapKit

struct CoordinateButton: View {
    var action: Actions.Location
        
    @AppStorage("coordinateDisplay") var coordinateDisplay: CoordinateDisplayType = .latitudeLongitude

    var body: some View {
        if CLLocationCoordinate2DIsValid(action.latLng) {
            Button(action: action.action) {
                Text(coordinateDisplay.format(coordinate: action.latLng))
                    .foregroundColor(Color.primaryColorVariant)
            }
            .accessibilityElement()
            .accessibilityLabel("Location")
        }
    }
}
