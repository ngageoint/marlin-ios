//
//  LatitudeLongitudeButton.swift
//  Marlin
//
//  Created by Daniel Barela on 6/16/22.
//

import SwiftUI
import MapKit
import MaterialComponents

struct LatitudeLongitudeButton: View {
    var latitude: NSDecimalNumber
    var longitude: NSDecimalNumber
    var coordinate: CLLocationCoordinate2D
    var title: String
    
    init(latitude: NSDecimalNumber, longitude: NSDecimalNumber) {
        self.latitude = latitude
        self.longitude = longitude
        coordinate = CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude: longitude.doubleValue)
        title = coordinate.toDisplay()
    }
    
    var body: some View {
        MaterialButton(title: title) {
            UIPasteboard.general.string = title
            MDCSnackbarManager.default.show(MDCSnackbarMessage(text: "Location \(title) copied to clipboard"))
            print("button tapped")
        }
    }
}

struct LatitudeLongitudeButton_Previews: PreviewProvider {
    static var previews: some View {
        LatitudeLongitudeButton(latitude: 4, longitude: 5)
    }
}
