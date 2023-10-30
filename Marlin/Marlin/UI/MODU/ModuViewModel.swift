//
//  ModuViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 9/15/23.
//

import Foundation

class ModuViewModel: ObservableObject, Identifiable {
    @Published var modu: ModuModel?
    @Published var predicate: NSPredicate?
    
    var repository: (any ModuRepository)?
    
    @discardableResult
    func getModu(name: String, waypointURI: URL? = nil) -> ModuModel? {
        if let waypointURI = waypointURI {
            predicate = NSPredicate(format: "name == %@", name)
            modu = repository?.getModu(name: name, waypointURI: waypointURI)
            return modu
        } else {
            predicate = NSPredicate(format: "name == %@", name)
            modu = repository?.getModu(name: name, waypointURI: waypointURI)
            return modu
        }
    }
}
