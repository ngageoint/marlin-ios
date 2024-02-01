//
//  NavigationalWarningLocalDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 2/1/24.
//

import Foundation

protocol NavigationalWarningLocalDataSource {
    func batchImport(from propertiesList: [NavigationalWarningModel]) async throws -> Int
}
