//
//  RadioBeaconActions.swift
//  Marlin
//
//  Created by Daniel Barela on 2/7/24.
//

import Foundation
import SwiftUI
import CoreLocation

enum RadioBeaconActions {
    class Zoom: Action {
        var latLng: CLLocationCoordinate2D
        var itemKey: String
        init(latLng: CLLocationCoordinate2D, itemKey: String) {
            self.latLng = latLng
            self.itemKey = itemKey
        }
        func action() {
            NotificationCenter.default.post(name: .TabRequestFocus, object: nil)
            let notification = MapItemsTappedNotification(itemKeys: [DataSources.radioBeacon.key: [itemKey]])
            NotificationCenter.default.post(name: .MapItemsTapped, object: notification)
        }
    }

    class Tap: Action {
        var featureNumber: Int?
        var volumeNumber: String?
        @Binding var path: NavigationPath
        init(featureNumber: Int?, volumeNumber: String?, path: Binding<NavigationPath>) {
            self.featureNumber = featureNumber
            self.volumeNumber = volumeNumber
            self._path = path
        }
        func action() {
            guard let featureNumber = featureNumber, let volumeNumber = volumeNumber else { return }

            path.append(RadioBeaconRoute.detail(featureNumber: featureNumber, volumeNumber: volumeNumber))
        }
    }
}
