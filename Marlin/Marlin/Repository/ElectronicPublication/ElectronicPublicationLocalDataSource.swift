//
//  ElectronicPublicationLocalDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 2/1/24.
//

import Foundation

protocol ElectronicPublicationLocalDataSource {
    func batchImport(from propertiesList: [ElectronicPublicationModel]) async throws -> Int
}
