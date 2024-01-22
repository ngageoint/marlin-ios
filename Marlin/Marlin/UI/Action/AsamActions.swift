//
//  AsamAction.swift
//  Marlin
//
//  Created by Daniel Barela on 11/28/23.
//

import Foundation
import MapKit
import SwiftUI

protocol Action {
    func action()
}

enum Actions {
    class Location: Action {
        var latLng: CLLocationCoordinate2D
        init(latLng: CLLocationCoordinate2D) {
            self.latLng = latLng
        }
        
        func action() {
            let coordinateDisplay = UserDefaults.standard.coordinateDisplay
            UIPasteboard.general.string = coordinateDisplay.format(coordinate: latLng)
            NotificationCenter.default.post(
                name: .SnackbarNotification,
                object: SnackbarNotification(
                    snackbarModel: SnackbarModel(
                        message: "Location \(coordinateDisplay.format(coordinate: latLng)) copied to clipboard")
                )
            )
        }
    }
}

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

            path.append(AsamRoute.detail(reference))
//            NotificationCenter.default.post(
//                name: .ViewDataSource,
//                object: ViewDataSource(definition: DataSources.asam, itemKey: reference)
//            )
        }
    }
    
    class Bookmark: Action {
        var itemKey: String
        @ObservedObject var bookmarkViewModel: BookmarkViewModel
        
        init(itemKey: String, bookmarkViewModel: BookmarkViewModel) {
            self.itemKey = itemKey
            self.bookmarkViewModel = bookmarkViewModel
        }
        
        func action() {
            withAnimation {
                if bookmarkViewModel.isBookmarked {
                    bookmarkViewModel.removeBookmark()
                } else {
                    bookmarkViewModel.bookmarkBottomSheet = true
                }
            }
        }
    }
}
