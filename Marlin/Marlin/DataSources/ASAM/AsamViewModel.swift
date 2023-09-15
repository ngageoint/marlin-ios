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
    
    var repository: (any AsamRepository)?
    
    @discardableResult
    func getAsam(reference: String, waypointURI: URL? = nil) -> AsamModel? {
        if let waypointURI = waypointURI {
            predicate = NSPredicate(format: "reference == %@", reference)
            asam = repository?.getAsam(reference: reference, waypointURI: waypointURI)
            return asam
        } else {
            predicate = NSPredicate(format: "reference == %@", reference)
            asam = repository?.getAsam(reference: reference, waypointURI: waypointURI)
            return asam
        }
    }
}
