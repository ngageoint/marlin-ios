//
//  DifferentialGPSStationActions.swift
//  Marlin
//
//  Created by Daniel Barela on 2/8/24.
//

import Foundation
import MapKit
import SwiftUI

enum DifferentialGPSStationActions {
    class Zoom: Action {
        var latLng: CLLocationCoordinate2D
        var itemKey: String
        init(latLng: CLLocationCoordinate2D, itemKey: String) {
            self.latLng = latLng
            self.itemKey = itemKey
        }
        func action() {
            NotificationCenter.default.post(name: .TabRequestFocus, object: nil)
            let notification = MapItemsTappedNotification(itemKeys: [DataSources.dgps.key: [itemKey]])
            NotificationCenter.default.post(name: .MapItemsTapped, object: notification)
        }
    }

    class Tap: Action {
        let featureNumber: Int?
        let volumeNumber: String?
        @Binding var path: NavigationPath
        init(featureNumber: Int?, volumeNumber: String?, path: Binding<NavigationPath>) {
            self.featureNumber = featureNumber
            self.volumeNumber = volumeNumber
            self._path = path
        }
        func action() {
            guard let featureNumber = featureNumber, let volumeNumber = volumeNumber else { return }

            path.append(DifferentialGPSStationRoute.detail(featureNumber: featureNumber, volumeNumber: volumeNumber))
        }
    }
}
