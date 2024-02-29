//
//  DGPSStationPropertyContainer.swift
//  Marlin
//
//  Created by Daniel Barela on 2/8/24.
//

import Foundation

struct DGPSStationPropertyContainer: Decodable {
    private enum CodingKeys: String, CodingKey {
        case ngalol
    }
    let ngalol: [DGPSStationModel]

    init(dgpss: [DGPSStationModel]) {
        ngalol = dgpss
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        ngalol = try container.decode(
            [Throwable<DGPSStationModel>].self, forKey: .ngalol
        )
        .compactMap { try? $0.result.get() }
    }
}
