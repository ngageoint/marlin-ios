//
//  DifferentialGPSStationPropertyContainer.swift
//  Marlin
//
//  Created by Daniel Barela on 2/8/24.
//

import Foundation

struct DifferentialGPSStationPropertyContainer: Decodable {
    private enum CodingKeys: String, CodingKey {
        case ngalol
    }
    let ngalol: [DifferentialGPSStationModel]

    init(dgpss: [DifferentialGPSStationModel]) {
        ngalol = dgpss
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        ngalol = try container.decode(
            [Throwable<DifferentialGPSStationModel>].self, forKey: .ngalol
        )
        .compactMap { try? $0.result.get() }
    }
}
