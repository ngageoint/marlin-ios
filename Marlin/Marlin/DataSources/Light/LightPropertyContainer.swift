//
//  Light+Decodable.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import OSLog
import CoreLocation
import mgrs_ios

struct LightsPropertyContainer: Decodable {
    private enum CodingKeys: String, CodingKey {
        case ngalol
    }
    let ngalol: [LightModel]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        ngalol = try container.decode([Throwable<LightModel>].self, forKey: .ngalol).compactMap { try? $0.result.get() }
    }
}
