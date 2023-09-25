//
//  Modu+Decodable.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import OSLog
import mgrs_ios

struct ModuPropertyContainer: Decodable {
    private enum CodingKeys: String, CodingKey {
        case modu
    }
    let modu: [ModuModel]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        modu = try container.decode([Throwable<ModuModel>].self, forKey: .modu).compactMap { try? $0.result.get() }
    }
}
