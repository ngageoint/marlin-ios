//
//  Asam+Decodable.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import CoreLocation
import OSLog
import mgrs_ios

struct AsamPropertyContainer: Decodable {
    private enum CodingKeys: String, CodingKey {
        case asam
    }
    let asam: [AsamModel]
    
    init(asams: [AsamModel]) {
        asam = asams
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        asam = try container.decode([Throwable<AsamModel>].self, forKey: .asam).compactMap { try? $0.result.get() }
    }
}
