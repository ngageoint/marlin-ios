//
//  RouteActions.swift
//  Marlin
//
//  Created by Daniel Barela on 2/28/24.
//

import Foundation
import SwiftUI

enum RouteActions {
    class Tap: Action {
        var uri: URL?
        @Binding var path: NavigationPath
        init(uri: URL?, path: Binding<NavigationPath>) {
            self.uri = uri
            self._path = path
        }
        func action() {
            guard let uri = uri else { return }

            path.append(MarlinRoute.editRoute(routeURI: uri))
        }
    }
}
