//
//  ElectronicPublicationStaticRemoteDataSource.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/15/24.
//

import Foundation
import BackgroundTasks

@testable import Marlin

class ElectronicPublicationStaticRemoteDataSource: ElectronicPublicationRemoteDataSource {
    var list: [ElectronicPublicationModel] = []

    override func fetch(task: BGTask? = nil) async -> [ElectronicPublicationModel] {
        return list
    }
}
