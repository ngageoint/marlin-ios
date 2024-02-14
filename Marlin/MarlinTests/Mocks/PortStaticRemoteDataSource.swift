//
//  PortStaticRemoteDataSource.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/14/24.
//

import Foundation
import BackgroundTasks

@testable import Marlin

class PortStaticRemoteDataSource: PortRemoteDataSource {
    var list: [PortModel] = []

    override func fetch(task: BGTask? = nil) async -> [PortModel] {
        list
    }
}
