//
//  NavigationalWarningActions.swift
//  Marlin
//
//  Created by Daniel Barela on 2/23/24.
//

import Foundation
import MapKit
import SwiftUI

enum NavigationalWarningActions {
    class Zoom: Action {
        var latLng: CLLocationCoordinate2D
        var itemKey: String
        init(latLng: CLLocationCoordinate2D, itemKey: String) {
            self.latLng = latLng
            self.itemKey = itemKey
        }
        func action() {
            NotificationCenter.default.post(name: .TabRequestFocus, object: nil)
            let notification = MapItemsTappedNotification(itemKeys: [DataSources.navWarning.key: [itemKey]])
            NotificationCenter.default.post(name: .MapItemsTapped, object: notification)
        }
    }

    class Tap: Action {
        var msgYear: Int?
        var msgNumber: Int?
        var navArea: String?
        @Binding var path: NavigationPath
        init(msgYear: Int?, msgNumber: Int?, navArea: String?, path: Binding<NavigationPath>) {
            self.msgYear = msgYear
            self.msgNumber = msgNumber
            self.navArea = navArea
            self._path = path
        }
        func action() {
            guard let msgYear = msgYear, let msgNumber = msgNumber, let navArea = navArea else { return }

            path.append(NavigationalWarningRoute.detail(msgYear: msgYear, msgNumber: msgNumber, navArea: navArea))
        }
    }
}
