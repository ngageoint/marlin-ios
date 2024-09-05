//
//  PublicationPropertyContainer.swift
//  Marlin
//
//  Created by Daniel Barela on 2/28/24.
//

import Foundation

struct PublicationPropertyContainer: Decodable {
    private enum CodingKeys: String, CodingKey {
        case publications
    }
    let publications: [PublicationModel]

    init(publications: [PublicationModel]) {
        self.publications = publications
    }

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var pubs: [PublicationModel] = []
        while !container.isAtEnd {
            if let pub = try? container.decode(Throwable<PublicationModel>.self) {
                if let pubResult = try? pub.result.get() {
                    pubs.append(pubResult)
                }
            }
        }
        publications = pubs
    }
}
