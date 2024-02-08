//
//  RadioBeacon+Decodable.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation

struct RadioBeaconPropertyContainer: Decodable {
    private enum CodingKeys: String, CodingKey {
        case ngalol
    }
    let ngalol: [RadioBeaconModel]

    init(radioBeacons: [RadioBeaconModel]) {
        ngalol = radioBeacons
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        ngalol = try container.decode(
            [Throwable<RadioBeaconModel>].self, forKey: .ngalol
        ).compactMap { try? $0.result.get() }
    }
}
