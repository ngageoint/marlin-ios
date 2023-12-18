//
//  DFRSArea+Decodable.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation

struct DFRSAreaPropertyContainer: Decodable {
    private enum CodingKeys: String, CodingKey {
        case areas
    }
    let areas: [DFRSAreaProperties]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        areas = try container.decode(
            [Throwable<DFRSAreaProperties>].self,
            forKey: .areas)
        .compactMap { try? $0.result.get()}
    }
}

struct DFRSAreaProperties: Decodable {
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case areaName
        case areaIndex
        case areaNote
        case noteIndex
        case indexNote
    }
    
    let areaName: String?
    let areaIndex: Int?
    let areaNote: String?
    let noteIndex: Int?
    let indexNote: String?
    
    init(from decoder: Decoder) throws {
        var values = try decoder.unkeyedContainer()
        areaName = try? values.decode(String.self)
        areaIndex = try? values.decode(Int.self)
        areaNote = try? values.decodeIfPresent(String.self)
        noteIndex = try? values.decodeIfPresent(Int.self)
        indexNote = try? values.decodeIfPresent(String.self)
    }
    
    // The keys must have the same name as the attributes of the Asam entity.
    var dictionaryValue: [String: Any?] {
        [
            "areaName": areaName,
            "areaNote": areaNote,
            "areaIndex": areaIndex,
            "index": noteIndex,
            "indexNote": indexNote
        ]
    }
}
