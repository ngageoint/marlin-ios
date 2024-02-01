//
//  LightLocalDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 2/1/24.
//

import Foundation

protocol LightLocalDataSource {
    func batchImport(from propertiesList: [LightModel]) async throws -> Int
}
