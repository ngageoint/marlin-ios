//
//  AsamAction.swift
//  Marlin
//
//  Created by Daniel Barela on 11/28/23.
//

import Foundation
import MapKit
import SwiftUI

enum AsamActions {
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
        var reference: String?
        @Binding var path: NavigationPath
        init(reference: String?, path: Binding<NavigationPath>) {
            self.reference = reference
            self._path = path
        }
        func action() {
            guard let reference = reference else { return }

            path.append(AsamRoute.detail(reference: reference))
        }
    }
}
