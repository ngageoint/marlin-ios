//
//  ElectronicPublication+Decodable.swift
//  Marlin
//
//  Created by Daniel Barela on 10/25/22.
//

import Foundation

struct ElectronicPublicationPropertyContainer: Decodable {
    private enum CodingKeys: String, CodingKey {
        case publications
    }
    let publications: [ElectronicPublicationModel]

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var pubs: [ElectronicPublicationModel] = []
        while !container.isAtEnd {
            if let pub = try? container.decode(Throwable<ElectronicPublicationModel>.self) {
                if let pubResult = try? pub.result.get() {
                    pubs.append(pubResult)
                }
            }
        }
        publications = pubs
    }
}
