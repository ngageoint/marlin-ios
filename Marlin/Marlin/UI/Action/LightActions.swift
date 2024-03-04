//
//  LightActions.swift
//  Marlin
//
//  Created by Daniel Barela on 2/2/24.
//

import Foundation
import MapKit
import SwiftUI

enum LightActions {
    class Zoom: Action {
        var latLng: CLLocationCoordinate2D
        var itemKey: String
        init(latLng: CLLocationCoordinate2D, itemKey: String) {
            self.latLng = latLng
            self.itemKey = itemKey
        }
        func action() {
            NotificationCenter.default.post(name: .TabRequestFocus, object: nil)
            let notification = MapItemsTappedNotification(itemKeys: [DataSources.light.key: [itemKey]])
            NotificationCenter.default.post(name: .MapItemsTapped, object: notification)
        }
    }

    class Tap: Action {
        var volume: String?
        var featureNumber: String?

        @Binding var path: NavigationPath
        init(volume: String?, featureNumber: String?, path: Binding<NavigationPath>) {
            self.volume = volume
            self.featureNumber = featureNumber
            self._path = path
        }
        func action() {
            guard let volume = volume, let featureNumber = featureNumber else { return }

            path.append(LightRoute.detail(volumeNumber: volume, featureNumber: featureNumber))
        }
    }
}
