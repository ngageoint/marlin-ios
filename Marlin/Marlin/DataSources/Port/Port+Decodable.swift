//
//  Port+Decodable.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import CoreLocation
import OSLog
import mgrs_ios

struct PortPropertyContainer: Decodable {
    private enum CodingKeys: String, CodingKey {
        case ports
    }
    let ports: [PortModel]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        ports = try container.decode([Throwable<PortModel>].self, forKey: .ports).compactMap { try? $0.result.get() }
    }
}
