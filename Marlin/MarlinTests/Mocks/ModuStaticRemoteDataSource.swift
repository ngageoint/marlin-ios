//
//  ModuStaticRemoteDataSource.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/14/24.
//

import Foundation
import BackgroundTasks

@testable import Marlin

class ModuStaticRemoteDataSource: ModuRemoteDataSource {
    var list: [ModuModel] = []

    override func fetch(task: BGTask? = nil, dateString: String? = nil) async -> [ModuModel] {
        return list
    }
}
