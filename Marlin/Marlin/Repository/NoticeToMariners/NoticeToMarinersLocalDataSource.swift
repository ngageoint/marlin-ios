//
//  NoticeToMarinersLocalDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 2/1/24.
//

import Foundation

protocol NoticeToMarinersLocalDataSource {
    func batchImport(from propertiesList: [NoticeToMarinersModel]) async throws -> Int
}
