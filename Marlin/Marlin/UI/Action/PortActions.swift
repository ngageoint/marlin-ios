//
//  PortActions.swift
//  Marlin
//
//  Created by Daniel Barela on 1/31/24.
//

import Foundation
import CoreLocation
import SwiftUI

enum PortActions {
    class Zoom: Action {
        var latLng: CLLocationCoordinate2D
        var itemKey: String
        init(latLng: CLLocationCoordinate2D, itemKey: String) {
            self.latLng = latLng
            self.itemKey = itemKey
        }
        func action() {
            NotificationCenter.default.post(name: .TabRequestFocus, object: nil)
            let notification = MapItemsTappedNotification(itemKeys: [DataSources.port.key: [itemKey]])
            NotificationCenter.default.post(name: .MapItemsTapped, object: notification)
        }
    }

    class Tap: Action {
        var portNumber: Int?
        @Binding var path: NavigationPath
        init(portNumber: Int?, path: Binding<NavigationPath>) {
            self.portNumber = portNumber
            self._path = path
        }
        func action() {
            guard let portNumber = portNumber else { return }

            path.append(PortRoute.detail(portNumber: portNumber))
        }
    }
}
