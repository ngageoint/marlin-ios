//
//  NavigationalWarningViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 2/22/24.
//

import Foundation

class NavigationalWarningViewModel: ObservableObject, Identifiable {
    @Published var navWarning: NavigationalWarningModel?

    var msgYear: Int?
    var msgNumber: Int?
    var navArea: String?

    @Injected(\.navWarningRepository)
    var repository: NavigationalWarningRepository
    var routeWaypointRepository: RouteWaypointRepository?

    @discardableResult
    func getNavigationalWarning(
        msgYear: Int,
        msgNumber: Int,
        navArea: String,
        waypointURI: URL? = nil
    ) -> NavigationalWarningModel? {
        if let waypointURI = waypointURI {
            navWarning = routeWaypointRepository?.getNavigationalWarning(waypointURI: waypointURI)
            return navWarning
        } else {
            navWarning = repository.getNavigationalWarning(
                msgYear: Int(msgYear),
                msgNumber: Int(msgNumber),
                navArea: navArea
            )
            return navWarning
        }
    }
}
