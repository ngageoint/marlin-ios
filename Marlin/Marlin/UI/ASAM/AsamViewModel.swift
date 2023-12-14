//
//  AsamViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 9/8/23.
//

import Foundation

class AsamViewModel: ObservableObject, Identifiable {
    @Published var asam: AsamModel?
    @Published var predicate: NSPredicate?
    
    var asamListModel: AsamListModel? {
        if let asam = asam {
            return AsamListModel(asamModel: asam)
        }
        return nil
    }
    
    var repository: AsamRepository?
    var routeWaypointRepository: RouteWaypointRepository?
    
    @discardableResult
    func getAsam(reference: String, waypointURI: URL? = nil) -> AsamModel? {
        predicate = NSPredicate(format: "reference == %@", reference)
        if let waypointURI = waypointURI {
            asam = routeWaypointRepository?.getAsam(waypointURI: waypointURI)
            return asam
        } else {
            asam = repository?.getAsam(reference: reference)
            return asam
        }
    }
}
