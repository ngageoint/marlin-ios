//
//  ModuViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 9/15/23.
//

import Foundation

class ModuViewModel: ObservableObject, Identifiable {
    @Injected(\.moduRepository)
    var repository: ModuRepository
    @Published var modu: ModuModel?
    @Published var predicate: NSPredicate?

    var name: String?

    var routeWaypointRepository: RouteWaypointRepository?

    @discardableResult
    func getModu(name: String, waypointURI: URL? = nil) -> ModuModel? {
        self.name = name
        predicate = NSPredicate(format: "name == %@", name)

        if let waypointURI = waypointURI {
            modu = routeWaypointRepository?.getModu(waypointURI: waypointURI)
            return modu
        } else {
            modu = repository.getModu(name: name)
            return modu
        }
    }
}
