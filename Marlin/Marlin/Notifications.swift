//
//  Notifications.swift
//  Marlin
//
//  Created by Daniel Barela on 6/14/22.
//

import Foundation
import MapKit

extension Notification.Name {
    public static let MapItemsTapped = Notification.Name("MapItemsTapped")
    public static let MapAnnotationFocused = Notification.Name("MapAnnotationFocused")
    public static let MapViewDisappearing = Notification.Name("MapViewDisappearing")
    public static let DismissBottomSheet = Notification.Name("DismissBottomSheet")
    public static let BottomSheetDismissed = Notification.Name("BottomSheetDismissed")
    public static let MapRequestFocus = Notification.Name("MapRequestFocus")
    public static let ViewAsam = Notification.Name("ViewAsam")
}

struct MapAnnotationFocusedNotification {
    var annotation: MKAnnotation?
    var mapView: MKMapView?
}

struct MapItemsTappedNotification {
    var annotations: [Any]?
    var items: [Any]?
    var mapView: MKMapView?
}
