//
//  PortViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 9/21/23.
//

import Foundation

class PortViewModel: ObservableObject, Identifiable {
    @Published var port: PortModel?
    @Published var predicate: NSPredicate?
    
    var repository: (any PortRepository)?
    
    @discardableResult
    func getPort(portNumber: Int64?, waypointURI: URL?) -> PortModel? {
        if let waypointURI = waypointURI {
            if let portNumber = portNumber {
                predicate = NSPredicate(format: "portNumber == %ld", portNumber)
            }
            port = repository?.getPort(portNumber: portNumber, waypointURI: waypointURI)
            return port
        } else {
            if let portNumber = portNumber {
                predicate = NSPredicate(format: "portNumber == %ld", portNumber)
            }
            port = repository?.getPort(portNumber: portNumber, waypointURI: waypointURI)
            return port
        }
    }
}
