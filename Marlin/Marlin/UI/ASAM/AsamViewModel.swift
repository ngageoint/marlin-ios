//
//  AsamViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 9/8/23.
//

import Foundation

class AsamViewModel: ObservableObject, Identifiable {
    @Published var asam: AsamModel?

    var reference: String?

    init(reference: String? = nil) {
        self.reference = reference
    }

    @Injected(\.asamRepository)
    var repository: AsamRepository
    var routeWaypointRepository: RouteWaypointRepository?
    
    @discardableResult
    func getAsam(reference: String, waypointURI: URL? = nil) -> AsamModel? {
        if let waypointURI = waypointURI {
            asam = routeWaypointRepository?.getAsam(waypointURI: waypointURI)
            return asam
        } else {
            Task {
                asam = await repository.getAsam(reference: reference)
                return asam
            }
        }
        return nil
    }
}
