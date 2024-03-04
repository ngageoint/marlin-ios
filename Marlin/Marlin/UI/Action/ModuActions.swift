//
//  ModuActions.swift
//  Marlin
//
//  Created by Daniel Barela on 1/22/24.
//

import Foundation
import SwiftUI
import MapKit

enum ModuActions {
    class Zoom: Action {
        var latLng: CLLocationCoordinate2D
        var itemKey: String
        init(latLng: CLLocationCoordinate2D, itemKey: String) {
            self.latLng = latLng
            self.itemKey = itemKey
        }
        func action() {
            NotificationCenter.default.post(name: .TabRequestFocus, object: nil)
            let notification = MapItemsTappedNotification(itemKeys: [DataSources.modu.key: [itemKey]])
            NotificationCenter.default.post(name: .MapItemsTapped, object: notification)
        }
    }

    class Tap: Action {
        var name: String?
        @Binding var path: NavigationPath
        init(name: String?, path: Binding<NavigationPath>) {
            self.name = name
            self._path = path
        }
        func action() {
            guard let name = name else { return }

            path.append(ModuRoute.detail(name: name))
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
