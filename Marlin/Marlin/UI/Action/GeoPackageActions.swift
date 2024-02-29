//
//  GeoPackageActions.swift
//  Marlin
//
//  Created by Daniel Barela on 2/28/24.
//

import Foundation
import MapKit
import SwiftUI

enum GeoPackageActions {
    class Zoom: Action {
        var latLng: CLLocationCoordinate2D
        var itemKey: String
        init(latLng: CLLocationCoordinate2D, itemKey: String) {
            self.latLng = latLng
            self.itemKey = itemKey
        }
        func action() {
            NotificationCenter.default.post(name: .TabRequestFocus, object: nil)
            let notification = MapItemsTappedNotification(itemKeys: [DataSources.asam.key: [itemKey]])
            NotificationCenter.default.post(name: .MapItemsTapped, object: notification)
        }
    }

    class Tap: Action {
        var featureItem: GeoPackageFeatureItem?
        @Binding var path: NavigationPath
        init(featureItem: GeoPackageFeatureItem?, path: Binding<NavigationPath>) {
            self.featureItem = featureItem
            self._path = path
        }
        func action() {
            guard let featureItem = featureItem else { return }

            path.append(GeoPackageRoute.detail(featureItem: featureItem))
        }
    }
}
